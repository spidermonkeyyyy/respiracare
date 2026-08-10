import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../models/rule_condition.dart';

/// Editable form for a single condition inside the rule builder.
///
/// The metric catalogue is injected (the [RuleDraftNotifier] gets it from the
/// repository), so this widget never hardcodes metric names or operators. When
/// the metric changes, the parent re-points the condition at a valid operator,
/// which is why the operator dropdown can only ever show operators that apply
/// to the chosen metric.
class RuleConditionBuilder extends StatelessWidget {
  final RuleCondition condition;
  final List<RuleMetric> metrics;

  /// Same callbacks as [RuleDraftNotifier], wired by the builder screen.
  final ValueChanged<String> onMetricChanged;
  final ValueChanged<RuleOperator> onOperatorChanged;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<ComparisonMode> onComparisonModeChanged;
  final VoidCallback? onRemove;

  const RuleConditionBuilder({
    super.key,
    required this.condition,
    required this.metrics,
    required this.onMetricChanged,
    required this.onOperatorChanged,
    required this.onValueChanged,
    required this.onComparisonModeChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final metric = metrics.firstWhere(
      (candidate) => candidate.key == condition.metric,
      orElse: () => metrics.first,
    );
    final operators = metric.supportedOperators;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _Dropdown<String>(
                  label: 'Mesure',
                  value: condition.metric,
                  items: metrics
                      .map((candidate) => DropdownMenuItem(
                          value: candidate.key, child: Text(candidate.label)))
                      .toList(),
                  onChanged: onMetricChanged,
                ),
              ),
              if (onRemove != null) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.danger),
                  tooltip: 'Supprimer',
                  onPressed: onRemove,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _Dropdown<RuleOperator>(
                  label: 'Opérateur',
                  value: condition.operator,
                  items: operators
                      .map((operator) => DropdownMenuItem(
                            value: operator,
                            child:
                                Text('${operator.symbol}  ${operator.label}'),
                          ))
                      .toList(),
                  onChanged: onOperatorChanged,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (condition.operator.requiresValue)
                Expanded(
                  child: TextField(
                    key: ValueKey('${condition.id}-${condition.operator}'),
                    controller: TextEditingController(text: condition.value)
                      ..selection = TextSelection.collapsed(
                          offset: condition.value.length),
                    decoration: InputDecoration(
                      labelText: 'Valeur',
                      hintText: metric.valueHint,
                      hintStyle: AppTypography.bodySmall,
                      suffixText: metric.unit.isEmpty ? null : metric.unit,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                    ),
                    keyboardType: metric.unit.isEmpty
                        ? TextInputType.text
                        : const TextInputType.numberWithOptions(decimal: true),
                    onChanged: onValueChanged,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _Dropdown<ComparisonMode>(
            label: 'Comparaison',
            value: condition.comparisonMode,
            items: ComparisonMode.values
                .map((mode) =>
                    DropdownMenuItem(value: mode, child: Text(mode.label)))
                .toList(),
            onChanged: onComparisonModeChanged,
          ),
        ],
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium),
        const SizedBox(height: 4.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: (next) => onChanged(next as T),
            isExpanded: true,
            underline: const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
