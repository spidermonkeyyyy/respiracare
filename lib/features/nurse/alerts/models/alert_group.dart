import 'package:equatable/equatable.dart';

import 'alert.dart';
import 'alert_priority.dart';

/// Related open alerts for one patient, presented as a single review item.
///
/// Alert fatigue (step 4.9T/4.9U) is the main risk in a surveillance product:
/// three separate red rows for one patient train the nurse to ignore red. So
/// alerts are grouped per patient and summarised as
/// `3 éléments nécessitent une revue`, with the group inheriting the highest
/// priority and the most recent timestamp of its members.
class AlertGroup extends Equatable {
  final String patientId;
  final String patientName;
  final String patientSummary;
  final List<Alert> alerts;

  const AlertGroup({
    required this.patientId,
    required this.patientName,
    required this.patientSummary,
    required this.alerts,
  });

  /// Builds one group per patient, ordered by priority then recency.
  ///
  /// Sorting is stable and deterministic so the queue does not reshuffle
  /// between rebuilds.
  static List<AlertGroup> groupByPatient(List<Alert> alerts) {
    final buckets = <String, List<Alert>>{};
    for (final alert in alerts) {
      buckets.putIfAbsent(alert.patientId, () => <Alert>[]).add(alert);
    }

    final groups = buckets.entries.map((entry) {
      final patientAlerts = [...entry.value]
        ..sort((a, b) {
          final byPriority = a.priority.sortWeight.compareTo(b.priority.sortWeight);
          if (byPriority != 0) return byPriority;
          return b.createdAt.compareTo(a.createdAt);
        });

      return AlertGroup(
        patientId: entry.key,
        patientName: patientAlerts.first.patientName,
        patientSummary: patientAlerts.first.patientSummary,
        alerts: patientAlerts,
      );
    }).toList();

    groups.sort((a, b) {
      final byPriority = a.priority.sortWeight.compareTo(b.priority.sortWeight);
      if (byPriority != 0) return byPriority;
      return b.mostRecentAt.compareTo(a.mostRecentAt);
    });

    return groups;
  }

  bool get isSingle => alerts.length == 1;

  int get count => alerts.length;

  /// Highest priority among members — the group is only as calm as its worst
  /// item.
  AlertPriority get priority => alerts
      .map((alert) => alert.priority)
      .reduce((a, b) => a.sortWeight <= b.sortWeight ? a : b);

  DateTime get mostRecentAt =>
      alerts.map((alert) => alert.createdAt).reduce((a, b) => a.isAfter(b) ? a : b);

  int get unreadCount => alerts.where((alert) => !alert.isAcknowledged).length;

  /// Distinct metric labels across the group, e.g. `SpO₂`, `Dyspnée`.
  List<String> get concernedMetrics {
    final seen = <String>{};
    for (final alert in alerts) {
      seen.addAll(alert.concernedMetrics);
    }
    return seen.toList();
  }

  /// Headline for the group card.
  String get summaryLabel =>
      isSingle ? alerts.first.reason : '$count éléments nécessitent une revue';

  @override
  List<Object?> get props => [patientId, patientName, patientSummary, alerts];
}
