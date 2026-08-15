import 'package:flutter/material.dart';
import '../../../../mock/mock_patients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../widgets/patient_bottom_nav.dart';

class PatientProfileScreen extends ConsumerWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Patient'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              AppCard(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFFE0F2FE),
                      child: Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(user?.name ?? kPatientP1FullName, style: AppTypography.headlineLarge),
                    Text(user?.email ?? 'patient@respiracare.org', style: AppTypography.secondaryText),
                    if (user?.phone != null) ...[
                      const SizedBox(height: 4),
                      Text(user!.phone!, style: AppTypography.labelMedium),
                    ],
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
      bottomNavigationBar: PatientBottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index != 4) {
            const routes = [
              '/patient/home',
              '/patient/monitoring',
              '/patient/treatment',
              '/patient/education',
              '/patient/profile',
              '/patient/messages',
            ];
            context.go(routes[index]);
          }
        },
      ),
    );
  }
}
