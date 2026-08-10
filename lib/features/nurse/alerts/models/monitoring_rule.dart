import 'package:equatable/equatable.dart';

import 'alert_priority.dart';
import 'rule_group.dart';

/// What the platform does when a rule matches.
///
/// Deliberately limited to surveillance outcomes. The platform never prescribes
/// treatment or contacts anyone autonomously — it creates work for a nurse.
enum RuleAction {
  createAlert,
  flagForReview;

  String get label {
    switch (this) {
      case RuleAction.createAlert:
        return 'Créer une alerte';
      case RuleAction.flagForReview:
        return 'Signaler pour revue';
    }
  }

  String get storageKey => name;

  static RuleAction fromStorageKey(String value) {
    return RuleAction.values.firstWhere(
      (action) => action.storageKey == value,
      orElse: () => RuleAction.createAlert,
    );
  }
}

/// A configurable surveillance rule.
///
/// The rule describes *what to watch for* and *how urgent the resulting review
/// is*. It does not encode a diagnosis. Thresholds live in the configuration
/// data, never in UI code, so they can be reviewed and validated clinically
/// without a code change.
class MonitoringRule extends Equatable {
  final String id;
  final String name;
  final String description;
  final bool enabled;
  final RuleGroup conditionGroup;
  final RuleAction action;
  final AlertPriority priority;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MonitoringRule({
    required this.id,
    required this.name,
    required this.description,
    required this.enabled,
    required this.conditionGroup,
    required this.action,
    required this.priority,
    required this.createdAt,
    this.updatedAt,
  });

  /// Ready to be saved: named, and backed by at least one complete condition.
  bool get isValid => name.trim().isNotEmpty && conditionGroup.isValid;

  String get statusLabel => enabled ? 'Active' : 'Inactive';

  int get conditionCount => conditionGroup.conditions.length;

  MonitoringRule copyWith({
    String? id,
    String? name,
    String? description,
    bool? enabled,
    RuleGroup? conditionGroup,
    RuleAction? action,
    AlertPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonitoringRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      conditionGroup: conditionGroup ?? this.conditionGroup,
      action: action ?? this.action,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        enabled,
        conditionGroup,
        action,
        priority,
        createdAt,
        updatedAt,
      ];
}
