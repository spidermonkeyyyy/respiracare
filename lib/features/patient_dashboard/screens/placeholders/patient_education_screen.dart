import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/cards/app_card.dart';

class PatientEducationScreen extends StatelessWidget {
  const PatientEducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Centre d\'Éducation'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school_outlined, size: 48, color: AppColors.primary),
                SizedBox(height: AppSpacing.md),
                Text('Centre Éducatif', style: AppTypography.headlineLarge),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Écran de démonstration pour les vidéos explicatives et guides BPCO.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
