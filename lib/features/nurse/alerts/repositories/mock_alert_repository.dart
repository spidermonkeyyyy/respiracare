import '../models/alert.dart';
import '../models/alert_priority.dart';
import '../models/alert_status.dart';
import '../models/rule_evaluation.dart';
import '../models/supporting_measurement.dart';
import 'alert_repository.dart';

/// In-memory [AlertRepository] used until the backend exists.
///
/// IMPORTANT — the values below are FICTITIOUS DEMONSTRATION DATA. They exist
/// to exercise the interface and are not clinically validated thresholds or
/// real patient records. The authoritative evaluation will be performed by the
/// backend rules engine.
///
/// State is held in a mutable list so lifecycle transitions persist for the
/// lifetime of the session, which is what lets the UI demonstrate a full
/// unread -> acknowledged -> inProgress -> resolved flow.
class MockAlertRepository implements AlertRepository {
  MockAlertRepository() {
    _alerts = _seed();
  }

  late List<Alert> _alerts;

  static const Duration _latency = Duration(milliseconds: 280);

  List<Alert> _seed() {
    final now = DateTime.now();

    return [
      Alert(
        id: 'alert_001',
        patientId: 'p1',
        patientName: 'Ahmed B.',
        patientSummary: 'BPCO · GOLD III',
        reason: 'Données respiratoires à revoir',
        priority: AlertPriority.high,
        status: AlertStatus.unread,
        createdAt: now.subtract(const Duration(minutes: 12)),
        submissionId: 'ms-1',
        triggeredRules: [
          RuleEvaluationResult(
            ruleId: 'rule_001',
            ruleName: 'Aggravation respiratoire',
            matched: true,
            matchedCriteria: const [
              'Variation de la dyspnée',
              'Modification des expectorations',
            ],
            priority: AlertPriority.high,
            evaluatedAt: now.subtract(const Duration(minutes: 12)),
          ),
        ],
        supportingMeasurements: const [
          SupportingMeasurement(
            label: 'SpO₂',
            value: '91 %',
            referenceValue: '95 %',
            variation: '-4 points',
            trend: MeasurementTrend.down,
          ),
          SupportingMeasurement(
            label: 'Dyspnée',
            value: 'mMRC 3',
            referenceValue: 'mMRC 2',
            variation: '+1',
            trend: MeasurementTrend.up,
          ),
          SupportingMeasurement(
            label: 'Expectorations',
            value: 'Modification signalée',
            trend: MeasurementTrend.unknown,
            note: 'Signalée par le patient dans le suivi du jour',
          ),
        ],
      ),
      Alert(
        id: 'alert_002',
        patientId: 'p1',
        patientName: 'Ahmed B.',
        patientSummary: 'BPCO · GOLD III',
        reason: 'Suivi du traitement à vérifier',
        priority: AlertPriority.medium,
        status: AlertStatus.unread,
        createdAt: now.subtract(const Duration(minutes: 26)),
        submissionId: 'ms-1',
        triggeredRules: [
          RuleEvaluationResult(
            ruleId: 'rule_003',
            ruleName: 'Suivi de traitement incomplet',
            matched: true,
            matchedCriteria: const ['Prises confirmées inférieures au seuil configuré'],
            priority: AlertPriority.medium,
            evaluatedAt: now.subtract(const Duration(minutes: 26)),
          ),
        ],
        supportingMeasurements: const [
          SupportingMeasurement(
            label: 'Prises confirmées',
            value: '72 %',
            referenceValue: '90 %',
            variation: '-18 points',
            trend: MeasurementTrend.down,
          ),
        ],
      ),
      Alert(
        id: 'alert_003',
        patientId: 'p2',
        patientName: 'Mariem K.',
        patientSummary: 'BPCO · GOLD II',
        reason: 'Nouvelle variation signalée',
        priority: AlertPriority.medium,
        status: AlertStatus.acknowledged,
        createdAt: now.subtract(const Duration(minutes: 32)),
        acknowledgedAt: now.subtract(const Duration(minutes: 8)),
        assignedNurseId: 'nurse_001',
        submissionId: 'ms-2',
        triggeredRules: [
          RuleEvaluationResult(
            ruleId: 'rule_002',
            ruleName: 'Variation des symptômes',
            matched: true,
            matchedCriteria: const ['Variation de la toux par rapport à la référence'],
            priority: AlertPriority.medium,
            evaluatedAt: now.subtract(const Duration(minutes: 32)),
          ),
        ],
        supportingMeasurements: const [
          SupportingMeasurement(
            label: 'Toux',
            value: 'Plus importante',
            referenceValue: 'Stable',
            trend: MeasurementTrend.up,
          ),
          SupportingMeasurement(
            label: 'SpO₂',
            value: '93 %',
            referenceValue: '94 %',
            variation: '-1 point',
            trend: MeasurementTrend.down,
          ),
        ],
      ),
      Alert(
        id: 'alert_004',
        patientId: 'p3',
        patientName: 'Sami R.',
        patientSummary: 'IRC · Suivi stable',
        reason: 'Suivi quotidien non transmis',
        priority: AlertPriority.low,
        status: AlertStatus.inProgress,
        createdAt: now.subtract(const Duration(hours: 6)),
        acknowledgedAt: now.subtract(const Duration(hours: 5)),
        assignedNurseId: 'nurse_001',
        nurseAction: NurseAction.contactPatient,
        nurseDecision: NurseDecision.enhancedMonitoring,
        actionNote: 'Message laissé au patient, rappel prévu demain.',
        triggeredRules: [
          RuleEvaluationResult(
            ruleId: 'rule_004',
            ruleName: 'Suivi incomplet',
            matched: true,
            matchedCriteria: const ['Aucun suivi reçu sur la période configurée'],
            priority: AlertPriority.low,
            evaluatedAt: now.subtract(const Duration(hours: 6)),
          ),
        ],
        supportingMeasurements: const [
          SupportingMeasurement(
            label: 'Dernier suivi',
            value: 'Il y a 2 jours',
            referenceValue: 'Quotidien',
            trend: MeasurementTrend.unknown,
          ),
        ],
      ),
      Alert(
        id: 'alert_005',
        patientId: 'p2',
        patientName: 'Mariem K.',
        patientSummary: 'BPCO · GOLD II',
        reason: 'Données respiratoires à revoir',
        priority: AlertPriority.medium,
        status: AlertStatus.resolved,
        createdAt: now.subtract(const Duration(days: 2)),
        acknowledgedAt: now.subtract(const Duration(days: 2, hours: -1)),
        resolvedAt: now.subtract(const Duration(days: 1, hours: 20)),
        assignedNurseId: 'nurse_001',
        nurseAction: NurseAction.monitoring,
        nurseDecision: NurseDecision.notConcerning,
        justification: 'Valeurs revenues à la référence habituelle du patient au contrôle suivant.',
        resolutionNote: 'Surveillance poursuivie selon le protocole habituel.',
        triggeredRules: [
          RuleEvaluationResult(
            ruleId: 'rule_001',
            ruleName: 'Aggravation respiratoire',
            matched: true,
            matchedCriteria: const ['Variation de la saturation'],
            priority: AlertPriority.medium,
            evaluatedAt: now.subtract(const Duration(days: 2)),
          ),
        ],
        supportingMeasurements: const [
          SupportingMeasurement(
            label: 'SpO₂',
            value: '92 %',
            referenceValue: '95 %',
            variation: '-3 points',
            trend: MeasurementTrend.down,
          ),
        ],
      ),
    ];
  }

