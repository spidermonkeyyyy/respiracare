import 'package:flutter/material.dart';
import '../../../mock/mock_patients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';

class PatientHomePlaceholder extends ConsumerWidget {
  const PatientHomePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Espace Patient — Sanad',
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
                borderColor: AppColors.primary.withValues(alpha: 0.3),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 36.0,
                      backgroundColor: Color(0xFFE0F2FE),
                      child: Icon(
                        Icons.person_rounded,
                        size: 40.0,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      user?.name ?? kPatientP1FullName,
                      style: AppTypography.headlineLarge,
                    ),
                    Text(
                      user?.email ?? 'patient@respiracare.org',
                      style: AppTypography.secondaryText,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text(
                        'Rôle : ${user?.role.nameString ?? 'Patient'}',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
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
                          Icons.check_circle_outline_rounded,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Authentification Réussie !',
                          style:
                              AppTypography.titleLarge.copyWith(fontSize: 16.0),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Vous êtes connecté avec un compte Patient. La navigation sécurisée par rôle fonctionne correctement.\n\nLe tableau de bord complet pour patient sera implémenté dans l\'étape 5.',
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
