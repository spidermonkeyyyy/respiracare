import 'package:flutter/material.dart';
import '../../theme/tokens/respi_spacing.dart';
import '../../theme/tokens/respi_typography.dart';

/// Consistent app bar with optional avatar, actions, and bottom widget.
class RespiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RespiAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leadingAvatar,
    this.actions,
    this.bottom,
    this.centerTitle = false,
    this.elevation = 0,
  });

  final String? title;
  final String? subtitle;
  final Widget? leadingAvatar;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final double elevation;

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0) + (subtitle != null ? 8 : 0),
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      centerTitle: centerTitle,
      elevation: elevation,
      scrolledUnderElevation: 0,
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      leading: leadingAvatar != null
          ? Padding(padding: const EdgeInsets.only(left: RespiSpacing.sm), child: leadingAvatar)
          : null,
      title: Column(
        crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Text(title!, style: RespiTypography.titleLarge.copyWith(color: cs.onSurface)),
          if (subtitle != null)
            Text(subtitle!, style: RespiTypography.bodySmall.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}
