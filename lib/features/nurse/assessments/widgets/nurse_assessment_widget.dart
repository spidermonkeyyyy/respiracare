import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/inputs/app_input.dart';
import '../models/nurse_assessment.dart';

class NurseAssessmentWidget extends StatefulWidget {
  final String patientId;
  final ValueChanged<NurseAssessment>? onSaved;
  final bool loading;

  const NurseAssessmentWidget(
      {super.key, required this.patientId, this.onSaved, this.loading = false});

  @override
  State<NurseAssessmentWidget> createState() => _NurseAssessmentWidgetState();
}

class _NurseAssessmentWidgetState extends State<NurseAssessmentWidget> {
  AssessmentStatus _selectedStatus = AssessmentStatus.enhancedMonitoring;
  final _observationController = TextEditingController();
  final _actionController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _observationController.dispose();
    _actionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Évaluation infirmière', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Text('Évaluation',
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: AssessmentStatus.values.map((status) {
              final selected = _selectedStatus == status;
              return ChoiceChip(
                label: Text(status.label),
                selected: selected,
                onSelected: (_) => setState(() => _selectedStatus = status),
                selectedColor: AppColors.primary.withValues(alpha: 0.14),
                labelStyle: AppTypography.bodyMedium.copyWith(
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppInput(
              controller: _observationController,
              label: 'Observation',
              hint: 'Notes cliniques de synthèse',
              maxLines: 3),
          const SizedBox(height: AppSpacing.md),
          AppInput(
              controller: _actionController,
              label: 'Action réalisée',
              hint: 'Surveillance renforcée, contact patient...',
              maxLines: 2),
          const SizedBox(height: AppSpacing.md),
          AppInput(
              controller: _noteController,
              label: 'Commentaire complémentaire',
              hint: 'Renseigner si nécessaire',
              maxLines: 2),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            text: 'Enregistrer l’évaluation',
            icon: Icons.save_rounded,
            loading: widget.loading,
            fullWidth: true,
            onPressed: () {
              final assessment = NurseAssessment(
                id: 'assessment-${DateTime.now().millisecondsSinceEpoch}',
                patientId: widget.patientId,
                status: _selectedStatus,
                observation: _observationController.text.trim(),
                action: _actionController.text.trim(),
                note: _noteController.text.trim().isEmpty
                    ? null
                    : _noteController.text.trim(),
                createdAt: DateTime.now(),
              );
              widget.onSaved?.call(assessment);
            },
          ),
        ],
      ),
    );
  }
}