  int _indexOf(String alertId) {
    final index = _alerts.indexWhere((alert) => alert.id == alertId);
    if (index == -1) {
      throw StateError('Alerte introuvable: $alertId');
    }
    return index;
  }

  @override
  Future<List<Alert>> getAlerts() async {
    await Future<void>.delayed(_latency);
    return List<Alert>.unmodifiable(_alerts);
  }

  @override
  Future<List<Alert>> getPatientAlerts(String patientId) async {
    await Future<void>.delayed(_latency);
    return _alerts.where((alert) => alert.patientId == patientId).toList();
  }

  @override
  Future<Alert?> getAlertById(String alertId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    for (final alert in _alerts) {
      if (alert.id == alertId) return alert;
    }
    return null;
  }

  @override
  Future<List<Alert>> getAlertsByStatus(AlertStatus status) async {
    await Future<void>.delayed(_latency);
    return _alerts.where((alert) => alert.status == status).toList();
  }

  @override
  Future<List<Alert>> getAlertsByPriority(AlertPriority priority) async {
    await Future<void>.delayed(_latency);
    return _alerts.where((alert) => alert.priority == priority).toList();
  }

  @override
  Future<Alert> acknowledgeAlert(String alertId, String nurseId) async {
    await Future<void>.delayed(_latency);
    final index = _indexOf(alertId);
    final current = _alerts[index];

    if (current.status != AlertStatus.unread) {
      return current;
    }

    final updated = current.copyWith(
      status: AlertStatus.acknowledged,
      acknowledgedAt: DateTime.now(),
      assignedNurseId: nurseId,
    );
    _alerts[index] = updated;
    return updated;
  }

  @override
  Future<Alert> recordAction(
    String alertId, {
    required NurseAction action,
    required NurseDecision decision,
    String? actionNote,
    String? justification,
  }) async {
    await Future<void>.delayed(_latency);
    final index = _indexOf(alertId);
    final current = _alerts[index];

    if (current.status == AlertStatus.unread) {
      throw StateError('L\'alerte doit être prise en charge avant d\'enregistrer une action.');
    }
    if (decision.requiresJustification && (justification == null || justification.trim().isEmpty)) {
      throw StateError('Une justification est requise pour cette décision.');
    }
    if (action.requiresNote && (actionNote == null || actionNote.trim().isEmpty)) {
      throw StateError('Un commentaire est requis pour l\'action choisie.');
    }

    final updated = current.copyWith(
      status: AlertStatus.inProgress,
      nurseAction: action,
      nurseDecision: decision,
      actionNote: actionNote,
      justification: justification,
    );
    _alerts[index] = updated;
    return updated;
  }

  @override
  Future<Alert> resolveAlert(String alertId, {String? resolutionNote}) async {
    await Future<void>.delayed(_latency);
    final index = _indexOf(alertId);
    final current = _alerts[index];

    if (current.status == AlertStatus.unread) {
      throw StateError('L\'alerte doit être prise en charge avant d\'être résolue.');
    }
    if (current.status == AlertStatus.resolved) {
      return current;
    }

    final updated = current.copyWith(
      status: AlertStatus.resolved,
      resolvedAt: DateTime.now(),
      resolutionNote: resolutionNote,
    );
    _alerts[index] = updated;
    return updated;
  }
}
