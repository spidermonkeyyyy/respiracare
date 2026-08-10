import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/alert_priority.dart';
import '../models/monitoring_rule.dart';
import '../models/rule_condition.dart';
import '../models/rule_group.dart';
import '../repositories/mock_rule_repository.dart';
import '../repositories/rule_repository.dart';

class RuleListState {
  final List<MonitoringRule> rules;
  final bool isLoading;
  final String? errorMessage;
  final bool showEnabledOnly;
  final String? pendingRuleId;

  const RuleListState({
    this.rules = const [],
    this.isLoading = false,
    this.errorMessage,
    this.showEnabledOnly = false,
    this.pendingRuleId,
  });

  RuleListState copyWith({
    List<MonitoringRule>? rules,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? showEnabledOnly,
    String? pendingRuleId,
    bool clearPending = false,
  }) {
    return RuleListState(
      rules: rules ?? this.rules,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      showEnabledOnly: showEnabledOnly ?? this.showEnabledOnly,
      pendingRuleId: clearPending ? null : (pendingRuleId ?? this.pendingRuleId),
    );
  }

  List<MonitoringRule> get filteredRules {
    final result = showEnabledOnly ? rules.where((rule) => rule.enabled).toList() : [...rules];
    result.sort((a, b) {
      if (a.enabled != b.enabled) return a.enabled ? -1 : 1;
      final byPriority = a.priority.sortWeight.compareTo(b.priority.sortWeight);
      if (byPriority != 0) return byPriority;
      return a.name.compareTo(b.name);
    });
    return result;
  }

  int get enabledCount => rules.where((rule) => rule.enabled).length;

  bool get isEmpty => !isLoading && errorMessage == null && filteredRules.isEmpty;
}

class RuleListNotifier extends StateNotifier<RuleListState> {
  RuleListNotifier(this._repository) : super(const RuleListState());

  final RuleRepository _repository;

