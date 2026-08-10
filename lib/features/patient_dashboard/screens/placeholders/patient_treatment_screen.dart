import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/cards/app_card.dart';

class PatientTreatmentScreen extends StatelessWidget {
  const PatientTreatmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Traitement & Inhalateurs'),
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
                Icon(Icons.medication_outlined, size: 48, color: AppColors.secondary),
                SizedBox(height: AppSpacing.md),
                Text('Espace Traitement', style: AppTypography.headlineLarge),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Écran de démonstration pour la gestion des rappels et fiches médicaments.',
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
