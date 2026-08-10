import '../models/alert_priority.dart';
import '../models/monitoring_rule.dart';
import '../models/rule_condition.dart';
import '../models/rule_group.dart';
import 'rule_repository.dart';

/// In-memory [RuleRepository] used until the backend exists.
///
/// IMPORTANT — every value below is FICTITIOUS MOCK CONFIGURATION. The numbers
/// are placeholders chosen to demonstrate the builder UI; they are NOT
/// clinically validated thresholds and must not be read as recommendations.
/// The real catalogue and thresholds will be defined with the clinical
/// supervisor and served by the backend.
class MockRuleRepository implements RuleRepository {
  MockRuleRepository() {
    _rules = _seed();
  }

  late List<MonitoringRule> _rules;

  static const Duration _latency = Duration(milliseconds: 260);

  /// Mock metric catalogue offered by the condition builder.
  static const List<RuleMetric> _metrics = [
    RuleMetric(
      key: 'spo2',
      label: 'SpO₂',
      unit: '%',
      valueHint: 'valeur configurée',
      supportedOperators: [
        RuleOperator.lessThan,
        RuleOperator.lessThanOrEqual,
        RuleOperator.greaterThan,
        RuleOperator.greaterThanOrEqual,
        RuleOperator.decreasedFromBaseline,
        RuleOperator.increasedFromBaseline,
      ],
    ),
    RuleMetric(
      key: 'dyspnea',
      label: 'Dyspnée (mMRC)',
      valueHint: 'niveau configuré',
      supportedOperators: [
        RuleOperator.equals,
        RuleOperator.greaterThanOrEqual,
        RuleOperator.lessThanOrEqual,
        RuleOperator.increasedFromBaseline,
        RuleOperator.changed,
      ],
    ),
    RuleMetric(
      key: 'cough',
      label: 'Toux',
      valueHint: 'état configuré',
      supportedOperators: [
        RuleOperator.equals,
        RuleOperator.notEquals,
        RuleOperator.increasedFromBaseline,
        RuleOperator.changed,
      ],
    ),
    RuleMetric(
      key: 'sputum',
      label: 'Expectorations',
      valueHint: 'état configuré',
      supportedOperators: [
        RuleOperator.equals,
        RuleOperator.notEquals,
        RuleOperator.changed,
      ],
    ),
    RuleMetric(
      key: 'adherence',
      label: 'Prises confirmées',
      unit: '%',
      valueHint: 'seuil configuré',
      supportedOperators: [
        RuleOperator.lessThan,
        RuleOperator.lessThanOrEqual,
        RuleOperator.decreasedFromBaseline,
      ],
    ),
    RuleMetric(
      key: 'submission_gap',
      label: 'Jours sans suivi',
      unit: 'j',
      valueHint: 'nombre de jours',
      supportedOperators: [
        RuleOperator.greaterThan,
        RuleOperator.greaterThanOrEqual,
      ],
    ),
  ];

