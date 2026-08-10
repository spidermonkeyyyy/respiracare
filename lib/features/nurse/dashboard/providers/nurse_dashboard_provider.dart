import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../patients/models/nurse_patient.dart';
import '../models/dashboard_summary.dart';
import '../models/monitoring_rule.dart';
import '../../monitoring/models/monitoring_submission.dart';
import '../repositories/mock_nurse_dashboard_repository.dart';
import '../repositories/nurse_dashboard_repository.dart';

class NurseDashboardState {
  final bool isLoading;
  final String? errorMessage;
  final DashboardSummary? summary;
  final List<NursePatient> priorityQueue;
  final List<MonitoringSubmission> recentSubmissions;
  final List<MonitoringRule> monitoringRules;

  const NurseDashboardState({
    this.isLoading = true,
    this.errorMessage,
    this.summary,
    this.priorityQueue = const [],
    this.recentSubmissions = const [],
    this.monitoringRules = const [],
  });

  NurseDashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    DashboardSummary? summary,
    List<NursePatient>? priorityQueue,
    List<MonitoringSubmission>? recentSubmissions,
    List<MonitoringRule>? monitoringRules,
  }) {
    return NurseDashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      summary: summary ?? this.summary,
      priorityQueue: priorityQueue ?? this.priorityQueue,
      recentSubmissions: recentSubmissions ?? this.recentSubmissions,
      monitoringRules: monitoringRules ?? this.monitoringRules,
    );
  }
}

final nurseDashboardRepositoryProvider = Provider<NurseDashboardRepository>((ref) {
  return MockNurseDashboardRepository();
});

final nurseDashboardProvider = StateNotifierProvider<NurseDashboardNotifier, NurseDashboardState>((ref) {
  final repository = ref.watch(nurseDashboardRepositoryProvider);
  return NurseDashboardNotifier(repository);
});

class NurseDashboardNotifier extends StateNotifier<NurseDashboardState> {
  final NurseDashboardRepository _repository;

  NurseDashboardNotifier(this._repository) : super(const NurseDashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summary = await _repository.getDashboardSummary();
      final priorityQueue = await _repository.getPriorityQueue();
      final recentSubmissions = await _repository.getRecentSubmissions();
      final monitoringRules = await _repository.getMonitoringRules();
      state = state.copyWith(
        isLoading: false,
        summary: summary,
        priorityQueue: priorityQueue,
        recentSubmissions: recentSubmissions,
        monitoringRules: monitoringRules,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger le tableau de bord infirmier.',
      );
    }
  }
}
