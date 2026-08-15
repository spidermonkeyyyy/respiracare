import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/tokens/respi_colors.dart';
import '../../theme/tokens/respi_typography.dart';

/// A single value plotted on a [RespiLineChart].
///
/// Kept deliberately framework-agnostic so the chart can be reused by any
/// feature without the `core` layer depending on feature models.
class ChartPoint {
  final double value;
  final DateTime time;
  final String? label;

  const ChartPoint({
    required this.value,
    required this.time,
    this.label,
  });

  @override
  bool operator ==(Object other) =>
      other is ChartPoint &&
      other.value == value &&
      other.time == time &&
      other.label == label;

  @override
  int get hashCode => Object.hash(value, time, label);
}

/// Accessible, dependency-free line chart used for clinical trends.
///
/// Design goals (Step 11):
///  - No third-party chart package — rendered with [CustomPainter].
///  - Axis labels scale with the system text size ([TextScaler]).
///  - High-contrast mode uses solid colors and thicker strokes.
///  - Reduced motion disables the draw-in animation (static render).
///  - Semantic label summarizes the series for screen readers.
///  - Charts describe data — they never diagnose.
class RespiLineChart extends StatelessWidget {
  const RespiLineChart({
    super.key,
    this.points = const [],
    required this.unit,
    this.color,
    this.height = 200,
    this.enableAnimation = true,
    this.semanticsLabel,
  });

  /// Points, ideally sorted oldest → newest.  Empty lists render an empty
  /// placeholder rather than an error.
  final List<ChartPoint> points;

  /// Measurement unit label shown on the y-axis (e.g. `%`, `bpm`).
  final String unit;

  /// Line color; defaults to the theme's primary color.
  final Color? color;

  /// Chart height (excluding surrounding widget padding).
  final double height;

  /// When `true` (and reduced-motion is off) the series draws itself in.
  final bool enableAnimation;

  /// Overrides the computed accessibility label.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final lineColor = color ?? cs.primary;
    final highContrast = mediaQuery.highContrast;
    final animate = enableAnimation && !mediaQuery.disableAnimations;

    final label = semanticsLabel ?? _summarize();

    Widget chart = Semantics(
      label: label,
      image: true,
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: animate ? const Duration(milliseconds: 700) : Duration.zero,
          curve: Curves.easeOutCubic,
          builder: (context, progress, _) {
            return CustomPaint(
              size: Size(double.infinity, height),
              painter: _RespiLineChartPainter(
                points: points,
                unit: unit,
                color: lineColor,
                progress: progress,
                highContrast: highContrast,
                gridColor:
                    isDark ? RespiColors.outlineDark : RespiColors.outline,
                labelColor: cs.onSurfaceVariant,
                background: cs.surface,
                textScaler: mediaQuery.textScaler,
                textDirection: Directionality.of(context),
              ),
            );
          },
        ),
      ),
    );

    // High contrast: wrap in a visible border so the plot area is clearly
    // delineated even with color-blindness.
    if (highContrast) {
      chart = Container(
        decoration: BoxDecoration(
          border: Border.all(color: cs.onSurface, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: chart,
      );
    }

    return chart;
  }

  String _summarize() {
    if (points.isEmpty) return 'Aucune donnée à afficher.';
    final values = points.map((p) => p.value).toList();
    final min = values.reduce(math.min);
    final max = values.reduce(math.max);
    final latest = values.last;
    final first = points.first.time;
    final last = points.last.time;
    final range = 'du ${_formatDate(first)} au ${_formatDate(last)}';
    return 'Courbe de mesures. ${points.length} mesures $range. '
        'Valeur la plus basse $min, plus haute $max, dernière $latest.';
  }
}

// ─── End of RespiLineChart widget ────────────────────────────────

String _formatDate(DateTime d) => '${d.day}/${d.month}';

