import 'package:flutter/material.dart';
import 'package:respiracare/app/theme/colors.dart';
import 'package:respiracare/app/theme/spacing.dart';
import 'package:respiracare/app/theme/typography.dart';
import '../buttons/app_button.dart';

class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    this.title = 'Unable to load data',
    this.message =
        'An unexpected error occurred while fetching information. Please try again.',
    this.retryLabel = 'Retry',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      // Screen readers announce the full error summary when it appears.
      label: '$title. $message',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.0,
                height: 72.0,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 36.0,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: retryLabel,
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                  variant: AppButtonVariant.outlined,
                  fullWidth: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
