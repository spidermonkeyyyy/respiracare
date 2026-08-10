import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/utils/animations/app_animations.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../providers/monitoring_provider.dart';

class MonitoringIntroScreen extends ConsumerWidget {
  const MonitoringIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(monitoringProvider);
    final hasDraft = state.answers.isNotEmpty;
    final draftCount = state.answers.length;
    final total = state.totalSteps;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Suivi quotidien',
          style:
              AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              AppFadeAnimation(
                child: Center(
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 52.0,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Title
              AppSlideAnimation(
                delay: const Duration(milliseconds: 80),
                child: Text(
                  'Votre suivi respiratoire',
                  style: AppTypography.displayLarge.copyWith(fontSize: 26.0),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Description
              AppSlideAnimation(
                delay: const Duration(milliseconds: 120),
                child: Text(
                  'Quelques questions pour faire le point sur votre respiration et vos symptômes d\'aujourd\'hui.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Info Cards Row
              AppFadeAnimation(
                delay: const Duration(milliseconds: 160),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.schedule_rounded,
                        label: 'Environ\n2 minutes',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.assignment_outlined,
                        label: '$total questions\nrespirables',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.medical_services_outlined,
                        label: 'Partagé\navec votre équipe',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Care team message
              AppFadeAnimation(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.health_and_safety_outlined,
                        color: AppColors.info,
                        size: 22.0,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Vos réponses seront transmises à votre équipe soignante pour assurer votre télésurveillance.',
                          style: AppTypography.secondaryText.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Draft resume banner
              if (hasDraft) ...[
                AppFadeAnimation(
                  delay: const Duration(milliseconds: 220),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.history_rounded,
                                color: AppColors.warning, size: 18),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Suivi en cours',
                              style: AppTypography.titleLarge.copyWith(
                                fontSize: 15.0,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Vous avez complété $draftCount étape${draftCount > 1 ? 's' : ''} sur $total.',
                          style: AppTypography.secondaryText
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: 'Reprendre',
                                onPressed: () =>
                                    context.go('/patient/monitoring/question'),
                                fullWidth: true,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppButton(
                                text: 'Recommencer',
                                variant: AppButtonVariant.outlined,
                                onPressed: () {
                                  ref.read(monitoringProvider.notifier).reset();
                                  context.go('/patient/monitoring/question');
                                },
                                fullWidth: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                AppFadeAnimation(
                  delay: const Duration(milliseconds: 240),
                  child: AppButton(
                    text: 'Commencer',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () {
                      ref.read(monitoringProvider.notifier).reset();
                      context.go('/patient/monitoring/question');
                    },
                    fullWidth: true,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22.0, color: AppColors.primary),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelMedium
                .copyWith(fontWeight: FontWeight.w600, height: 1.3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
