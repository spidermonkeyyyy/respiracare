import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../features/authentication/providers/auth_provider.dart';
import '../providers/monitoring_provider.dart';
import '../widgets/monitoring_summary_card.dart';

class MonitoringReviewScreen extends ConsumerWidget {
  const MonitoringReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(monitoringProvider);
    final authState = ref.watch(authProvider);
    final notifier = ref.read(monitoringProvider.notifier);
    final patientId = authState.currentUser?.id ?? 'unknown';

    final now = DateTime.now();
    final timeStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')} à ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.go('/patient/monitoring/question'),
        ),
        title: Text(
          'Vérification de vos réponses',
          style:
              AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.checklist_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Votre suivi du $timeStr',
                                  style: AppTypography.titleLarge
                                      .copyWith(fontSize: 15.0),
                                ),
                                const Text(
                                  'Vérifiez vos réponses avant d\'envoyer.',
                                  style: AppTypography.labelMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'Votre suivi',
                      style:
                          AppTypography.headlineLarge.copyWith(fontSize: 20.0),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Summary cards for each question
                    ...state.questions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final question = entry.value;
                      final answer = state.answers[question.id];
                      return MonitoringSummaryCard(
                        question: question,
                        answer: answer,
                        onEdit: () {
                          notifier.goToStep(index);
                          context.go('/patient/monitoring/question');
                        },
                      );
                    }),

                    if (state.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadius.small),
                          border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.danger, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: AppTypography.secondaryText.copyWith(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),

            // Bottom Submit Bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: AppButton(
                text: 'Envoyer mon suivi',
                icon: Icons.send_rounded,
                loading: state.isSubmitting,
                onPressed: state.isSubmitting
                    ? null
                    : () async {
                        final success =
                            await notifier.submitMonitoring(patientId);
                        if (success && context.mounted) {
                          context.go('/patient/monitoring/result');
                        }
                      },
                fullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
