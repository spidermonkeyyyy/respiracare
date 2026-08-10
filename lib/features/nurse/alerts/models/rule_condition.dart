import 'package:equatable/equatable.dart';

/// How a condition's value should be compared.
///
/// [absolute] compares against the configured value directly.
/// [baseline] compares against the patient's own recent reference.
/// [trend] looks at the direction of change over recent submissions.
enum ComparisonMode {
  absolute,
  baseline,
  trend;

  String get label {
    switch (this) {
      case ComparisonMode.absolute:
        return 'Valeur absolue';
      case ComparisonMode.baseline:
        return 'Comparé à la référence du patient';
      case ComparisonMode.trend:
        return 'Tendance récente';
    }
  }
}

/// Generic comparison operators available to the rule builder.
///
/// This list is an *architectural* option set, not a clinical recommendation.
/// The definitive operator list is to be agreed with the clinical supervisor.
enum RuleOperator {
  equals,
  notEquals,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  increasedFromBaseline,
  decreasedFromBaseline,
  changed;

  String get symbol {
    switch (this) {
      case RuleOperator.equals:
        return '=';
      case RuleOperator.notEquals:
        return '≠';
      case RuleOperator.greaterThan:
        return '>';
      case RuleOperator.lessThan:
        return '<';
      case RuleOperator.greaterThanOrEqual:
        return '≥';
      case RuleOperator.lessThanOrEqual:
        return '≤';
      case RuleOperator.increasedFromBaseline:
        return '↑';
      case RuleOperator.decreasedFromBaseline:
        return '↓';
      case RuleOperator.changed:
        return '±';
    }
  }

  String get label {
    switch (this) {
      case RuleOperator.equals:
        return 'est égal à';
      case RuleOperator.notEquals:
        return 'est différent de';
      case RuleOperator.greaterThan:
        return 'est supérieur à';
      case RuleOperator.lessThan:
        return 'est inférieur à';
      case RuleOperator.greaterThanOrEqual:
        return 'est supérieur ou égal à';
      case RuleOperator.lessThanOrEqual:
        return 'est inférieur ou égal à';
      case RuleOperator.increasedFromBaseline:
        return 'augmente par rapport à la référence de';
      case RuleOperator.decreasedFromBaseline:
        return 'diminue par rapport à la référence de';
      case RuleOperator.changed:
        return 'présente une modification signalée';
    }
  }

  /// Operators such as [changed] are self-contained and take no operand.
  bool get requiresValue => this != RuleOperator.changed;

  /// Operators that only make sense against the patient's own reference.
  bool get isBaselineOperator =>
      this == RuleOperator.increasedFromBaseline ||
      this == RuleOperator.decreasedFromBaseline;

  String get storageKey => name;

  static RuleOperator fromStorageKey(String value) {
    return RuleOperator.values.firstWhere(
      (op) => op.storageKey == value,
      orElse: () => RuleOperator.equals,
    );
  }
}

/// A metric that a condition can be built on.
///
/// Metrics are supplied by the repository rather than hardcoded in widgets, so
/// the catalogue can later come from a validated clinical configuration
/// without touching the UI.
class RuleMetric extends Equatable {
  final String key;
  final String label;

  /// Unit shown next to the value field, e.g. `%`. Empty when not applicable.
  final String unit;

  /// Operators that make sense for this metric.
  final List<RuleOperator> supportedOperators;

  /// Hint shown in the value field. Deliberately generic — no clinical
  /// threshold is suggested here.
  final String valueHint;

  const RuleMetric({
    required this.key,
    required this.label,
    this.unit = '',
    required this.supportedOperators,
    this.valueHint = 'valeur',
  });

  @override
  List<Object?> get props => [key, label, unit, supportedOperators, valueHint];
}

/// A single configurable surveillance condition.
///
/// Intentionally generic: the frontend understands the *structure* of a
/// condition (metric / operator / value / comparison mode) but never decides
/// whether a given combination is clinically valid.
class RuleCondition extends Equatable {
  final String id;

  /// Key of the [RuleMetric] this condition observes.
  final String metric;

  /// Display label for [metric], denormalised so cards can render without a
  /// catalogue lookup.
  final String metricLabel;

  final RuleOperator operator;

  /// Operand as raw text. Kept as a string because the operand may be numeric,
  /// categorical, or empty depending on the operator.
  final String value;

  final String unit;
  final ComparisonMode comparisonMode;

  const RuleCondition({
    required this.id,
    required this.metric,
    required this.metricLabel,
    required this.operator,
    this.value = '',
    this.unit = '',
    this.comparisonMode = ComparisonMode.absolute,
  });

  /// Human-readable rendering used by the rule preview and rule detail.
  String get displayText {
    if (!operator.requiresValue) {
      return '$metricLabel ${operator.label}';
    }
    final suffix = unit.isEmpty ? '' : ' $unit';
    return '$metricLabel ${operator.label} $value$suffix';
  }

  /// A condition is only complete once it carries an operand, unless the
  /// operator is self-contained.
  bool get isComplete {
    if (metric.isEmpty) return false;
    if (!operator.requiresValue) return true;
    return value.trim().isNotEmpty;
  }

  RuleCondition copyWith({
    String? id,
    String? metric,
    String? metricLabel,
    RuleOperator? operator,
    String? value,
    String? unit,
    ComparisonMode? comparisonMode,
  }) {
    return RuleCondition(
      id: id ?? this.id,
      metric: metric ?? this.metric,
      metricLabel: metricLabel ?? this.metricLabel,
      operator: operator ?? this.operator,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      comparisonMode: comparisonMode ?? this.comparisonMode,
    );
  }

  @override
  List<Object?> get props => [id, metric, metricLabel, operator, value, unit, comparisonMode];
}