  Future<void> loadRules() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final rules = await _repository.getRules();
      state = state.copyWith(rules: rules, isLoading: false, clearError: true);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger les règles de surveillance.',
      );
    }
  }

  void setShowEnabledOnly(bool value) {
    state = state.copyWith(showEnabledOnly: value);
  }

  MonitoringRule? ruleById(String ruleId) {
    for (final rule in state.rules) {
      if (rule.id == ruleId) return rule;
    }
    return null;
  }

  /// Rules are disabled rather than deleted, so alerts created earlier keep
  /// resolving to an existing rule.
  Future<bool> setEnabled(String ruleId, bool enabled) async {
    state = state.copyWith(pendingRuleId: ruleId, clearError: true);
    try {
      final updated = await _repository.setRuleEnabled(ruleId, enabled);
      _replace(updated);
      return true;
    } catch (_) {
      state = state.copyWith(
        clearPending: true,
        errorMessage: 'Impossible de modifier l\'état de la règle.',
      );
      return false;
    }
  }

  Future<MonitoringRule?> createRule(MonitoringRule rule) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final created = await _repository.createRule(rule);
      state = state.copyWith(
        rules: [...state.rules, created],
        isLoading: false,
        clearError: true,
      );
      return created;
    } on StateError catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return null;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible d\'enregistrer la règle.',
      );
      return null;
    }
  }

  Future<MonitoringRule?> updateRule(MonitoringRule rule) async {
    state = state.copyWith(pendingRuleId: rule.id, clearError: true);
    try {
      final updated = await _repository.updateRule(rule);
      _replace(updated);
      return updated;
    } on StateError catch (error) {
      state = state.copyWith(clearPending: true, errorMessage: error.message);
      return null;
    } catch (_) {
      state = state.copyWith(
        clearPending: true,
        errorMessage: 'Impossible d\'enregistrer la règle.',
      );
      return null;
    }
  }

  void _replace(MonitoringRule updated) {
    state = state.copyWith(
      rules: [
        for (final rule in state.rules) rule.id == updated.id ? updated : rule,
      ],
      clearPending: true,
      clearError: true,
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

/// Editable working copy backing the rule builder.
///
/// Held separately from [RuleListState] so an in-progress edit never mutates
/// the saved configuration until the nurse explicitly saves.
class RuleDraftState {
  final String? id;
  final String name;
  final String description;
  final bool enabled;
  final RuleGroup conditionGroup;
  final RuleAction action;
  final AlertPriority priority;
  final List<RuleMetric> availableMetrics;
  final bool isLoadingMetrics;

  const RuleDraftState({
    this.id,
    this.name = '',
    this.description = '',
    this.enabled = true,
    this.conditionGroup = const RuleGroup(id: 'draft_group'),
    this.action = RuleAction.createAlert,
    this.priority = AlertPriority.medium,
    this.availableMetrics = const [],
    this.isLoadingMetrics = false,
  });

  RuleDraftState copyWith({
    String? id,
    String? name,
    String? description,
    bool? enabled,
    RuleGroup? conditionGroup,
    RuleAction? action,
    AlertPriority? priority,
    List<RuleMetric>? availableMetrics,
    bool? isLoadingMetrics,
  }) {
    return RuleDraftState(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      conditionGroup: conditionGroup ?? this.conditionGroup,
      action: action ?? this.action,
      priority: priority ?? this.priority,
      availableMetrics: availableMetrics ?? this.availableMetrics,
      isLoadingMetrics: isLoadingMetrics ?? this.isLoadingMetrics,
    );
  }

  bool get isEditing => id != null;

  bool get canSave => name.trim().isNotEmpty && conditionGroup.isValid;

  /// Explains why saving is blocked, so the button is never inert without a
  /// reason the nurse can act on.
  String? get validationMessage {
    if (name.trim().isEmpty) return 'Donnez un nom à la règle.';
    if (conditionGroup.conditions.isEmpty) return 'Ajoutez au moins une condition.';
    if (!conditionGroup.isValid) return 'Complétez toutes les conditions.';
    return null;
  }

  /// Snapshot of the draft as a persistable rule.
  MonitoringRule toRule() {
    return MonitoringRule(
      id: id ?? 'draft',
      name: name.trim(),
      description: description.trim(),
      enabled: enabled,
      conditionGroup: conditionGroup,
      action: action,
      priority: priority,
      createdAt: DateTime.now(),
    );
  }
}

class RuleDraftNotifier extends StateNotifier<RuleDraftState> {
  RuleDraftNotifier(this._repository) : super(const RuleDraftState()) {
    _loadMetrics();
  }

  final RuleRepository _repository;
  int _conditionSeed = 0;

  Future<void> _loadMetrics() async {
    state = state.copyWith(isLoadingMetrics: true);
    try {
      final metrics = await _repository.getAvailableMetrics();
      state = state.copyWith(availableMetrics: metrics, isLoadingMetrics: false);
    } catch (_) {
      state = state.copyWith(isLoadingMetrics: false);
    }
  }

  /// Resets the draft, optionally seeding it from an existing rule.
  void startDraft({MonitoringRule? source}) {
    _conditionSeed = 0;
    if (source == null) {
      state = RuleDraftState(
        availableMetrics: state.availableMetrics,
        conditionGroup: const RuleGroup(id: 'draft_group'),
      );
      return;
    }
    state = RuleDraftState(
      id: source.id,
      name: source.name,
      description: source.description,
      enabled: source.enabled,
      conditionGroup: source.conditionGroup,
      action: source.action,
      priority: source.priority,
      availableMetrics: state.availableMetrics,
    );
  }

  void setName(String value) => state = state.copyWith(name: value);

  void setDescription(String value) => state = state.copyWith(description: value);

  void setEnabled(bool value) => state = state.copyWith(enabled: value);

  void setAction(RuleAction value) => state = state.copyWith(action: value);

  void setPriority(AlertPriority value) => state = state.copyWith(priority: value);

  void setGroupMode(ConditionGroupMode mode) {
    state = state.copyWith(conditionGroup: state.conditionGroup.copyWith(mode: mode));
  }

  /// Appends a condition pre-filled with the first available metric.
  void addCondition() {
    if (state.availableMetrics.isEmpty) return;
    final metric = state.availableMetrics.first;
    _conditionSeed++;

    final condition = RuleCondition(
      id: 'draft_cond_$_conditionSeed',
      metric: metric.key,
      metricLabel: metric.label,
      operator: metric.supportedOperators.first,
      unit: metric.unit,
      comparisonMode: metric.supportedOperators.first.isBaselineOperator
          ? ComparisonMode.baseline
          : ComparisonMode.absolute,
    );

    state = state.copyWith(conditionGroup: state.conditionGroup.addCondition(condition));
  }

  void removeCondition(String conditionId) {
    state = state.copyWith(conditionGroup: state.conditionGroup.removeCondition(conditionId));
  }

  /// Switching metric re-points the condition at an operator that metric
  /// actually supports, so the draft can never hold an impossible pairing.
  void changeConditionMetric(String conditionId, String metricKey) {
    final metric = state.availableMetrics.firstWhere(
      (candidate) => candidate.key == metricKey,
      orElse: () => state.availableMetrics.first,
    );

    final current = _condition(conditionId);
    if (current == null) return;

    final operator = metric.supportedOperators.contains(current.operator)
        ? current.operator
        : metric.supportedOperators.first;

    _update(current.copyWith(
      metric: metric.key,
      metricLabel: metric.label,
      unit: metric.unit,
      operator: operator,
      value: operator.requiresValue ? current.value : '',
      comparisonMode:
          operator.isBaselineOperator ? ComparisonMode.baseline : current.comparisonMode,
    ));
  }

  void changeConditionOperator(String conditionId, RuleOperator operator) {
    final current = _condition(conditionId);
    if (current == null) return;

    _update(current.copyWith(
      operator: operator,
      value: operator.requiresValue ? current.value : '',
      comparisonMode:
          operator.isBaselineOperator ? ComparisonMode.baseline : current.comparisonMode,
    ));
  }

  void changeConditionValue(String conditionId, String value) {
    final current = _condition(conditionId);
    if (current == null) return;
    _update(current.copyWith(value: value));
  }

  void changeConditionComparisonMode(String conditionId, ComparisonMode mode) {
    final current = _condition(conditionId);
    if (current == null) return;
    _update(current.copyWith(comparisonMode: mode));
  }

  RuleCondition? _condition(String conditionId) {
    for (final condition in state.conditionGroup.conditions) {
      if (condition.id == conditionId) return condition;
    }
    return null;
  }

  void _update(RuleCondition condition) {
    state = state.copyWith(conditionGroup: state.conditionGroup.updateCondition(condition));
  }
}

final ruleRepositoryProvider = Provider<RuleRepository>((ref) {
  return MockRuleRepository();
});

final ruleListProvider = StateNotifierProvider<RuleListNotifier, RuleListState>((ref) {
  return RuleListNotifier(ref.watch(ruleRepositoryProvider));
});

final ruleDraftProvider =
    StateNotifierProvider<RuleDraftNotifier, RuleDraftState>((ref) {
  return RuleDraftNotifier(ref.watch(ruleRepositoryProvider));
});

final ruleByIdProvider = Provider.family<MonitoringRule?, String>((ref, ruleId) {
  final state = ref.watch(ruleListProvider);
  for (final rule in state.rules) {
    if (rule.id == ruleId) return rule;
  }
  return null;
});

final enabledRuleCountProvider = Provider<int>((ref) {
  return ref.watch(ruleListProvider).enabledCount;
});
