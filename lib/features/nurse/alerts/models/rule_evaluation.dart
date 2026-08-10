import 'package:equatable/equatable.dart';

import 'alert_priority.dart';

/// Outcome of evaluating one [MonitoringRule] against a monitoring submission.
///
/// This is the contract between the (future) rule engine and the frontend:
///
/// ```
/// MonitoringSubmission -> RuleEvaluationResult -> Alert
/// ```
///
/// The frontend *consumes* evaluation results. It never computes them: no
/// widget, provider, or model in this feature inspects raw patient values to
/// decide whether a criterion is met. That authority belongs to the backend
/// rules engine so the logic can be clinically validated in one place.
class RuleEvaluationResult extends Equatable {
  final String ruleId;

  /// Rule name as configured. Shown to the nurse instead of [ruleId] — the
  /// technical identifier is never the primary explanation.
  final String ruleName;

  final bool matched;

  /// Plain-language description of each criterion that matched, supplied by
  /// the evaluation layer, e.g. `Variation de la dyspnée`.
  final List<String> matchedCriteria;

  final AlertPriority priority;
  final DateTime evaluatedAt;

  const RuleEvaluationResult({
    required this.ruleId,
    required this.ruleName,
    required this.matched,
    required this.matchedCriteria,
    required this.priority,
    required this.evaluatedAt,
  });

  RuleEvaluationResult copyWith({
    String? ruleId,
    String? ruleName,
    bool? matched,
    List<String>? matchedCriteria,
    AlertPriority? priority,
    DateTime? evaluatedAt,
  }) {
    return RuleEvaluationResult(
      ruleId: ruleId ?? this.ruleId,
      ruleName: ruleName ?? this.ruleName,
      matched: matched ?? this.matched,
      matchedCriteria: matchedCriteria ?? this.matchedCriteria,
      priority: priority ?? this.priority,
      evaluatedAt: evaluatedAt ?? this.evaluatedAt,
    );
  }

  @override
  List<Object?> get props => [ruleId, ruleName, matched, matchedCriteria, priority, evaluatedAt];
}