/// Formats a numeric axis label without useless decimals.
String _formatValue(double v) {
  if (v == v.roundToDouble()) return v.round().toString();
  final s = v.toStringAsFixed(1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}

/// Rounds a rough step up to a "nice" 1/2/5 × 10ⁿ step.
double _niceStep(double rough) {
  if (rough <= 0) return 1;
  final exponent = (math.log(rough) / math.ln10).floor();
  final magnitude = math.pow(10, exponent).toDouble();
  final fraction = rough / magnitude;
  final nice = fraction <= 1
      ? 1.0
      : fraction <= 2
          ? 2.0
          : fraction <= 5
              ? 5.0
              : 10.0;
  return nice * magnitude;
}

// ──────────────────────────────────────────────────────────────────

class _PlotMetrics {
  final Rect plot;
  final double yMin;
  final double yMax;
  final double step;

  const _PlotMetrics({
    required this.plot,
    required this.yMin,
    required this.yMax,
    required this.step,
  });
}

class _RespiLineChartPainter extends CustomPainter {
  _RespiLineChartPainter({
    required this.points,
    required this.unit,
    required this.color,
    required this.progress,
    required this.highContrast,
    required this.gridColor,
    required this.labelColor,
    required this.background,
    required this.textScaler,
    required this.textDirection,
  });

  final List<ChartPoint> points;
  final String unit;
  final Color color;
  final double progress;
  final bool highContrast;
  final Color gridColor;
  final Color labelColor;
  final Color background;
  final TextScaler textScaler;
  final TextDirection textDirection;

  static const double _leftPad = 46;
  static const double _rightPad = 12;
  static const double _topPad = 14;
  static const double _bottomPad = 26;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      _paintEmptyState(canvas, size);
      return;
    }

    final metrics = _computeMetrics(size);

    _paintGridAndLabels(canvas, size, metrics);
    _paintSeries(canvas, metrics);
  }

  _PlotMetrics _computeMetrics(Size size) {
    final plot = Rect.fromLTRB(
      _leftPad,
      _topPad,
      math.max(1, size.width - _leftPad - _rightPad),
      math.max(1, size.height - _topPad - _bottomPad),
    );

    var rawMin = points.first.value;
    var rawMax = points.first.value;
    for (final p in points) {
      rawMin = math.min(rawMin, p.value);
      rawMax = math.max(rawMax, p.value);
    }

    // Expand range so single points / flat lines still render in the middle.
    var low = rawMin;
    var high = rawMax;
    if (high - low < 1) {
      low = rawMin - 2;
      high = rawMax + 2;
    } else {
      final padding = (high - low) * 0.15;
      low -= padding;
      high += padding;
    }

    // Snap to "nice" values aligned to the computed step.
    final step = math.max(_niceStep((high - low) / 3), 0.5);
    final yMin = (low / step).floorToDouble() * step;
    final yMax = (high / step).ceilToDouble() * step;

    return _PlotMetrics(plot: plot, yMin: yMin, yMax: yMax, step: step);
  }

  double _xFor(int index, _PlotMetrics m) {
    if (points.length == 1) return m.plot.center.dx;
    return m.plot.left +
        (m.plot.width * index / (points.length - 1)) * progress;
  }

  double _yFor(double value, _PlotMetrics m) {
    final span = m.yMax - m.yMin;
    if (span == 0) return m.plot.center.dy;
    final t = (value - m.yMin) / span;
    return m.plot.bottom - t * m.plot.height;
  }

  void _paintGridAndLabels(Canvas canvas, Size size, _PlotMetrics m) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = highContrast ? 1.4 : 1.0;

    // Determine gridline ticks from the nice step.
    final double firstTick = (m.yMin / m.step).ceilToDouble() * m.step;
    final ticks = <double>[];
    for (var v = firstTick; v <= m.yMax + 0.0001; v += m.step) {
      ticks.add(v);
    }
    if (ticks.length > 5) {
      // Fall back to 4 evenly-spaced lines when ticks are too dense.
      ticks
        ..clear()
        ..addAll([m.yMin, m.yMin + m.step * 2, m.yMin + m.step * 4, m.yMax]);
    }

    for (final tick in ticks) {
      final y = _yFor(tick, m);
      canvas.drawLine(
        Offset(m.plot.left, y),
        Offset(m.plot.right, y),
        gridPaint,
      );
      _paintLabel(
        canvas,
        size,
        _formatValue(tick),
        Offset(_leftPad - 6, y),
        alignRight: true,
        centeredVertically: true,
      );
    }

    // X-axis labels: first / quarter points / last.
    const labelCount = 4;
    final indices = <int>{};
    for (var k = 0; k < labelCount; k++) {
      final i = (k * (points.length - 1) / (labelCount - 1)).round();
      indices.add(i.clamp(0, points.length - 1));
    }
    final sortedIndices = indices.toList()..sort();
    for (final i in sortedIndices) {
      final dateLabel = _formatDate(points[i].time);
      canvas.drawLine(
        Offset(_xFor(i, m), m.plot.bottom),
        Offset(_xFor(i, m), m.plot.bottom + 3),
        gridPaint,
      );
      _paintLabel(
        canvas,
        size,
        dateLabel,
        Offset(_xFor(i, m), m.plot.bottom + 5),
        centeredHorizontally: true,
      );
    }

    // Unit label (top-left, above the grid).
    _paintLabel(canvas, size, unit, const Offset(_leftPad, 0));
  }

  void _paintSeries(Canvas canvas, _PlotMetrics m) {
    // Gradient fill under the line (disabled in high contrast: keeps the
    // chart crisp and readable).
    if (!highContrast) {
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.02),
          ],
        ).createShader(
          Rect.fromLTRB(m.plot.left, m.plot.top, m.plot.right, m.plot.bottom),
        );
      final fillPath = Path()..moveTo(_xFor(0, m), m.plot.bottom);
      for (var i = 0; i < points.length; i++) {
        fillPath.lineTo(_xFor(i, m), _yFor(points[i].value, m));
      }
      fillPath
        ..lineTo(_xFor(points.length - 1, m), m.plot.bottom)
        ..close();
      canvas.drawPath(fillPath, fillPaint);
    }

    // The polyline itself.
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = highContrast ? 4.0 : 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (points.length == 1) {
      canvas.drawCircle(
        Offset(_xFor(0, m), _yFor(points[0].value, m)),
        highContrast ? 6 : 4,
        Paint()..color = color,
      );
      return;
    }

    final linePath = Path();
    for (var i = 0; i < points.length; i++) {
      final dx = _xFor(i, m);
      final dy = _yFor(points[i].value, m);
      if (i == 0) {
        linePath.moveTo(dx, dy);
      } else {
        linePath.lineTo(dx, dy);
      }
    }
    canvas.drawPath(linePath, linePaint);

    // Point markers (revealed as `progress` increases).
    final markerStroke = Paint()
      ..color = background
      ..style = PaintingStyle.stroke
      ..strokeWidth = highContrast ? 2.6 : 1.6;
    final markerFill = Paint()..color = color;
    for (var i = 0; i < points.length; i++) {
      final dx = _xFor(i, m);
      final dy = _yFor(points[i].value, m);
      final radius = highContrast ? 5.5 : 3.5;
      canvas.drawCircle(Offset(dx, dy), radius, markerStroke);
      canvas.drawCircle(Offset(dx, dy), radius - 0.5, markerFill);
    }
  }

  void _paintEmptyState(Canvas canvas, Size size) {
    _paintLabel(canvas, size, 'Aucune donnée', size.center(Offset.zero));
  }

  void _paintLabel(
    Canvas canvas,
    Size size,
    String text,
    Offset anchor, {
    bool alignRight = false,
    bool centeredHorizontally = false,
    bool centeredVertically = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: labelStyle(),
      ),
      textDirection: textDirection,
      textScaler: textScaler,
    )..layout();

    var offset = anchor;
    if (alignRight) {
      offset = Offset(anchor.dx - tp.width, anchor.dy);
    }
    if (centeredHorizontally) {
      offset = Offset(anchor.dx - tp.width / 2, anchor.dy);
    }
    if (centeredVertically) {
      offset = Offset(offset.dx, anchor.dy - tp.height / 2);
    }

    // Keep labels inside the canvas.
    final left =
        offset.dx.clamp(0.0, math.max(0, size.width - tp.width)).toDouble();
    final top =
        offset.dy.clamp(0.0, math.max(0, size.height - tp.height)).toDouble();

    tp.paint(canvas, Offset(left, top));
  }

  TextStyle labelStyle() {
    return RespiTypography.labelMedium.copyWith(
      color: labelColor,
      fontSize: highContrast ? 12 : 11,
    );
  }

  @override
  bool shouldRepaint(_RespiLineChartPainter old) =>
      old.points != points ||
      old.unit != unit ||
      old.color != color ||
      old.progress != progress ||
      old.highContrast != highContrast ||
      old.gridColor != gridColor ||
      old.labelColor != labelColor ||
      old.background != background ||
      old.textScaler != textScaler ||
      old.textDirection != textDirection;
}

// ─── End of RespiLineChart widget ────────────────────────────────
