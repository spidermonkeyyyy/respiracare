import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nurse_patient.dart';
import '../repositories/mock_nurse_patient_repository.dart';
import '../repositories/nurse_patient_repository.dart';

class NursePatientsState {
  final bool isLoading;
  final String? errorMessage;
  final List<NursePatient> patients;
  final String searchQuery;
  final NursePatient? selectedPatient;

  const NursePatientsState({
    this.isLoading = true,
    this.errorMessage,
    this.patients = const [],
    this.searchQuery = '',
    this.selectedPatient,
  });

  NursePatientsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<NursePatient>? patients,
    String? searchQuery,
    NursePatient? selectedPatient,
  }) {
    return NursePatientsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      patients: patients ?? this.patients,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPatient: selectedPatient,
    );
  }
}

final nursePatientRepositoryProvider = Provider<NursePatientRepository>((ref) {
  return MockNursePatientRepository();
});

final nursePatientsProvider = StateNotifierProvider<NursePatientsNotifier, NursePatientsState>((ref) {
  final repository = ref.watch(nursePatientRepositoryProvider);
  return NursePatientsNotifier(repository);
});

class NursePatientsNotifier extends StateNotifier<NursePatientsState> {
  final NursePatientRepository _repository;

  NursePatientsNotifier(this._repository) : super(const NursePatientsState()) {
    loadPatients();
  }

  Future<void> loadPatients() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final patients = await _repository.getPatients();
      state = state.copyWith(isLoading: false, patients: patients);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger la liste des patients.',
      );
    }
  }

  Future<void> searchPatients(String query) async {
    state = state.copyWith(isLoading: true, errorMessage: null, searchQuery: query);
    try {
      final patients = await _repository.searchPatients(query);
      state = state.copyWith(isLoading: false, patients: patients);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de filtrer les patients.',
      );
    }
  }

  Future<void> selectPatient(String patientId) async {
    try {
      final patient = await _repository.getPatient(patientId);
      state = state.copyWith(selectedPatient: patient);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Impossible d’ouvrir le profil du patient.');
    }
  }
}
