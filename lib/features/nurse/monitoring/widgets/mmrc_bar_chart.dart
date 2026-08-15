import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../models/respiratory_trend.dart';

/// A compact bar chart for the mMRC dyspnoea grade (0–4 scale).
///
/// Rendered with [CustomPainter] so it needs no third-party chart package.
/// Bars are colour-graded by severity (green → amber → red) to support
/// colorblind users through both hue and the numeric axis label.
class MmrcBarChart extends StatelessWidget {
  /// Points with a non-null [RespiratoryTrendPoint.mmrcGrade].
  final List<RespiratoryTrendPoint> points;

  /// Currently selected point index (for tooltip highlight), nullable.
  final int? selectedIndex;

  /// Callback with the nearest point index for a horizontal tap.
  final ValueChanged<int>? onPointTap;

  const MmrcBarChart({
    super.key,
    this.points = const [],
    this.selectedIndex,
    this.onPointTap,
  });

  static Color colorForGrade(int grade) {
    switch (grade) {
      case 0:
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.warning;
      default:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effective = points.where((p) => p.mmrcGrade != null).toList();
    final series = effective.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const height = 160.0;

        return GestureDetector(
          onTapDown: (details) {
            if (series.isEmpty || onPointTap == null) return;
            final index =
                ((details.localPosition.dx / width) * series.length)
                    .floor()
                    .clamp(0, series.length - 1);
            onPointTap!(index);
          },
          child: CustomPaint(
            size: Size(width, height),
            painter: _MmrcBarChartPainter(
              series: series,
              selectedIndex: selectedIndex,
            ),
          ),
        );
      },
    );
  }
}

class _MmrcBarChartPainter extends CustomPainter {
  _MmrcBarChartPainter({
    required this.series,
    required this.selectedIndex,
  });

  final List<RespiratoryTrendPoint> series;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) {
      _label(canvas, size, 'Aucune donnée');
      return;
    }

    const maxGrade = 4;
    final slotW = size.width / series.length;
    final barW = slotW * 0.55;
    final plotBottom = size.height - 16;

    for (var i = 0; i < series.length; i++) {
      final grade = series[i].mmrcGrade!;
      final barCenter = slotW * i + slotW / 2;
      final barTop =
          plotBottom - (grade / maxGrade) * (plotBottom - 10);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          barCenter - barW / 2,
          barTop,
          barCenter + barW / 2,
          plotBottom,
        ),
        const Radius.circular(4),
      );

      final gradeColor = MmrcBarChart.colorForGrade(grade);
      final selected = selectedIndex == i;
      canvas.drawRRect(
        rect,
        Paint()
          ..color = selected ? AppColors.primary : gradeColor
          ..style = PaintingStyle.fill,
      );

      // Grade label under each bar.
      _labelAt(canvas, '$grade', Offset(barCenter, plotBottom + 16),
          centerX: true);
    }
  }

  void _label(Canvas canvas, Size size, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, size.height / 2));
  }

  void _labelAt(Canvas canvas, String text, Offset anchor, {bool centerX = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final dx = centerX ? anchor.dx - tp.width / 2 : anchor.dx;
    tp.paint(canvas, Offset(dx, anchor.dy));
  }

  @override
  bool shouldRepaint(_MmrcBarChartPainter old) =>
      old.series != series || old.selectedIndex != selectedIndex;
}
