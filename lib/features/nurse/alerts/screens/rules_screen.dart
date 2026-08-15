import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_error_state.dart';
import '../providers/rule_provider.dart';
import '../widgets/rule_card.dart';

/// Surveillance rule configuration list.
///
/// Note on permissions: configuring rules is a clinical-governance action. The
/// route that lands here is gated by `canConfigureMonitoringRules` in the
/// router; this screen assumes the caller already passed that check (a TODO
/// tracks wiring real auth there).
class RulesScreen extends ConsumerStatefulWidget {
  const RulesScreen({super.key});

  @override
  ConsumerState<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends ConsumerState<RulesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ruleListProvider.notifier).loadRules());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ruleListProvider);
    final notifier = ref.read(ruleListProvider.notifier);
    final rules = state.filteredRules;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Règles de surveillance'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () =>
                notifier.setShowEnabledOnly(!state.showEnabledOnly),
            child: Text(state.showEnabledOnly ? 'Toutes' : 'Actives'),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
                ? AppErrorState(
                    title: 'Impossible de charger les règles',
                    message: state.errorMessage!,
                    retryLabel: 'Réessayer',
                    onRetry: () => notifier.loadRules(),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Surveillance configurée',
                              style: AppTypography.titleLarge,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '${state.enabledCount} règle${state.enabledCount > 1 ? 's' : ''} active${state.enabledCount > 1 ? 's' : ''} '
                              'sur ${state.rules.length}. Les seuils sont définis avec l\'équipe clinique.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: rules.isEmpty
                            ? const AppEmptyState(
                                title: 'Aucune règle',
                                message:
                                    'Créez une règle pour déclencher des alertes de surveillance.',
                                icon: Icons.rule_outlined,
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount: rules.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: AppSpacing.md),
                                itemBuilder: (context, index) {
                                  final rule = rules[index];
                                  return RuleCard(
                                    rule: rule,
                                    isPending: state.pendingRuleId == rule.id,
                                    onTap: () =>
                                        context.push('/nurse/rules/${rule.id}'),
                                    onToggle: () => notifier.setEnabled(
                                        rule.id, !rule.enabled),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/nurse/rules/new'),
        label: const Text('Nouvelle règle'),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
