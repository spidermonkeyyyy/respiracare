import '../models/monitoring_submission.dart';
import '../../dashboard/models/monitoring_rule.dart';

abstract class NurseMonitoringRepository {
  Future<List<MonitoringSubmission>> getMonitoringHistory(String patientId);
  Future<MonitoringSubmission?> getLatestMonitoring(String patientId);
  Future<List<RuleEvaluationResult>> evaluateSubmission(MonitoringSubmission submission);
}
