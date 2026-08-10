import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patient_dashboard_data.dart';
import '../repositories/mock_patient_dashboard_repository.dart';
import '../repositories/patient_dashboard_repository.dart';

class PatientDashboardState {
  final bool isLoading;
  final bool isOffline;
  final bool isEmpty;
  final String? errorMessage;
  final PatientDashboardData? data;

  const PatientDashboardState({
    this.isLoading = true,
    this.isOffline = false,
    this.isEmpty = false,
    this.errorMessage,
    this.data,
  });

  PatientDashboardState copyWith({
    bool? isLoading,
    bool? isOffline,
    bool? isEmpty,
    String? errorMessage,
    PatientDashboardData? data,
  }) {
    return PatientDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isOffline: isOffline ?? this.isOffline,
      isEmpty: isEmpty ?? this.isEmpty,
      errorMessage: errorMessage,
      data: data ?? this.data,
    );
  }
}

final patientDashboardRepositoryProvider = Provider<PatientDashboardRepository>((ref) {
  return MockPatientDashboardRepository();
});

final patientDashboardProvider =
    StateNotifierProvider<PatientDashboardNotifier, PatientDashboardState>((ref) {
  final repository = ref.watch(patientDashboardRepositoryProvider);
  return PatientDashboardNotifier(repository);
});

class PatientDashboardNotifier extends StateNotifier<PatientDashboardState> {
  final PatientDashboardRepository _repository;
  bool _disposed = false;

  PatientDashboardNotifier(this._repository)
      : super(const PatientDashboardState(isLoading: true)) {
    loadDashboard();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadDashboard({bool forceEmpty = false, bool forceError = false}) async {
    if (_disposed) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (forceError) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (_disposed) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger votre suivi. Vérifiez votre connexion puis réessayez.',
      );
      return;
    }

    if (forceEmpty) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (_disposed) return;
      state = state.copyWith(
        isLoading: false,
        isEmpty: true,
        data: null,
      );
      return;
    }

    try {
      final data = await _repository.getDashboardData();
      if (_disposed) return;
      state = state.copyWith(
        isLoading: false,
        isEmpty: false,
        data: data,
        errorMessage: null,
      );
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Une erreur s'est produite lors du chargement de vos données.",
      );
    }
  }

  void toggleOfflineMode() {
    if (_disposed) return;
    state = state.copyWith(isOffline: !state.isOffline);
  }

  Future<void> completeQuestionnaire() async {
    await _repository.completeDailyQuestionnaire();
    await loadDashboard();
  }

  Future<void> confirmMedication() async {
    await _repository.confirmMedication();
    await loadDashboard();
  }
}