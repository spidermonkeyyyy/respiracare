import '../models/clinical_measurement.dart';
import '../models/evaluation_result.dart';
import '../models/monitoring_question.dart';
import '../models/measurement_type.dart';
import '../models/monitoring_submission.dart';

/// Contract for monitoring data access.
///
/// The historical-queries method is intentionally abstract so the UI never
/// talks to Supabase directly.  A future Step will provide the real Supabase
/// implementation behind this same contract.
abstract class MonitoringRepository {
  /// Returns the daily monitoring questionnaire.
  Future<List<MonitoringQuestion>> getQuestions();

  /// Evaluates a submitted monitoring session.
  Future<EvaluationResult> submitMonitoring(MonitoringSubmission submission);

  /// Returns historical physiological measurements within [start, end]
  /// (inclusive) for the requested [types].
  ///
  /// The result is sorted oldest→newest.  Invalid or zero-length ranges
  /// return an empty list (never throws for filtering reasons).
  ///
  /// Implementations should request only the range actually needed by the
  /// calling screen to avoid loading unnecessary data.
  Future<List<ClinicalMeasurement>> getHistoricalMeasurements({
    required DateTime start,
    required DateTime end,
    required Set<MeasurementType> types,
  });
}
