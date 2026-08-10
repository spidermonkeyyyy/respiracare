import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nurse_assessment.dart';
import '../repositories/mock_nurse_assessment_repository.dart';
import '../repositories/nurse_assessment_repository.dart';

class NurseAssessmentState {
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final List<NurseAssessment> assessments;

  const NurseAssessmentState({
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.assessments = const [],
  });

  NurseAssessmentState copyWith({
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    List<NurseAssessment>? assessments,
  }) {
    return NurseAssessmentState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
      assessments: assessments ?? this.assessments,
    );
  }
}

final nurseAssessmentRepositoryProvider = Provider<NurseAssessmentRepository>((ref) {
  return MockNurseAssessmentRepository();
});

final nurseAssessmentProvider = StateNotifierProvider<NurseAssessmentNotifier, NurseAssessmentState>((ref) {
  final repository = ref.watch(nurseAssessmentRepositoryProvider);
  return NurseAssessmentNotifier(repository);
});

class NurseAssessmentNotifier extends StateNotifier<NurseAssessmentState> {
  final NurseAssessmentRepository _repository;

  NurseAssessmentNotifier(this._repository) : super(const NurseAssessmentState());

  Future<void> saveAssessment(NurseAssessment assessment) async {
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);
    try {
      final saved = await _repository.saveAssessment(assessment);
      final updated = [...state.assessments, saved];
      state = state.copyWith(isSaving: false, assessments: updated, successMessage: 'Évaluation enregistrée.');
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Impossible d’enregistrer l’évaluation.');
    }
  }

  Future<void> loadAssessments(String patientId) async {
    try {
      final assessments = await _repository.getAssessments(patientId);
      state = state.copyWith(assessments: assessments);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Impossible de charger l’historique d’évaluation.');
    }
  }
}
