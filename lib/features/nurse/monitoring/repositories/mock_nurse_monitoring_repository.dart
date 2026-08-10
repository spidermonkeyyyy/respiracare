import '../../dashboard/models/monitoring_rule.dart';
import '../models/monitoring_submission.dart';
import 'nurse_monitoring_repository.dart';

class MockNurseMonitoringRepository implements NurseMonitoringRepository {
  @override
  Future<List<MonitoringSubmission>> getMonitoringHistory(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (patientId == 'p1') {
      return [
        MonitoringSubmission(
          id: 'ms-1',
          patientId: patientId,
          submittedAt: DateTime.now().subtract(const Duration(minutes: 12)),
          spo2: 89,
          dyspneaScore: 3,
          coughStatus: 'Plus importante',
          sputumStatus: 'Modification signalée',
          overallStatus: 'À surveiller',
          notes: 'Signalement de dyspnée plus marquée aujourd’hui',
          ruleResults: const [
            RuleEvaluationResult(
              ruleId: 'rule-1',
              title: 'Saturation basse',
              matched: true,
              evidence: ['SpO₂ à 89 %'],
              summary: 'Certain monitoring information meets configured surveillance criteria.',
              priority: PriorityLevel.high,
            ),
            RuleEvaluationResult(
              ruleId: 'rule-2',
              title: 'Dyspnée aggravée',
              matched: true,
              evidence: ['Dyspnée mMRC 3'],
              summary: 'Le profil respiratoire nécessite un examen infirmier.',
              priority: PriorityLevel.reviewRequired,
            ),
          ],
        ),
        MonitoringSubmission(
          id: 'ms-0',
          patientId: patientId,
          submittedAt: DateTime.now().subtract(const Duration(days: 1)),
          spo2: 93,
          dyspneaScore: 2,
          coughStatus: 'Stable',
          sputumStatus: 'Stable',
          overallStatus: 'Normal',
          notes: 'Évolution stable',
          ruleResults: const [
            RuleEvaluationResult(
              ruleId: 'rule-2',
              title: 'Dyspnée aggravée',
              matched: false,
              evidence: ['Dyspnée mMRC 2'],
              summary: 'Aucun élément de surveillance prioritaire n’a été identifié.',
              priority: PriorityLevel.informational,
            ),
          ],
        ),
      ];
    }
    return [
      MonitoringSubmission(
        id: 'ms-${patientId}-base',
        patientId: patientId,
        submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
        spo2: 94,
        dyspneaScore: 2,
        coughStatus: 'Stable',
        sputumStatus: 'Stable',
        overallStatus: 'Normal',
        notes: 'Données récentes disponibles',
      ),
    ];
  }

  @override
  Future<MonitoringSubmission?> getLatestMonitoring(String patientId) async {
    final history = await getMonitoringHistory(patientId);
    return history.isEmpty ? null : history.first;
  }

  @override
  Future<List<RuleEvaluationResult>> evaluateSubmission(MonitoringSubmission submission) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final results = <RuleEvaluationResult>[];
    if (submission.spo2 < 90) {
      results.add(const RuleEvaluationResult(
        ruleId: 'rule-1',
        title: 'Saturation basse',
        matched: true,
        evidence: ['SpO₂ en dessous du seuil de surveillance'],
        summary: 'Certain monitoring information meets configured surveillance criteria.',
        priority: PriorityLevel.high,
      ));
    }
    if (submission.dyspneaScore > 2) {
      results.add(const RuleEvaluationResult(
        ruleId: 'rule-2',
        title: 'Dyspnée aggravée',
        matched: true,
        evidence: ['Score de dyspnée plus élevé que la référence'],
        summary: 'Le profil respiratoire nécessite un examen infirmier.',
        priority: PriorityLevel.reviewRequired,
      ));
    }
    if (results.isEmpty) {
      results.add(const RuleEvaluationResult(
        ruleId: 'rule-3',
        title: 'État stable',
        matched: false,
        evidence: ['Pas de signal de surveillance prioritaire'],
        summary: 'Aucun élément de surveillance prioritaire n’a été identifié.',
        priority: PriorityLevel.informational,
      ));
    }
    return results;
  }
}
