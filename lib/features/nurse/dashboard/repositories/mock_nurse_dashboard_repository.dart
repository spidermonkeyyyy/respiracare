import '../../patients/models/nurse_patient.dart';
import '../models/dashboard_summary.dart';
import '../models/monitoring_rule.dart';
import '../../monitoring/models/monitoring_submission.dart';
import 'nurse_dashboard_repository.dart';

class MockNurseDashboardRepository implements NurseDashboardRepository {
  @override
  Future<DashboardSummary> getDashboardSummary() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const DashboardSummary(
      totalPatients: 24,
      highPriorityCount: 3,
      reviewRequiredCount: 5,
      newSubmissionsCount: 7,
    );
  }

  @override
  Future<List<NursePatient>> getPriorityQueue() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      const NursePatient(
        id: 'p1',
        fullName: 'Ahmed Ben Ali',
        condition: 'BPCO',
        classification: 'GOLD III',
        lastSubmissionAt: null,
        priority: PriorityLevel.high,
        hasNewSubmission: true,
        adherence: null,
        latestObservation: 'SpO₂ à 89 %',
      ),
      const NursePatient(
        id: 'p2',
        fullName: 'Mariem K.',
        condition: 'BPCO',
        classification: 'GOLD II',
        lastSubmissionAt: null,
        priority: PriorityLevel.reviewRequired,
        hasNewSubmission: true,
        adherence: null,
        latestObservation: 'Nouvelles données respiratoires',
      ),
      const NursePatient(
        id: 'p3',
        fullName: 'Sami R.',
        condition: 'IRC',
        classification: 'Suivi stable',
        lastSubmissionAt: null,
        priority: PriorityLevel.informational,
        hasNewSubmission: false,
        adherence: null,
        latestObservation: 'Traitement confirmé hier',
      ),
    ];
  }

  @override
  Future<List<MonitoringSubmission>> getRecentSubmissions({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      MonitoringSubmission(
        id: 'ms-1',
        patientId: 'p1',
        submittedAt: DateTime.now().subtract(const Duration(minutes: 12)),
        spo2: 89,
        dyspneaScore: 3,
        coughStatus: 'Plus importante',
        sputumStatus: 'Modification signalée',
        overallStatus: 'À surveiller',
        notes: 'Suivi respiratoire reçu aujourd’hui',
      ),
      MonitoringSubmission(
        id: 'ms-2',
        patientId: 'p2',
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        spo2: 93,
        dyspneaScore: 2,
        coughStatus: 'Stable',
        sputumStatus: 'Stable',
        overallStatus: 'Normal',
        notes: 'Nouvelles données de suivi',
      ),
    ];
  }

  @override
  Future<List<MonitoringRule>> getMonitoringRules() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      const MonitoringRule(
        id: 'rule-1',
        title: 'Saturation basse',
        description: 'Vérifier les valeurs de saturation en oxygène et la stabilité clinique.',
        condition: RuleCondition(field: 'spo2', operator: '<', value: '90', description: 'Saturation inférieure au seuil de surveillance.'),
        action: RuleAction(type: RuleActionType.nurseReview, label: 'Revue infirmière', priority: PriorityLevel.high),
      ),
      const MonitoringRule(
        id: 'rule-2',
        title: 'Dyspnée aggravée',
        description: 'Revoir l’évolution de la dyspnée par rapport à la référence du patient.',
        condition: RuleCondition(field: 'dyspneaScore', operator: '>', value: '2', description: 'Score de dyspnée plus élevé que la référence.'),
        action: RuleAction(type: RuleActionType.patientContact, label: 'Contact patient', priority: PriorityLevel.reviewRequired),
      ),
    ];
  }
}
