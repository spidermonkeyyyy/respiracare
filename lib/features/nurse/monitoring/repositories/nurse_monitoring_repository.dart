import '../models/monitoring_submission.dart';
import '../../dashboard/models/monitoring_rule.dart';
import '../models/respiratory_trend.dart';

abstract class NurseMonitoringRepository {
  Future<List<MonitoringSubmission>> getMonitoringHistory(String patientId);
  Future<MonitoringSubmission?> getLatestMonitoring(String patientId);
  Future<List<RuleEvaluationResult>> evaluateSubmission(MonitoringSubmission submission);

  /// Returns the longitudinal respiratory trend series for [patientId].
  ///
  /// Points are returned oldest → newest and filtered to the [timeframe]
  /// window. A future Supabase implementation derives these from the
  /// monitoring tables; the mock returns deterministic seeded data.
  Future<List<RespiratoryTrendPoint>> getRespiratoryTrend(
    String patientId, {
    TrendTimeframe timeframe = TrendTimeframe.days14,
  });
}

