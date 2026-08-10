import 'package:equatable/equatable.dart';

import 'alert_priority.dart';
import 'alert_status.dart';
import 'rule_evaluation.dart';
import 'supporting_measurement.dart';

/// Concrete follow-up the nurse chose for an alert.
enum NurseAction {
  monitoring,
  contactPatient,
  pneumologistReview,
  other;

  String get label {
    switch (this) {
      case NurseAction.monitoring:
        return 'Surveillance simple';
      case NurseAction.contactPatient:
        return 'Contact patient';
      case NurseAction.pneumologistReview:
        return 'Avis pneumologue';
      case NurseAction.other:
        return 'Autre';
    }
  }

  /// `other` is free-form, so it is only meaningful with an explanatory note.
  bool get requiresNote => this == NurseAction.other;

  String get storageKey => name;

  static NurseAction fromStorageKey(String value) {
    return NurseAction.values.firstWhere(
      (action) => action.storageKey == value,
      orElse: () => NurseAction.monitoring,
    );
  }
}

/// The nurse's clinical judgement about the alert.
///
/// This is the override mechanism: the platform detected that data met a
/// configured criterion, but the nurse decides what it means. Disagreeing with
/// the system is a first-class, recorded outcome — not a silent dismissal.
enum NurseDecision {
  actionRequired,
  enhancedMonitoring,
  notConcerning;

  String get label {
    switch (this) {
      case NurseDecision.actionRequired:
        return 'Action requise';
      case NurseDecision.enhancedMonitoring:
        return 'Surveillance renforcée';
      case NurseDecision.notConcerning:
        return 'Non préoccupant selon évaluation';
    }
  }

  /// Overriding the alert demands a written justification so the reasoning
  /// stays auditable.
  bool get requiresJustification => this == NurseDecision.notConcerning;

  String get storageKey => name;

  static NurseDecision fromStorageKey(String value) {
    return NurseDecision.values.firstWhere(
      (decision) => decision.storageKey == value,
      orElse: () => NurseDecision.actionRequired,
    );
  }
}

/// A clinical alert awaiting nurse review.
///
/// An alert states that patient data matched a configured surveillance
/// criterion. It never asserts a diagnosis, and it is never auto-resolved:
/// closing one always requires an explicit nurse action, which is what makes
/// the audit trail meaningful.
class Alert extends Equatable {
  final String id;
  final String patientId;
  final String patientName;

  /// Denormalised context, e.g. `BPCO · GOLD III`.
  final String patientSummary;

  /// Short neutral headline, e.g. `Données respiratoires à revoir`.
  final String reason;

  final AlertPriority priority;
  final AlertStatus status;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;

  /// Evaluation results that produced this alert.
  final List<RuleEvaluationResult> triggeredRules;

  final List<SupportingMeasurement> supportingMeasurements;

  /// Identifier of the originating monitoring submission, used to deep-link
  /// into the full patient record.
  final String? submissionId;

  final String? assignedNurseId;
  final NurseAction? nurseAction;
  final NurseDecision? nurseDecision;
  final String? actionNote;
  final String? justification;
  final String? resolutionNote;

  const Alert({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.patientSummary = '',
    required this.reason,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.acknowledgedAt,
    this.resolvedAt,
    this.triggeredRules = const [],
    this.supportingMeasurements = const [],
    this.submissionId,
    this.assignedNurseId,
    this.nurseAction,
    this.nurseDecision,
    this.actionNote,
    this.justification,
    this.resolutionNote,
  });

  bool get isOpen => status.isOpen;

  bool get isAcknowledged =>
      status == AlertStatus.acknowledged ||
      status == AlertStatus.inProgress ||
      status == AlertStatus.resolved;

  /// Flat list of every criterion that matched, across all triggered rules.
  /// Used by the "Critères concernés" explanation block.
  List<String> get matchedCriteria => [
        for (final rule in triggeredRules) ...rule.matchedCriteria,
      ];

  /// Metric labels behind this alert, used when summarising grouped alerts.
  List<String> get concernedMetrics =>
      supportingMeasurements.map((measurement) => measurement.label).toList();

  Alert copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? patientSummary,
    String? reason,
    AlertPriority? priority,
    AlertStatus? status,
    DateTime? createdAt,
    DateTime? acknowledgedAt,
    DateTime? resolvedAt,
    List<RuleEvaluationResult>? triggeredRules,
    List<SupportingMeasurement>? supportingMeasurements,
    String? submissionId,
    String? assignedNurseId,
    NurseAction? nurseAction,
    NurseDecision? nurseDecision,
    String? actionNote,
    String? justification,
    String? resolutionNote,
  }) {
    return Alert(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientSummary: patientSummary ?? this.patientSummary,
      reason: reason ?? this.reason,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      triggeredRules: triggeredRules ?? this.triggeredRules,
      supportingMeasurements: supportingMeasurements ?? this.supportingMeasurements,
      submissionId: submissionId ?? this.submissionId,
      assignedNurseId: assignedNurseId ?? this.assignedNurseId,
      nurseAction: nurseAction ?? this.nurseAction,
      nurseDecision: nurseDecision ?? this.nurseDecision,
      actionNote: actionNote ?? this.actionNote,
      justification: justification ?? this.justification,
      resolutionNote: resolutionNote ?? this.resolutionNote,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        patientSummary,
        reason,
        priority,
        status,
        createdAt,
        acknowledgedAt,
        resolvedAt,
        triggeredRules,
        supportingMeasurements,
        submissionId,
        assignedNurseId,
        nurseAction,
        nurseDecision,
        actionNote,
        justification,
        resolutionNote,
      ];
}
