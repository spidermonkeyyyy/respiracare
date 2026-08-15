import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/spacing.dart';
import '../../app/theme/typography.dart';

/// Shared application header used by both the patient and nurse shells
/// (Step 4.11E). Guarantees consistent safe-area handling, background,
/// branding and typography across every screen.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.title = 'RespiraCare',
    this.showBackButton = false,
    this.onBack,
    this.actions,
    this.leading,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBackButton
          ? (leading ??
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                tooltip: 'Retour',
              ))
          : leading,
      title: Row(
        children: [
          const Icon(Icons.health_and_safety_rounded,
              color: AppColors.primary, size: 22.0),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style:
                AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      actions: actions,
    );
  }
}
