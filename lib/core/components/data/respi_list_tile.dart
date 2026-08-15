import 'package:flutter/material.dart';
import '../../theme/tokens/respi_shapes.dart';
import '../../theme/tokens/respi_spacing.dart';
import '../../theme/tokens/respi_typography.dart';

/// Accessible list tile with consistent padding and touch targets.
class RespiListTile extends StatelessWidget {
  const RespiListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isThreeLine = false,
    this.dense = false,
    this.backgroundColor,
  });

  final Widget? leading;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isThreeLine;
  final bool dense;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: RespiShapes.mdRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: RespiShapes.mdRadius,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: RespiSpacing.md, vertical: dense ? RespiSpacing.sm : RespiSpacing.md),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: RespiSpacing.md)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(title!, style: RespiTypography.bodyLarge.copyWith(color: cs.onSurface, fontWeight: FontWeight.w500)),
                    if (subtitle != null) ...[
                      const SizedBox(height: RespiSpacing.xs),
                      Text(subtitle!, style: RespiTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant),
                        maxLines: isThreeLine ? 3 : 2, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: RespiSpacing.md), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
