import 'package:equatable/equatable.dart';

enum PriorityLevel { high, reviewRequired, informational }

enum RuleActionType { nurseReview, patientContact, escalation }

class RuleCondition extends Equatable {
  final String field;
  final String operator;
  final String value;
  final String? description;

  const RuleCondition({
    required this.field,
    required this.operator,
    required this.value,
    this.description,
  });

  @override
  List<Object?> get props => [field, operator, value, description];
}

class RuleAction extends Equatable {
  final RuleActionType type;
  final String label;
  final PriorityLevel priority;

  const RuleAction({
    required this.type,
    required this.label,
    required this.priority,
  });

  @override
  List<Object?> get props => [type, label, priority];
}

class MonitoringRule extends Equatable {
  final String id;
  final String title;
  final String description;
  final RuleCondition condition;
  final RuleAction action;

  const MonitoringRule({
    required this.id,
    required this.title,
    required this.description,
    required this.condition,
    required this.action,
  });

  @override
  List<Object?> get props => [id, title, description, condition, action];
}

class RuleEvaluationResult extends Equatable {
  final String ruleId;
  final String title;
  final bool matched;
  final List<String> evidence;
  final String summary;
  final PriorityLevel priority;

  const RuleEvaluationResult({
    required this.ruleId,
    required this.title,
    required this.matched,
    required this.evidence,
    required this.summary,
    required this.priority,
  });

  @override
  List<Object?> get props => [ruleId, title, matched, evidence, summary, priority];
}