  List<MonitoringRule> _seed() {
    final now = DateTime.now();

    return [
      MonitoringRule(
        id: 'rule_001',
        name: 'Aggravation respiratoire',
        description:
            'Combine une variation de la saturation et une variation de la dyspnée signalée dans le suivi.',
        enabled: true,
        priority: AlertPriority.high,
        action: RuleAction.createAlert,
        createdAt: now.subtract(const Duration(days: 30)),
        conditionGroup: const RuleGroup(
          id: 'group_001',
          mode: ConditionGroupMode.all,
          conditions: [
            RuleCondition(
              id: 'cond_001',
              metric: 'spo2',
              metricLabel: 'SpO₂',
              operator: RuleOperator.decreasedFromBaseline,
              value: '3',
              unit: 'points',
              comparisonMode: ComparisonMode.baseline,
            ),
            RuleCondition(
              id: 'cond_002',
              metric: 'dyspnea',
              metricLabel: 'Dyspnée (mMRC)',
              operator: RuleOperator.increasedFromBaseline,
              value: '1',
              comparisonMode: ComparisonMode.baseline,
            ),
          ],
        ),
      ),
      MonitoringRule(
        id: 'rule_002',
        name: 'Variation des symptômes',
        description:
            'Signale une modification de la toux ou des expectorations par rapport à la référence du patient.',
        enabled: true,
        priority: AlertPriority.medium,
        action: RuleAction.createAlert,
        createdAt: now.subtract(const Duration(days: 24)),
        conditionGroup: const RuleGroup(
          id: 'group_002',
          mode: ConditionGroupMode.any,
          conditions: [
            RuleCondition(
              id: 'cond_003',
              metric: 'cough',
              metricLabel: 'Toux',
              operator: RuleOperator.changed,
              comparisonMode: ComparisonMode.baseline,
            ),
            RuleCondition(
              id: 'cond_004',
              metric: 'sputum',
              metricLabel: 'Expectorations',
              operator: RuleOperator.changed,
              comparisonMode: ComparisonMode.baseline,
            ),
          ],
        ),
      ),
      MonitoringRule(
        id: 'rule_003',
        name: 'Suivi de traitement incomplet',
        description: 'Signale un taux de prises confirmées inférieur au seuil configuré.',
        enabled: true,
        priority: AlertPriority.medium,
        action: RuleAction.createAlert,
        createdAt: now.subtract(const Duration(days: 18)),
        conditionGroup: const RuleGroup(
          id: 'group_003',
          mode: ConditionGroupMode.all,
          conditions: [
            RuleCondition(
              id: 'cond_005',
              metric: 'adherence',
              metricLabel: 'Prises confirmées',
              operator: RuleOperator.lessThan,
              value: '80',
              unit: '%',
              comparisonMode: ComparisonMode.absolute,
            ),
          ],
        ),
      ),
      MonitoringRule(
        id: 'rule_004',
        name: 'Suivi incomplet',
        description: 'Signale une absence de transmission de suivi sur la période configurée.',
        enabled: false,
        priority: AlertPriority.low,
        action: RuleAction.flagForReview,
        createdAt: now.subtract(const Duration(days: 9)),
        conditionGroup: const RuleGroup(
          id: 'group_004',
          mode: ConditionGroupMode.all,
          conditions: [
            RuleCondition(
              id: 'cond_006',
              metric: 'submission_gap',
              metricLabel: 'Jours sans suivi',
              operator: RuleOperator.greaterThanOrEqual,
              value: '2',
              unit: 'j',
              comparisonMode: ComparisonMode.absolute,
            ),
          ],
        ),
      ),
    ];
  }

  int _indexOf(String ruleId) {
    final index = _rules.indexWhere((rule) => rule.id == ruleId);
    if (index == -1) {
      throw StateError('Règle introuvable: $ruleId');
    }
    return index;
  }

  @override
  Future<List<MonitoringRule>> getRules() async {
    await Future<void>.delayed(_latency);
    return List<MonitoringRule>.unmodifiable(_rules);
  }

  @override
  Future<List<MonitoringRule>> getEnabledRules() async {
    await Future<void>.delayed(_latency);
    return _rules.where((rule) => rule.enabled).toList();
  }

  @override
  Future<MonitoringRule?> getRuleById(String ruleId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    for (final rule in _rules) {
      if (rule.id == ruleId) return rule;
    }
    return null;
  }

  @override
  Future<MonitoringRule> createRule(MonitoringRule rule) async {
    await Future<void>.delayed(_latency);
    if (!rule.isValid) {
      throw StateError('La règle est incomplète.');
    }
    final created = rule.copyWith(
      id: 'rule_${DateTime.now().microsecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _rules = [..._rules, created];
    return created;
  }

  @override
  Future<MonitoringRule> updateRule(MonitoringRule rule) async {
    await Future<void>.delayed(_latency);
    if (!rule.isValid) {
      throw StateError('La règle est incomplète.');
    }
    final index = _indexOf(rule.id);
    final updated = rule.copyWith(updatedAt: DateTime.now());
    _rules[index] = updated;
    return updated;
  }

  @override
  Future<MonitoringRule> setRuleEnabled(String ruleId, bool enabled) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final index = _indexOf(ruleId);
    final updated = _rules[index].copyWith(enabled: enabled, updatedAt: DateTime.now());
    _rules[index] = updated;
    return updated;
  }

  @override
  Future<List<RuleMetric>> getAvailableMetrics() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _metrics;
  }
}
