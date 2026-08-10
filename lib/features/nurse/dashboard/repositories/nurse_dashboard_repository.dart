import '../../patients/models/nurse_patient.dart';
import '../models/dashboard_summary.dart';
import '../models/monitoring_rule.dart';
import '../../monitoring/models/monitoring_submission.dart';

abstract class NurseDashboardRepository {
  Future<DashboardSummary> getDashboardSummary();
  Future<List<NursePatient>> getPriorityQueue();
  Future<List<MonitoringSubmission>> getRecentSubmissions({int limit = 5});
  Future<List<MonitoringRule>> getMonitoringRules();
}
