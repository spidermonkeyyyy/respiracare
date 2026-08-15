import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_loading.dart';
import '../models/alert_priority.dart';
import '../models/monitoring_rule.dart';
import '../models/rule_group.dart';
import '../providers/rule_provider.dart';
import '../widgets/rule_condition_builder.dart';
import '../widgets/rule_summary.dart';

/// Rule builder screen.
///
/// Drives [RuleDraftNotifier], which holds the working copy and pulls the
/// metric catalogue from the repository. The screen never hardcodes metric
/// names or thresholds — it only arranges what the catalogue offers.
class RuleBuilderScreen extends ConsumerStatefulWidget {
  /// `new` to create, otherwise an existing rule id to edit.
  final String ruleId;

  const RuleBuilderScreen({super.key, required this.ruleId});

  @override
  ConsumerState<RuleBuilderScreen> createState() => _RuleBuilderScreenState();
}

class _RuleBuilderScreenState extends ConsumerState<RuleBuilderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final draft = ref.read(ruleDraftProvider.notifier);
      if (widget.ruleId == 'new') {
        draft.startDraft();
      } else {
        final existing =
            ref.read(ruleListProvider.notifier).ruleById(widget.ruleId);
        draft.startDraft(source: existing);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(ruleDraftProvider);
    final draftNotifier = ref.read(ruleDraftProvider.notifier);
    final ruleNotifier = ref.read(ruleListProvider.notifier);

    if (draft.isLoadingMetrics && draft.availableMetrics.isEmpty) {
      return const Scaffold(
        body: Center(
            child: AppLoading(message: 'Chargement du catalogue de mesures…')),
      );
    }

    final metrics = draft.availableMetrics;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => context.pop(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(draft.isEditing ? 'Modifier la règle' : 'Nouvelle règle'),
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          automaticallyImplyLeading: true,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: TextEditingController(text: draft.name)
                        ..selection =
                            TextSelection.collapsed(offset: draft.name.length),
                      decoration: InputDecoration(
                        labelText: 'Nom de la règle',
                        hintText: 'Ex. Aggravation respiratoire',
                        hintStyle: AppTypography.bodySmall,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                      ),
                      onChanged: draftNotifier.setName,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: TextEditingController(text: draft.description)
                        ..selection = TextSelection.collapsed(
                            offset: draft.description.length),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Expliquez ce que surveille cette règle.',
                        hintStyle: AppTypography.bodySmall,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                      ),
                      onChanged: draftNotifier.setDescription,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text('Priorité des alertes',
                        style: AppTypography.labelMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: AlertPriority.values
                          .map((priority) => ChoiceChip(
                                label: Text(priority.label),
                                selected: draft.priority == priority,
                                selectedColor:
                                    AppColors.primary.withValues(alpha: 0.15),
                                onSelected: (_) =>
                                    draftNotifier.setPriority(priority),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text('Action', style: AppTypography.labelMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: RuleAction.values
                          .map((action) => ChoiceChip(
                                label: Text(action.label),
                                selected: draft.action == action,
                                selectedColor:
                                    AppColors.primary.withValues(alpha: 0.15),
                                onSelected: (_) =>
                                    draftNotifier.setAction(action),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Text('Active', style: AppTypography.bodyMedium),
                        const Spacer(),
                        Switch(
                          value: draft.enabled,
                          activeThumbColor: AppColors.primary,
                          onChanged: draftNotifier.setEnabled,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Text(
                    'Conditions',
                    style: AppTypography.labelMedium
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _GroupModeToggle(
                    mode: draft.conditionGroup.mode,
                    onChanged: draftNotifier.setGroupMode,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final condition in draft.conditionGroup.conditions) ...[
                RuleConditionBuilder(
                  condition: condition,
                  metrics: metrics,
                  onMetricChanged: (value) =>
                      draftNotifier.changeConditionMetric(condition.id, value),
                  onOperatorChanged: (value) => draftNotifier
                      .changeConditionOperator(condition.id, value),
                  onValueChanged: (value) =>
                      draftNotifier.changeConditionValue(condition.id, value),
                  onComparisonModeChanged: (value) => draftNotifier
                      .changeConditionComparisonMode(condition.id, value),
                  onRemove: () => draftNotifier.removeCondition(condition.id),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              AppButton(
                text: 'Ajouter une condition',
                onPressed: draft.availableMetrics.isEmpty
                    ? null
                    : draftNotifier.addCondition,
                variant: AppButtonVariant.outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              if (draft.conditionGroup.conditions.isNotEmpty)
                RuleSummary(rule: draft.toRule()),
              const SizedBox(height: AppSpacing.md),
              if (draft.validationMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    draft.validationMessage!,
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.warning),
                  ),
                ),
              AppButton(
                text: draft.isEditing ? 'Enregistrer' : 'Créer la règle',
                onPressed: !draft.canSave
                    ? null
                    : () async {
                        final saved = draft.isEditing
                            ? await ruleNotifier.updateRule(draft.toRule())
                            : await ruleNotifier.createRule(draft.toRule());
                        if (saved != null && mounted) {
                          context.pop();
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ruleNotifier.state.errorMessage ??
                                  'La règle n\'a pas pu être enregistrée.'),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupModeToggle extends StatelessWidget {
  final ConditionGroupMode mode;
  final ValueChanged<ConditionGroupMode> onChanged;

  const _GroupModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ConditionGroupMode>(
      segments: ConditionGroupMode.values
          .map((m) => ButtonSegment(value: m, label: Text(m.label)))
          .toList(),
      selected: {mode},
      onSelectionChanged: (set) => onChanged(set.first),
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
