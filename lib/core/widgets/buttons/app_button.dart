import 'package:flutter/material.dart';
import 'package:respiracare/app/theme/colors.dart';
import 'package:respiracare/app/theme/radius.dart';
import 'package:respiracare/app/theme/spacing.dart';
import 'package:respiracare/app/theme/typography.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outlined,
  danger,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool enabled;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.enabled = true,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = enabled && !loading && onPressed != null;

    final Widget buttonContent = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor()),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: _getTextStyle(isInteractive),
          ),
        ] else ...[
          if (icon != null) ...[
            Icon(
              icon,
              size: 20.0,
              color: _getIconColor(isInteractive),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            text,
            style: _getTextStyle(isInteractive),
          ),
        ],
      ],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 48.0, // Minimum touch target height guideline
      ),
      child: Material(
        color: _getBackgroundColor(isInteractive),
        borderRadius: AppRadius.buttonBorderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isInteractive ? onPressed : null,
          splashColor: Colors.black.withValues(alpha: 0.08),
          highlightColor: Colors.black.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md - 2,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.buttonBorderRadius,
              border: _getBorder(isInteractive),
            ),
            child: buttonContent,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isInteractive) {
    if (!isInteractive) {
      return AppColors.surfaceVariant;
    }
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.secondary:
        return AppColors.secondary;
      case AppButtonVariant.outlined:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return AppColors.danger;
    }
  }

  Color _getLoadingColor() {
    switch (variant) {
      case AppButtonVariant.outlined:
        return AppColors.primary;
      default:
        return AppColors.surface;
    }
  }

  Color _getIconColor(bool isInteractive) {
    if (!isInteractive) return AppColors.textMuted;
    switch (variant) {
      case AppButtonVariant.outlined:
        return AppColors.primary;
      default:
        return AppColors.surface;
    }
  }

  TextStyle _getTextStyle(bool isInteractive) {
    final baseStyle = AppTypography.bodyMedium.copyWith(
      fontWeight: FontWeight.w600,
    );

    if (!isInteractive) {
      return baseStyle.copyWith(color: AppColors.textMuted);
    }

    switch (variant) {
      case AppButtonVariant.outlined:
        return baseStyle.copyWith(color: AppColors.primary);
      default:
        return baseStyle.copyWith(color: AppColors.surface);
    }
  }

  Border? _getBorder(bool isInteractive) {
    if (variant == AppButtonVariant.outlined) {
      return Border.all(
        color: isInteractive ? AppColors.primary : AppColors.border,
        width: 1.5,
      );
    }
    return null;
  }
}
