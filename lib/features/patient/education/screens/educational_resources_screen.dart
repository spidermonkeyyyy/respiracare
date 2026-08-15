import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/animations/app_animations.dart';
import '../../../../app/widgets/app_header.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../providers/smoking_cessation_provider.dart';
import '../widgets/educational_content_card.dart';

class EducationalResourcesScreen extends ConsumerStatefulWidget {
  const EducationalResourcesScreen({super.key});

  @override
  ConsumerState<EducationalResourcesScreen> createState() =>
      _EducationalResourcesScreenState();
}

class _EducationalResourcesScreenState
    extends ConsumerState<EducationalResourcesScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smokingCessationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'Ressources éducatives',
        showBackButton: true,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(SmokingCessationState state) {
    if (state.isLoading) {
      return const _ResourcesSkeleton();
    }

    if (state.errorMessage != null) {
      return AppErrorState(
        title: 'Impossible de charger les ressources',
        message: state.errorMessage!,
        retryLabel: 'Réessayer',
        onRetry: () => ref.read(smokingCessationProvider.notifier).loadData(),
      );
    }

    if (state.educationalContent.isEmpty) {
      return AppEmptyState(
        title: 'Aucune ressource disponible',
        message:
            'Les ressources éducatives seront ajoutées prochainement par votre équipe soignante.',
        icon: Icons.menu_book_rounded,
        actionLabel: 'Actualiser',
        onActionPressed: () =>
            ref.read(smokingCessationProvider.notifier).loadData(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(smokingCessationProvider.notifier).loadData(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        children: [
          AppFadeAnimation(
            duration: const Duration(milliseconds: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ressources éducatives',
                  style: AppTypography.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Contenu de support à lire avec votre équipe soignante avant toute validation clinique.',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSlideAnimation(
            delay: const Duration(milliseconds: 100),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Technique d’inhalation',
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Accédez à l’espace dédié à la technique d’inhalation et aux vidéos éducatives.',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    text: 'Voir la technique',
                    icon: Icons.air_rounded,
                    fullWidth: true,
                    onPressed: () => context.push('/patient/education/inhaler'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Contenus disponibles',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          ...state.educationalContent.asMap().entries.map((entry) {
            final index = entry.key;
            final content = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: EducationalContentCard(
                content: content,
                index: index,
                onTap: () =>
                    context.push('/patient/education/resources/${content.id}'),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _ResourcesSkeleton extends StatelessWidget {
  const _ResourcesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      children: [
        Container(
          height: 28.0,
          width: 160.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 20.0,
          width: 240.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 124.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              height: 92.0,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
            ),
          );
        }),
      ],
    );
  }
}
