import 'package:flutter/material.dart';
import '../../theme/tokens/respi_elevation.dart';
import '../../theme/tokens/respi_shapes.dart';
import '../../theme/tokens/respi_spacing.dart';

/// RespiraCare card component for vitals, tasks, alerts, treatments.
class RespiCard extends StatelessWidget {
  const RespiCard({
    super.key,
    this.child,
    this.header,
    this.footer,
    this.onTap,
    this.padding = const EdgeInsets.all(RespiSpacing.md),
    this.margin = const EdgeInsets.only(bottom: RespiSpacing.md),
    this.elevation = RespiElevation.sm,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = RespiShapes.xlRadius,
  });

  final Widget? child;
  final Widget? header;
  final Widget? footer;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final List<BoxShadow> elevation;
  final Color? borderColor;
  final Color? backgroundColor;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget content = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? cs.surfaceContainerHighest,
        borderRadius: borderRadius,
        border: borderColor != null ? Border.all(color: borderColor!, width: 1.5) : null,
        boxShadow: elevation,
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (header != null) ...[header!, const SizedBox(height: RespiSpacing.md)],
            if (child != null) child!,
            if (footer != null) ...[const SizedBox(height: RespiSpacing.md), footer!],
          ],
        ),
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, borderRadius: borderRadius, child: content),
      );
    }

    return Padding(padding: margin, child: content);
  }
}
