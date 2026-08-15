import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/respiratory_trend.dart';
import '../repositories/nurse_monitoring_repository.dart';
import 'nurse_monitoring_provider.dart';

/// State for the respiratory evolution charts (SCR-NUR-06).
class NurseTrendState {
  final bool isLoading;
  final String? errorMessage;
  final String? patientId;
  final TrendTimeframe timeframe;
  final List<RespiratoryTrendPoint> points;

  const NurseTrendState({
    this.isLoading = true,
    this.errorMessage,
    this.patientId,
    this.timeframe = TrendTimeframe.days14,
    this.points = const [],
  });

  NurseTrendState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? patientId,
    TrendTimeframe? timeframe,
    List<RespiratoryTrendPoint>? points,
  }) {
    return NurseTrendState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      patientId: patientId ?? this.patientId,
      timeframe: timeframe ?? this.timeframe,
      points: points ?? this.points,
    );
  }
}

final nurseTrendProvider =
    StateNotifierProvider<NurseTrendNotifier, NurseTrendState>((ref) {
  return NurseTrendNotifier(ref.watch(nurseMonitoringRepositoryProvider));
});

class NurseTrendNotifier extends StateNotifier<NurseTrendState> {
  final NurseMonitoringRepository _repository;

  NurseTrendNotifier(this._repository) : super(const NurseTrendState());

  /// Loads the trend series for [patientId] using the current timeframe.
  Future<void> load(String patientId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      patientId: patientId,
    );
    try {
      final points = await _repository.getRespiratoryTrend(
        patientId,
        timeframe: state.timeframe,
      );
      state = state.copyWith(isLoading: false, points: points);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger les tendances respiratoires.',
      );
    }
  }

  /// Switches the displayed window and re-fetches for the current patient.
  Future<void> setTimeframe(TrendTimeframe timeframe) async {
    if (timeframe == state.timeframe) return;
    state = state.copyWith(timeframe: timeframe);
    final patientId = state.patientId;
    if (patientId != null) {
      await load(patientId);
    }
  }
}
