import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respiracare/features/nurse/alerts/models/alert_priority.dart';
import 'package:respiracare/features/nurse/alerts/models/monitoring_rule.dart';
import 'package:respiracare/features/nurse/alerts/models/rule_condition.dart';
import 'package:respiracare/features/nurse/alerts/models/rule_group.dart';
import 'package:respiracare/features/nurse/alerts/providers/rule_provider.dart';
import 'package:respiracare/features/nurse/alerts/repositories/mock_rule_repository.dart';

void main() {
  group('MockRuleRepository', () {
    late MockRuleRepository repository;

    setUp(() => repository = MockRuleRepository());

    test('seeds four rules with three enabled and a metric catalogue',
        () async {
      final rules = await repository.getRules();
      expect(rules.length, equals(4));
      expect(await repository.getEnabledRules(), hasLength(3));
      expect(await repository.getAvailableMetrics(), hasLength(6));
    });

    test('createRule rejects an incomplete rule', () async {
      final empty = MonitoringRule(
        id: 'x',
        name: '',
        description: '',
        enabled: true,
        priority: AlertPriority.medium,
        action: RuleAction.createAlert,
        createdAt: DateTime.now(),
        conditionGroup: const RuleGroup(id: 'g'),
      );
      expect(() => repository.createRule(empty), throwsStateError);
    });

    test('createRule assigns a fresh id and setRuleEnabled toggles', () async {
      final rule = MonitoringRule(
        id: 'x',
        name: 'Temp',
        description: 'desc',
        enabled: true,
        priority: AlertPriority.low,
        action: RuleAction.flagForReview,
        createdAt: DateTime.now(),
        conditionGroup: const RuleGroup(
          id: 'g',
          conditions: [
            RuleCondition(
              id: 'c',
              metric: 'spo2',
              metricLabel: 'SpO₂',
              operator: RuleOperator.lessThan,
              value: '90',
              unit: '%',
            ),
          ],
        ),
      );
      final created = await repository.createRule(rule);
      expect(created.id, isNot(equals('x')));

      final toggled = await repository.setRuleEnabled(created.id, false);
      expect(toggled.enabled, isFalse);
    });
  });

  group('RuleListNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          ruleRepositoryProvider.overrideWithValue(MockRuleRepository()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loadRules populates and counts enabled rules', () async {
      await container.read(ruleListProvider.notifier).loadRules();
      final state = container.read(ruleListProvider);
      expect(state.rules.length, equals(4));
      expect(state.enabledCount, equals(3));
    });

    test('setEnabled toggles and updates the persisted rule', () async {
      await container.read(ruleListProvider.notifier).loadRules();
      final target = container
          .read(ruleListProvider)
          .rules
          .firstWhere((rule) => rule.id == 'rule_004');
      expect(target.enabled, isFalse);

      final ok = await container
          .read(ruleListProvider.notifier)
          .setEnabled('rule_004', true);
      expect(ok, isTrue);
      final toggled =
          container.read(ruleListProvider.notifier).ruleById('rule_004');
      expect(toggled?.enabled, isTrue);
    });
  });

  group('RuleDraftNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          ruleRepositoryProvider.overrideWithValue(MockRuleRepository()),
        ],
      );
    });

    tearDown(() => container.dispose());

    Future<void> waitForMetrics() async {
      container.read(ruleDraftProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 250));
    }

    test('starts an empty draft that cannot be saved', () async {
      await waitForMetrics();
      final notifier = container.read(ruleDraftProvider.notifier);
      notifier.startDraft();
      final state = container.read(ruleDraftProvider);
      expect(state.availableMetrics, isNotEmpty);
      expect(state.canSave, isFalse);
      expect(state.validationMessage, isNotNull);
    });

    test('adding a condition uses the first available metric', () async {
      await waitForMetrics();
      final notifier = container.read(ruleDraftProvider.notifier);
      notifier.startDraft();
      notifier.addCondition();
      final state = container.read(ruleDraftProvider);
      expect(state.conditionGroup.conditions, hasLength(1));
      expect(state.conditionGroup.conditions.first.metric, equals('spo2'));
    });

    test('switching metric re-points to a supported operator', () async {
      await waitForMetrics();
      final notifier = container.read(ruleDraftProvider.notifier);
      notifier.startDraft();
      notifier.addCondition();
      final id =
          container.read(ruleDraftProvider).conditionGroup.conditions.first.id;

      // 'cough' does not support the SpO2 default operator, so it must switch.
      notifier.changeConditionMetric(id, 'cough');
      var condition = container
          .read(ruleDraftProvider)
          .conditionGroup
          .conditions
          .firstWhere((c) => c.id == id);
      expect(condition.metric, equals('cough'));
      expect(condition.operator, equals(RuleOperator.equals));

      // A self-contained operator clears the operand.
      notifier.changeConditionOperator(id, RuleOperator.changed);
      condition = container
          .read(ruleDraftProvider)
          .conditionGroup
          .conditions
          .firstWhere((c) => c.id == id);
      expect(condition.operator, equals(RuleOperator.changed));
      expect(condition.value, isEmpty);
    });

    test('a named rule with a complete condition can be saved', () async {
      await waitForMetrics();
      final notifier = container.read(ruleDraftProvider.notifier);
      notifier.startDraft();
      notifier.setName('Variation SpO₂');
      notifier.addCondition();
      final id =
          container.read(ruleDraftProvider).conditionGroup.conditions.first.id;
      notifier.changeConditionValue(id, '90');
      final state = container.read(ruleDraftProvider);
      expect(state.canSave, isTrue);

      final rule = state.toRule();
      expect(rule.name, equals('Variation SpO₂'));
      expect(rule.conditionGroup.conditions, hasLength(1));
      expect(rule.priority, equals(AlertPriority.medium));
    });
  });
}
