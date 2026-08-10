import 'package:equatable/equatable.dart';

import 'rule_condition.dart';

/// Logical combination applied to a group of conditions.
enum ConditionGroupMode {
  all,
  any;

  /// Short label used in the builder dropdown.
  String get label {
    switch (this) {
      case ConditionGroupMode.all:
        return 'Toutes les conditions';
      case ConditionGroupMode.any:
        return 'Au moins une condition';
    }
  }

  /// Sentence used by the rule preview.
  String get sentence {
    switch (this) {
      case ConditionGroupMode.all:
        return 'Toutes les conditions sont réunies';
      case ConditionGroupMode.any:
        return 'Au moins une condition est réunie';
    }
  }

  /// Conjunction used when flattening conditions into one line.
  String get conjunction {
    switch (this) {
      case ConditionGroupMode.all:
        return ' ET ';
      case ConditionGroupMode.any:
        return ' OU ';
    }
  }

  String get storageKey => name;

  static ConditionGroupMode fromStorageKey(String value) {
    return ConditionGroupMode.values.firstWhere(
      (mode) => mode.storageKey == value,
      orElse: () => ConditionGroupMode.all,
    );
  }
}

/// Groups conditions under a single ALL/ANY operator.
///
/// ```
/// ALL                ANY
/// ├── Condition 1    ├── Condition 1
/// ├── Condition 2    └── Condition 2
/// └── Condition 3
/// ```
class RuleGroup extends Equatable {
  final String id;
  final ConditionGroupMode mode;
  final List<RuleCondition> conditions;

  const RuleGroup({
    required this.id,
    this.mode = ConditionGroupMode.all,
    this.conditions = const [],
  });

  bool get isEmpty => conditions.isEmpty;

  /// A group is valid once it holds at least one fully configured condition
  /// and no partially configured ones.
  bool get isValid =>
      conditions.isNotEmpty && conditions.every((condition) => condition.isComplete);

  /// Flattened single-line summary, e.g. `SpO₂ ... ET Dyspnée ...`.
  String get summary =>
      conditions.map((condition) => condition.displayText).join(mode.conjunction);

  RuleGroup copyWith({
    String? id,
    ConditionGroupMode? mode,
    List<RuleCondition>? conditions,
  }) {
    return RuleGroup(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      conditions: conditions ?? this.conditions,
    );
  }

  RuleGroup addCondition(RuleCondition condition) =>
      copyWith(conditions: [...conditions, condition]);

  RuleGroup removeCondition(String conditionId) => copyWith(
        conditions: conditions.where((condition) => condition.id != conditionId).toList(),
      );

  RuleGroup updateCondition(RuleCondition updated) => copyWith(
        conditions: conditions
            .map((condition) => condition.id == updated.id ? updated : condition)
            .toList(),
      );

  @override
  List<Object?> get props => [id, mode, conditions];
}
