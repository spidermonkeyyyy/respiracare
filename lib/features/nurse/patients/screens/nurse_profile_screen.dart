import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../authentication/models/app_user.dart';

class NurseProfileScreen extends ConsumerWidget {
  final AppUser? user;

  const NurseProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user?.name ?? 'Infirmière';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.headlineLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Vue clinique de supervision', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.md),
                  Text('Rôle', style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(user?.role.nameString ?? 'Infirmier(e)', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
