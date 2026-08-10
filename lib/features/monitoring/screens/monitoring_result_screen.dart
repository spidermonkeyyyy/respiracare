import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/utils/animations/app_animations.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../features/patient_dashboard/providers/patient_dashboard_provider.dart';
import '../models/evaluation_result.dart';
import '../providers/monitoring_provider.dart';

class MonitoringResultScreen extends ConsumerWidget {
  const MonitoringResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(monitoringProvider);
    final result = state.evaluationResult;

    if (result == null) {
      // Fallback — should not happen in normal flow
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: AppButton(
            text: 'Retour à l\'accueil',
            onPressed: () => context.go('/patient/home'),
            fullWidth: false,
          ),
        ),
      );
    }

    final isNormal = result.status == EvaluationStatus.normal;
    final Color statusColor = isNormal ? AppColors.success : AppColors.warning;
    final IconData statusIcon =
        isNormal ? Icons.check_circle_rounded : Icons.info_outline_rounded;
    final String statusTitle = isNormal ? 'Suivi envoyé ✓' : 'Suivi transmis';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        ref.read(monitoringProvider.notifier).reset();
        context.go('/patient/home');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Animated success icon
                AppScaleAnimation(
                  duration: AppAnimationDuration.slow,
                  initialScale: 0.6,
                  child: Container(
                    width: 110.0,
                    height: 110.0,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 2.0,
                      ),
                    ),
                    child: Icon(statusIcon, size: 58.0, color: statusColor),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                AppFadeAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Text(
                        statusTitle,
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 28.0,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Patient-facing message — NEVER a diagnosis
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(AppRadius.large),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          result.patientMessage,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.6,
                            fontSize: 16.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // Return to dashboard button
                AppFadeAnimation(
                  delay: const Duration(milliseconds: 350),
                  child: AppButton(
                    text: 'Retour à l\'accueil',
                    icon: Icons.home_rounded,
                    onPressed: () {
                      // Refresh dashboard so the Daily Monitoring Card updates
                      ref
                          .read(patientDashboardProvider.notifier)
                          .completeQuestionnaire();
                      ref.read(monitoringProvider.notifier).reset();
                      context.go('/patient/home');
                    },
                    fullWidth: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
