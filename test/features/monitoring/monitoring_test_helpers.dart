import 'package:respiracare/features/monitoring/models/clinical_measurement.dart';
import 'package:respiracare/features/monitoring/models/evaluation_result.dart';
import 'package:respiracare/features/monitoring/models/monitoring_question.dart';
import 'package:respiracare/features/monitoring/models/monitoring_submission.dart';
import 'package:respiracare/features/monitoring/repositories/monitoring_repository.dart';
import 'package:respiracare/features/monitoring/models/measurement_type.dart';

/// Configurable [MonitoringRepository] used to exercise provider logic in
/// isolation (no real I/O, no timers).
class FakeMonitoringRepository implements MonitoringRepository {
  FakeMonitoringRepository({
    List<ClinicalMeasurement>? measurements,
    this.throwOnHistory = false,
  }) : measurements = measurements ?? <ClinicalMeasurement>[];

  /// Data returned by [getHistoricalMeasurements].
  List<ClinicalMeasurement> measurements;

  /// When true, [getHistoricalMeasurements] throws a simulated error.
  bool throwOnHistory;

  /// Number of times [getHistoricalMeasurements] was called.
  int historyCallCount = 0;

  /// Records the last `types` set requested.
  Set<MeasurementType>? lastRequestedTypes;

  /// Records the last requested range.
  (DateTime, DateTime)? lastRange;

  /// When set, [getHistoricalMeasurements] awaits this gate before returning,
  /// letting tests hold the call in flight to observe loading states.
  Future<void>? historyGate;

  @override
  Future<List<ClinicalMeasurement>> getHistoricalMeasurements({
    required DateTime start,
    required DateTime end,
    required Set<MeasurementType> types,
  }) async {
    historyCallCount++;
    lastRequestedTypes = types;
    lastRange = (start, end);
    if (historyGate != null) await historyGate!;
    if (throwOnHistory) throw Exception('network down');
    // Yield to next microtask so tests can observe loading states.
    await Future<void>.value();
    // The fake is a provider-logic double: it honors the requested
    // measurement *types* (verified at this level) and otherwise returns
    // every stored reading regardless of the date window.  Date-range
    // filtering is the repository's responsibility and is covered by the
    // MockMonitoringRepository test suite, so the provider tests can inject
    // fixed past dates while the live range window moves with the clock.
    return measurements.where((m) => types.contains(m.type)).toList()
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
  }

  @override
  Future<List<MonitoringQuestion>> getQuestions() async =>
      <MonitoringQuestion>[];

  @override
  Future<EvaluationResult> submitMonitoring(
    MonitoringSubmission submission,
  ) async {
    return const EvaluationResult(
      status: EvaluationStatus.normal,
      patientMessage: 'ok',
    );
  }
}

/// Convenience factory for building a valid SpO₂ reading.
ClinicalMeasurement spo2Reading({
  required String id,
  required double value,
  required DateTime at,
}) {
  return ClinicalMeasurement(
    id: id,
    type: MeasurementType.spo2,
    value: value,
    unit: '%',
    measuredAt: at,
  );
}

/// Convenience factory for building a valid heart-rate reading.
ClinicalMeasurement heartRateReading({
  required String id,
  required double value,
  required DateTime at,
}) {
  return ClinicalMeasurement(
    id: id,
    type: MeasurementType.heartRate,
    value: value,
    unit: 'bpm',
    measuredAt: at,
  );
}
