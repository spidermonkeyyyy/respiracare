import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/models/monitoring_rule.dart';
import '../models/monitoring_submission.dart';
import '../repositories/mock_nurse_monitoring_repository.dart';
import '../repositories/nurse_monitoring_repository.dart';

class NurseMonitoringState {
  final bool isLoading;
  final String? errorMessage;
  final List<MonitoringSubmission> history;
  final MonitoringSubmission? latestSubmission;
  final List<RuleEvaluationResult> evaluationResults;

  const NurseMonitoringState({
    this.isLoading = true,
    this.errorMessage,
    this.history = const [],
    this.latestSubmission,
    this.evaluationResults = const [],
  });

  NurseMonitoringState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MonitoringSubmission>? history,
    MonitoringSubmission? latestSubmission,
    List<RuleEvaluationResult>? evaluationResults,
  }) {
    return NurseMonitoringState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      history: history ?? this.history,
      latestSubmission: latestSubmission,
      evaluationResults: evaluationResults ?? this.evaluationResults,
    );
  }
}

final nurseMonitoringRepositoryProvider = Provider<NurseMonitoringRepository>((ref) {
  return MockNurseMonitoringRepository();
});

final nurseMonitoringProvider = StateNotifierProvider<NurseMonitoringNotifier, NurseMonitoringState>((ref) {
  final repository = ref.watch(nurseMonitoringRepositoryProvider);
  return NurseMonitoringNotifier(repository);
});

class NurseMonitoringNotifier extends StateNotifier<NurseMonitoringState> {
  final NurseMonitoringRepository _repository;

  NurseMonitoringNotifier(this._repository) : super(const NurseMonitoringState());

  Future<void> loadMonitoring(String patientId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final history = await _repository.getMonitoringHistory(patientId);
      final latest = await _repository.getLatestMonitoring(patientId);
      final evaluation = await _repository.evaluateSubmission(latest ?? history.first);
      state = state.copyWith(
        isLoading: false,
        history: history,
        latestSubmission: latest,
        evaluationResults: evaluation,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger les mesures respiratoires.',
      );
    }
  }
}
