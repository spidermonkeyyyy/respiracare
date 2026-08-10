import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/widgets/feedback/app_empty_state.dart';
import '../../../core/widgets/feedback/app_error_state.dart';
import '../providers/nurse_messages_provider.dart';
import '../widgets/conversation_card.dart';

/// Nurse conversation list (step 4.10G).
///
/// Searchable, with a short filter set, and an unread indicator that is never
/// colour-only.
class NurseMessagesScreen extends ConsumerStatefulWidget {
  const NurseMessagesScreen({super.key});

  @override
  ConsumerState<NurseMessagesScreen> createState() =>
      _NurseMessagesScreenState();
}

class _NurseMessagesScreenState extends ConsumerState<NurseMessagesScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nurseMessagesProvider);
    final notifier = ref.read(nurseMessagesProvider.notifier);
    final conversations = state.filteredConversations;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (state.totalUnread > 0)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '${state.totalUnread} non lu${state.totalUnread > 1 ? 's' : ''}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
                ? AppErrorState(
                    title: 'Impossible de charger les conversations',
                    message: state.errorMessage!,
                    retryLabel: 'Réessayer',
                    onRetry: notifier.load,
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Rechercher',
                            prefixIcon: const Icon(Icons.search_rounded),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.medium),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                          ),
                          onChanged: notifier.search,
                        ),
                      ),
                      _FilterRow(
                        current: state.filter,
                        onChanged: notifier.setFilter,
                      ),
                      Expanded(
                        child: conversations.isEmpty
                            ? AppEmptyState(
                                title: state.filter ==
                                        NurseConversationFilter.unread
                                    ? 'Aucun nouveau message.'
                                    : 'Aucune conversation.',
                                message: 'Les messages des patients suivis '
                                    'apparaîtront ici.',
                                icon: Icons.chat_bubble_outline_rounded,
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount: conversations.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: AppSpacing.md),
                                itemBuilder: (context, index) {
                                  final conversation = conversations[index];
                                  return ConversationCard(
                                    conversation: conversation,
                                    unreadCount: state.unreadFor(conversation),
                                    onTap: () => context.push(
                                        '/nurse/messages/${conversation.id}'),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final NurseConversationFilter current;
  final ValueChanged<NurseConversationFilter> onChanged;

  const _FilterRow({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: NurseConversationFilter.values
            .map((filter) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(filter.label),
                    selected: current == filter,
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    onSelected: (_) => onChanged(filter),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
