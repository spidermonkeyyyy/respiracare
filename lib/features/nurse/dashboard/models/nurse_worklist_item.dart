import 'package:equatable/equatable.dart';

import '../../../communication/models/communication_task.dart';
import '../../alerts/models/alert.dart';
import '../../monitoring/models/monitoring_submission.dart';
import 'monitoring_rule.dart';

/// Source type of a nurse worklist item.
///
/// Only the three types actually supported by the existing domain are modelled.
/// No new clinical categories are invented.
enum NurseWorklistItemType {
  alert,
  monitoring,
  task;

  String get label {
    switch (this) {
      case NurseWorklistItemType.alert:
        return 'Alerte';
      case NurseWorklistItemType.monitoring:
        return 'Suivi à revoir';
      case NurseWorklistItemType.task:
        return 'Tâche';
    }
  }
}

/// Deterministic presentation ordering for worklist items.
///
/// The ordering is for sorting a queue only. It is **not** a clinical severity
/// scale and carries no diagnostic meaning. The mapping is:
///
/// - [priorityRank] for an [Alert] is the alert's own existing
///   `AlertPriority.sortWeight` (0 = high … 3 = informational).
/// - [priorityRank] for a monitoring review item is derived from the strongest
///   matched rule's existing `PriorityLevel` (0 = high, 1 = review-required).
/// - [priorityRank] for a [CommunicationTask] is 3: the task domain exposes no
///   priority-valued field, so tasks fall below alerts/reviews purely for
///   presentation. This is a documented default, not a clinical ranking.
class NurseWorklistItem extends Equatable {
  /// Stable composite id: `type.name:relatedEntityId`.
  final String id;

  final NurseWorklistItemType type;

  /// Patient association — always a stable id.
  final String patientId;

  /// Approved display name; empty string when the patient is unknown to the
  /// nurse roster (never fabricated).
  final String patientName;

  /// Short neutral headline shown in the queue.
  final String title;

  /// Existing domain-provided context (alert summary, rule-engine summary, or
  /// task description). Never constructed from raw measurements.
  final String? description;

  /// Source entity id (alert id, submission id, or task id) used for later
  /// navigation. No clinical content is placed here.
  final String? relatedEntityId;

  /// Closest existing timestamp. Never generated at compose-time.
  final DateTime timestamp;

  /// Lower sorts first (presentation only — see class doc).
  final int priorityRank;

  /// Existing status label (alert status.label, task status.label, or the
  /// fixed review label for monitoring items).
  final String statusLabel;

  /// True when the item still needs a nurse action, as already defined by the
  /// underlying domain (`Alert.isOpen`, `TaskStatus.isOpen`, review-required).
  final bool isActionable;

  /// Existing in-app action route for [CommunicationTask]s; null elsewhere.
  final String? actionRoute;

  const NurseWorklistItem({
    required this.id,
    required this.type,
    required this.patientId,
    required this.patientName,
    required this.title,
    this.description,
    this.relatedEntityId,
    required this.timestamp,
    required this.priorityRank,
    required this.statusLabel,
    required this.isActionable,
    this.actionRoute,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        patientId,
        patientName,
        title,
        description,
        relatedEntityId,
        timestamp,
        priorityRank,
        statusLabel,
        isActionable,
        actionRoute,
      ];
}

/// Composes alerts, monitoring-review items and tasks into one ordered list.
///
/// Pure and side-effect free so it can be unit-tested without Riverpod.
///
/// [patientNames] maps patient id → approved display name. Unknown patients
/// fall back to an empty display name (never fabricated).
List<NurseWorklistItem> composeNurseWorklist({
  required List<Alert> alerts,
  required List<MonitoringSubmission> submissions,
  required List<CommunicationTask> tasks,
  required Map<String, String> patientNames,
}) {
  final items = <NurseWorklistItem>[
    for (final alert in alerts) _fromAlert(alert),
    for (final submission in submissions)
      ..._fromSubmission(submission, patientNames),
    for (final task in tasks) _fromTask(task, patientNames),
  ]..sort(_compareItems);

  return items;
}

NurseWorklistItem _fromAlert(Alert alert) {
  return NurseWorklistItem(
    id: 'alert:${alert.id}',
    type: NurseWorklistItemType.alert,
    patientId: alert.patientId,
    patientName: alert.patientName,
    title: alert.reason,
    description: alert.patientSummary.isEmpty ? null : alert.patientSummary,
    relatedEntityId: alert.id,
    timestamp: alert.createdAt,
    priorityRank: alert.priority.sortWeight,
    statusLabel: alert.status.label,
    isActionable: alert.isOpen,
  );
}

/// A submission becomes a worklist item only when an existing matched rule
/// requires nurse attention. Matched rules marked `informational` by the rule
/// engine do not create a queue entry. No new threshold is applied.
List<NurseWorklistItem> _fromSubmission(
  MonitoringSubmission submission,
  Map<String, String> patientNames,
) {
  final reviewRequired = submission.ruleResults
      .where((r) => r.matched && r.priority != PriorityLevel.informational)
      .toList();
  if (reviewRequired.isEmpty) return const [];

  final hasHigh = reviewRequired.any((r) => r.priority == PriorityLevel.high);
  final primarySummary = reviewRequired.first.summary;

  return [
    NurseWorklistItem(
      id: 'monitoring:${submission.id}',
      type: NurseWorklistItemType.monitoring,
      patientId: submission.patientId,
      patientName: patientNames[submission.patientId] ?? '',
      title: 'Mesures respiratoires à revoir',
      description: primarySummary.isEmpty ? null : primarySummary,
      relatedEntityId: submission.id,
      timestamp: submission.submittedAt,
      priorityRank: hasHigh ? 0 : 1,
      statusLabel: 'À revoir',
      isActionable: true,
    ),
  ];
}

NurseWorklistItem _fromTask(
  CommunicationTask task,
  Map<String, String> patientNames,
) {
  return NurseWorklistItem(
    id: 'task:${task.id}',
    type: NurseWorklistItemType.task,
    patientId: task.patientId,
    patientName: patientNames[task.patientId] ?? '',
    title: task.title,
    description: task.description.isEmpty ? null : task.description,
    relatedEntityId: task.id,
    timestamp: task.createdAt,
    priorityRank: 3,
    statusLabel: task.status.label,
    isActionable: task.status.isOpen,
    actionRoute: task.actionRoute,
  );
}

int _compareItems(NurseWorklistItem a, NurseWorklistItem b) {
  final aActionable = a.isActionable ? 1 : 0;
  final bActionable = b.isActionable ? 1 : 0;
  if (aActionable != bActionable) return bActionable.compareTo(aActionable);
  final byPriority = a.priorityRank.compareTo(b.priorityRank);
  if (byPriority != 0) return byPriority;
  final byTime = b.timestamp.compareTo(a.timestamp);
  if (byTime != 0) return byTime;
  return a.type.index.compareTo(b.type.index);
}
