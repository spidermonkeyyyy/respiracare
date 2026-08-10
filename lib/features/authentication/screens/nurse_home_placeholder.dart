import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:respiracare/app/theme/colors.dart';
import 'package:respiracare/app/theme/spacing.dart';
import 'package:respiracare/app/theme/typography.dart';
import 'package:respiracare/core/widgets/buttons/app_button.dart';
import 'package:respiracare/core/widgets/cards/app_card.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';

class NurseHomePlaceholder extends ConsumerWidget {
  const NurseHomePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Espace Infirmier — RespiraCare',
          style:
              AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            tooltip: 'Se déconnecter',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                borderColor: AppColors.secondary.withValues(alpha: 0.3),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 36.0,
                      backgroundColor: Color(0xFFCCFBF1), // Soft teal
                      child: Icon(
                        Icons.medical_information_rounded,
                        size: 40.0,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      user?.name ?? 'Sarah Bennani',
                      style: AppTypography.headlineLarge,
                    ),
                    Text(
                      user?.email ?? 'nurse@respiracare.org',
                      style: AppTypography.secondaryText,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text(
                        'Rôle : ${user?.role.nameString ?? 'Infirmier(e)'}',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Espace Suivi Infirmier Actif',
                          style:
                              AppTypography.titleLarge.copyWith(fontSize: 16.0),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Vous êtes connecté en tant qu\'infirmier(e). La garde de navigation protège cet espace contre tout accès non autorisé par un rôle patient.\n\nLe tableau de bord de télésurveillance infirmière sera implémenté dans les étapes ultérieures.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Se déconnecter',
                variant: AppButtonVariant.outlined,
                icon: Icons.logout_rounded,
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
