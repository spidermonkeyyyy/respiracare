import '../models/monitoring_rule.dart';
import '../models/rule_condition.dart';

/// Data access contract for configurable surveillance rules.
abstract class RuleRepository {
  Future<List<MonitoringRule>> getRules();

  Future<List<MonitoringRule>> getEnabledRules();

  Future<MonitoringRule?> getRuleById(String ruleId);

  Future<MonitoringRule> createRule(MonitoringRule rule);

  Future<MonitoringRule> updateRule(MonitoringRule rule);

  /// Flips the active state.
  ///
  /// Note there is intentionally no `deleteRule`. Rules are disabled rather
  /// than removed so historical alerts keep pointing at a rule that still
  /// exists, preserving traceability.
  Future<MonitoringRule> setRuleEnabled(String ruleId, bool enabled);

  /// Catalogue of metrics offered by the condition builder.
  ///
  /// Supplied by the repository rather than hardcoded in widgets so the real
  /// catalogue can arrive from a validated clinical configuration later.
  Future<List<RuleMetric>> getAvailableMetrics();
}
