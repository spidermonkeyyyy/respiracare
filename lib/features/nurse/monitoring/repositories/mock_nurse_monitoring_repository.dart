import '../../dashboard/models/monitoring_rule.dart';
import '../models/monitoring_submission.dart';
import '../models/respiratory_trend.dart';
import 'nurse_monitoring_repository.dart';

class MockNurseMonitoringRepository implements NurseMonitoringRepository {
  @override
  Future<List<MonitoringSubmission>> getMonitoringHistory(
      String patientId) async {
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
              summary:
                  'Certain monitoring information meets configured surveillance criteria.',
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
              summary:
                  'Aucun élément de surveillance prioritaire n’a été identifié.',
              priority: PriorityLevel.informational,
            ),
          ],
        ),
      ];
    }
    return [
      MonitoringSubmission(
        id: 'ms-$patientId-base',
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
  Future<List<RuleEvaluationResult>> evaluateSubmission(
      MonitoringSubmission submission) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final results = <RuleEvaluationResult>[];
    if (submission.spo2 < 90) {
      results.add(const RuleEvaluationResult(
        ruleId: 'rule-1',
        title: 'Saturation basse',
        matched: true,
        evidence: ['SpO₂ en dessous du seuil de surveillance'],
        summary:
            'Certain monitoring information meets configured surveillance criteria.',
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

  @override
  Future<List<RespiratoryTrendPoint>> getRespiratoryTrend(
    String patientId, {
    TrendTimeframe timeframe = TrendTimeframe.days14,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    // Seed a 90-day series per patient (oldest → newest).
    final seed = _seedTrend(patientId);

    final window = timeframe.window();
    return seed
        .where((point) =>
            !point.date.isBefore(window.start) && !point.date.isAfter(window.end))
        .toList();
  }

  /// Deterministic per-patient 90-day series.
  ///
  /// Patient p1 (Ahmed, high priority) shows a gradual SpO₂ decline, rising
  /// CAT/mMRC and worsening sputum — modelling gradual deterioration for the
  /// nurse to evaluate. p2/p3 are more stable.
  List<RespiratoryTrendPoint> _seedTrend(String patientId) {
    final today = DateTime.now();
    final points = <RespiratoryTrendPoint>[];

    for (var i = 90; i >= 1; i--) {
      final date =
          DateTime(today.year, today.month, today.day).subtract(Duration(days: i - 1));

      switch (patientId) {
        case 'p1':
          // SpO₂ drifts down from ~93 to ~89 over 90 days.
          final spo2 = (94 - (90 - i) ~/ 6).clamp(86, 96);
          final cat = (20 + (90 - i) ~/ 4).clamp(18, 40);
          final mmrc = (3 - (i >= 30 ? 1 : 0)).clamp(1, 4);
          final sputum = i >= 60
              ? SputumSeverity.moderate
              : (i >= 30 ? SputumSeverity.high : SputumSeverity.low);
          points.add(RespiratoryTrendPoint(
            date: date,
            spo2: spo2,
            catScore: cat,
            mmrcGrade: mmrc,
            sputum: sputum,
            hasAlert: i % 25 == 0,
          ));
          break;
        case 'p2':
          points.add(RespiratoryTrendPoint(
            date: date,
            spo2: 94,
            catScore: 14 + (i % 3),
            mmrcGrade: 2,
            sputum: SputumSeverity.low,
            hasAlert: false,
          ));
          break;
        default:
          points.add(RespiratoryTrendPoint(
            date: date,
            spo2: 96,
            catScore: 9 + (i % 2),
            mmrcGrade: 1,
            sputum: SputumSeverity.none,
            hasAlert: false,
          ));
      }
    }

    return points;
  }
}
