import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../providers/rule_provider.dart';
import '../widgets/alert_priority_badge.dart';
import '../widgets/rule_condition_card.dart';
import '../widgets/rule_summary.dart';

/// Read-only view of a single configured rule.
class RuleDetailScreen extends ConsumerStatefulWidget {
  final String ruleId;

  const RuleDetailScreen({super.key, required this.ruleId});

  @override
  ConsumerState<RuleDetailScreen> createState() => _RuleDetailScreenState();
}

class _RuleDetailScreenState extends ConsumerState<RuleDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(ruleListProvider.notifier);
      if (notifier.ruleById(widget.ruleId) == null) {
        notifier.loadRules();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rule = ref.watch(ruleByIdProvider(widget.ruleId));
    final state = ref.watch(ruleListProvider);

    if (rule == null) {
      if (state.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Règle')),
        body: AppErrorState(
          title: 'Règle introuvable',
          message: 'Cette règle n\'existe plus ou n\'a pas pu être chargée.',
          retryLabel: 'Recharger',
          onRetry: () => ref.read(ruleListProvider.notifier).loadRules(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Règle de surveillance'),
        backgroundColor: AppColors.surface,
        elevation: 0,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(rule.name, style: AppTypography.titleLarge),
                      ),
                      AlertPriorityBadge(priority: rule.priority),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    rule.description,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _Tag(label: rule.statusLabel, color: AppColors.success),
                      const SizedBox(width: AppSpacing.sm),
                      _Tag(label: rule.action.label, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      _Tag(
                        label: rule.conditionGroup.mode.label,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            RuleSummary(rule: rule),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Conditions',
              style: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final condition in rule.conditionGroup.conditions) ...[
              RuleConditionCard(condition: condition),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: 'Modifier',
              onPressed: () => context.push('/nurse/rules/${rule.id}/edit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium
            .copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
