import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../providers/smoking_cessation_provider.dart';

class EducationalContentDetailScreen extends ConsumerWidget {
  final String contentId;

  const EducationalContentDetailScreen({super.key, required this.contentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(smokingCessationProvider);
    final content = state.educationalContent
        .where((item) => item.id == contentId)
        .firstOrNull;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => context.pop(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Contenu éducatif'),
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          automaticallyImplyLeading: true,
        ),
        body: SafeArea(
          child: content == null
              ? _buildNotFound(context)
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.medium),
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  color: AppColors.primary,
                                  size: 24.0,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  content.title,
                                  style: AppTypography.headlineLarge,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            content.summary,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (content.isPlaceholder) ...[
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.08),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.small),
                                border: Border.all(
                                  color: AppColors.warning
                                      .withValues(alpha: 0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                'Ce contenu est un placeholder. Il sera remplacé par des ressources validées par l\'équipe soignante.',
                                style: AppTypography.bodyMedium
                                    .copyWith(color: AppColors.warning),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        content.content,
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.article_rounded,
                size: 64.0, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            const Text('Ressource introuvable', style: AppTypography.headlineLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Cette ressource n\'est pas disponible pour le moment.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}