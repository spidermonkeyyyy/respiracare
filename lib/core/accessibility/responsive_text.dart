import 'package:flutter/material.dart';
import '../theme/tokens/respi_typography.dart';

/// Text widget that automatically selects the best size for readability
/// given the available width and current text scale factor.
///
/// Use for hero numbers, card titles, and any text that must remain
/// on a single line or within a constrained space.
class ResponsiveText extends StatelessWidget {
  const ResponsiveText({
    super.key,
    required this.text,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.minSize = 12,
    this.maxSize = 48,
    this.semanticsLabel,
  });

  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final double minSize;
  final double maxSize;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaler.scale(1.0);
    final baseStyle = style ?? RespiTypography.bodyLarge;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        if (availableWidth == double.infinity) {
          return Text(
            text,
            style: baseStyle,
            maxLines: maxLines,
            overflow: overflow,
            semanticsLabel: semanticsLabel,
          );
        }

        // Binary search for the largest font size that fits
        double low = minSize;
        double high = maxSize;
        double bestSize = minSize;

        final textPainter = TextPainter(textDirection: TextDirection.ltr);

        while (low <= high) {
          final mid = (low + high) / 2;
          textPainter.text = TextSpan(
            text: text,
            style: baseStyle.copyWith(fontSize: mid),
          );
          textPainter.layout(maxWidth: availableWidth);

          if (textPainter.didExceedMaxLines) {
            high = mid - 0.5;
          } else if (textPainter.size.width > availableWidth) {
            high = mid - 0.5;
          } else {
            bestSize = mid;
            low = mid + 0.5;
          }
        }

        // Apply text scale but cap it to prevent overflow
        final scaledSize = (bestSize / textScale).clamp(minSize, maxSize);

        return Text(
          text,
          style: baseStyle.copyWith(fontSize: scaledSize),
          maxLines: maxLines,
          overflow: overflow,
          semanticsLabel: semanticsLabel,
        );
      },
    );
  }
}
