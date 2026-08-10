import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/escalation_request.dart';
import '../repositories/mock_nurse_escalation_repository.dart';
import '../repositories/nurse_escalation_repository.dart';

class NurseEscalationState {
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  const NurseEscalationState({
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  NurseEscalationState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
  }) {
    return NurseEscalationState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

final nurseEscalationRepositoryProvider = Provider<NurseEscalationRepository>((ref) {
  return MockNurseEscalationRepository();
});

final nurseEscalationProvider = StateNotifierProvider<NurseEscalationNotifier, NurseEscalationState>((ref) {
  final repository = ref.watch(nurseEscalationRepositoryProvider);
  return NurseEscalationNotifier(repository);
});

class NurseEscalationNotifier extends StateNotifier<NurseEscalationState> {
  final NurseEscalationRepository _repository;

  NurseEscalationNotifier(this._repository) : super(const NurseEscalationState());

  Future<void> submitEscalation(EscalationRequest request) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null);
    try {
      await _repository.submitEscalation(request);
      state = state.copyWith(isSubmitting: false, successMessage: 'Demande transmise.');
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Impossible de transmettre l’élévation de cas.');
    }
  }
}
