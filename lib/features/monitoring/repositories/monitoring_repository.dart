import '../models/evaluation_result.dart';
import '../models/monitoring_question.dart';
import '../models/monitoring_submission.dart';

abstract class MonitoringRepository {
  Future<List<MonitoringQuestion>> getQuestions();
  Future<EvaluationResult> submitMonitoring(MonitoringSubmission submission);
}
