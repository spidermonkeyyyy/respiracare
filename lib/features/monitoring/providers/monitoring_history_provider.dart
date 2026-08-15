import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clinical_measurement.dart';
import '../models/measurement_type.dart';
import '../repositories/monitoring_repository.dart';
import '../utils/clinical_time_range.dart';
import '../utils/clinical_trend_calculator.dart';
import 'monitoring_provider.dart' show monitoringRepositoryProvider;

// ─── State ───────────────────────────────────────────────────────

class MonitoringHistoryState {
  final bool isLoading;
  final bool isRefreshing;
  final Object? error;
  final Set<MeasurementType> selectedTypes;
  final ClinicalTimeRange selectedRange;
  final List<ClinicalMeasurement> measurements;

  const MonitoringHistoryState({
    this.isLoading = true,
    this.isRefreshing = false,
    this.error,
    this.selectedTypes = const {MeasurementType.spo2},
    this.selectedRange = ClinicalTimeRange.days7,
    this.measurements = const [],
  });

  MonitoringHistoryState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Object? error,
    bool clearError = false,
    Set<MeasurementType>? selectedTypes,
    ClinicalTimeRange? selectedRange,
    List<ClinicalMeasurement>? measurements,
  }) {
    return MonitoringHistoryState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      selectedTypes: selectedTypes ?? this.selectedTypes,
      selectedRange: selectedRange ?? this.selectedRange,
      measurements: measurements ?? this.measurements,
    );
  }

  bool get hasError => error != null;

  /// Convenience: measurements for [type] only, sorted oldest→newest.
  List<ClinicalMeasurement> measurementsFor(MeasurementType type) {
    return measurements.where((m) => m.type == type && m.isValid).toList()
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
  }

  /// Latest measurement for a type, or null if none exist.
  ClinicalMeasurement? latestFor(MeasurementType type) {
    final list = measurementsFor(type);
    return list.isEmpty ? null : list.last;
  }

  /// Trend summary for a type (delegates to the pure calculator).
  TrendSummary trendFor(MeasurementType type) {
    return ClinicalTrendCalculator.calculate(
      measurementsFor(type),
      type,
    );
  }

  @override
  String toString() {
    return 'MonitoringHistoryState(isLoading: $isLoading, isRefreshing: $isRefreshing, '
        'hasError: $hasError, selectedTypes: $selectedTypes, '
        'selectedRange: $selectedRange, measurementCount: ${measurements.length})';
  }
}

// ─── Notifier ────────────────────────────────────────────────────

class MonitoringHistoryNotifier extends StateNotifier<MonitoringHistoryState> {
  final MonitoringRepository _repository;

  MonitoringHistoryNotifier(this._repository)
      : super(const MonitoringHistoryState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final range = state.selectedRange;
      final dateTimeRange = range.toDateTimeRange();
      final result = await _repository.getHistoricalMeasurements(
        start: dateTimeRange.start,
        end: dateTimeRange.end,
        types: state.selectedTypes,
      );
      state = state.copyWith(isLoading: false, measurements: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      final range = state.selectedRange;
      final dateTimeRange = range.toDateTimeRange();
      final result = await _repository.getHistoricalMeasurements(
        start: dateTimeRange.start,
        end: dateTimeRange.end,
        types: state.selectedTypes,
      );
      state = state.copyWith(
        isRefreshing: false,
        isLoading: false,
        measurements: result,
      );
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e);
    }
  }

  /// Changes the active time range and reloads data.
  Future<void> changeRange(ClinicalTimeRange newRange) async {
    if (newRange == state.selectedRange) return;
    state = state.copyWith(selectedRange: newRange);
    await _load();
  }

  /// Toggles a measurement type and reloads data.
  Future<void> toggleType(MeasurementType type) async {
    final current = Set<MeasurementType>.from(state.selectedTypes);
    if (current.contains(type)) {
      current.remove(type);
    } else {
      current.add(type);
    }
    // Always keep at least one type selected.
    if (current.isEmpty) {
      current.add(MeasurementType.spo2);
    }
    state = state.copyWith(selectedTypes: current);
    await _load();
  }
}

// ─── Provider ────────────────────────────────────────────────────

/// Provides the clinical-history view state.  Depends on the shared
/// [monitoringRepositoryProvider] so tests override a single repository.
final monitoringHistoryProvider =
    StateNotifierProvider<MonitoringHistoryNotifier, MonitoringHistoryState>(
  (ref) {
    final repository = ref.watch(monitoringRepositoryProvider);
    return MonitoringHistoryNotifier(repository);
  },
);
