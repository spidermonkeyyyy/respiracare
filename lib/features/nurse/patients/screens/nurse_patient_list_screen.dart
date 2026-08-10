import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../providers/nurse_patients_provider.dart';
import '../widgets/patient_card.dart';

class NursePatientListScreen extends ConsumerWidget {
  const NursePatientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nursePatientsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patients'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
                ? AppErrorState(
                    title: 'Impossible de charger la liste des patients',
                    message: state.errorMessage!,
                    retryLabel: 'Réessayer',
                    onRetry: () =>
                        ref.read(nursePatientsProvider.notifier).loadPatients(),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Rechercher un patient',
                            prefixIcon: const Icon(Icons.search_rounded),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.medium)),
                            filled: true,
                            fillColor: AppColors.surface,
                          ),
                          onChanged: (value) => ref
                              .read(nursePatientsProvider.notifier)
                              .searchPatients(value),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        child: Row(
                          children: [
                            _FilterChip(label: 'Tous', isSelected: true),
                            const SizedBox(width: AppSpacing.sm),
                            _FilterChip(label: 'À revoir'),
                            const SizedBox(width: AppSpacing.sm),
                            _FilterChip(label: 'Suivis'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: state.patients.isEmpty
                            ? const AppEmptyState(
                                title: 'Aucun patient trouvé',
                                message: 'Essayez une autre recherche.',
                                icon: Icons.people_outline_rounded,
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.md,
                                    0,
                                    AppSpacing.md,
                                    AppSpacing.lg),
                                itemCount: state.patients.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, index) {
                                  final patient = state.patients[index];
                                  return PatientCard(
                                    patient: patient,
                                    onTap: () => context
                                        .push('/nurse/patients/${patient.id}'),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {},
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      labelStyle: AppTypography.labelMedium.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textSecondary),
    );
  }
}
