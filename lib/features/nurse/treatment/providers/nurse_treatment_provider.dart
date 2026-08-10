import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/treatment_adherence.dart';
import '../repositories/mock_nurse_treatment_repository.dart';
import '../repositories/nurse_treatment_repository.dart';

class NurseTreatmentState {
  final bool isLoading;
  final String? errorMessage;
  final TreatmentAdherence? adherence;

  const NurseTreatmentState({
    this.isLoading = true,
    this.errorMessage,
    this.adherence,
  });

  NurseTreatmentState copyWith({
    bool? isLoading,
    String? errorMessage,
    TreatmentAdherence? adherence,
  }) {
    return NurseTreatmentState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      adherence: adherence,
    );
  }
}

final nurseTreatmentRepositoryProvider = Provider<NurseTreatmentRepository>((ref) {
  return MockNurseTreatmentRepository();
});

final nurseTreatmentProvider = StateNotifierProvider<NurseTreatmentNotifier, NurseTreatmentState>((ref) {
  final repository = ref.watch(nurseTreatmentRepositoryProvider);
  return NurseTreatmentNotifier(repository);
});

class NurseTreatmentNotifier extends StateNotifier<NurseTreatmentState> {
  final NurseTreatmentRepository _repository;

  NurseTreatmentNotifier(this._repository) : super(const NurseTreatmentState());

  Future<void> loadAdherence(String patientId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final adherence = await _repository.getAdherence(patientId);
      state = state.copyWith(isLoading: false, adherence: adherence);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Impossible de charger l’observance thérapeutique.');
    }
  }
}
