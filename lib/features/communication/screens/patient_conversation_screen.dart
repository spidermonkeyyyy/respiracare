import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../providers/patient_messages_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_composer.dart';

/// Patient conversation view (step 4.10C / 4.10F).
///
/// Shows the care-team conversation with a clear non-emergency disclaimer and
/// a composer. Patient-visible messages only — internal notes never reach
/// here (enforced by the repository and by this provider scope).
class PatientConversationScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const PatientConversationScreen({super.key, required this.conversationId});

  @override
  ConsumerState<PatientConversationScreen> createState() =>
      _PatientConversationScreenState();
}

class _PatientConversationScreenState
    extends ConsumerState<PatientConversationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(patientMessagesProvider.notifier);
      notifier.openConversation(widget.conversationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientMessagesProvider);
    final notifier = ref.read(patientMessagesProvider.notifier);

    final matches = state.conversations
        .where((c) => c.id == widget.conversationId)
        .toList();
    final conversation = matches.isEmpty ? null : matches.first;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => context.pop(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Équipe soignante'),
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          automaticallyImplyLeading: true,
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : conversation == null
                ? const Center(child: Text('Conversation introuvable.'))
                : Column(
                    children: [
                      _DisclaimerBanner(),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: conversation.messages.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.xs),
                          itemBuilder: (context, index) {
                            final message = conversation.messages[index];
                            return MessageBubble(
                              message: message,
                              onAction:
                                  message.hasAction && message.actionRoute != null
                                      ? () => context.push(message.actionRoute!)
                                      : null,
                            );
                          },
                        ),
                      ),
                      MessageComposer(
                        onSend: (text) => notifier.sendMessage(text),
                      ),
                    ],
                  ),
      ),
    );
  }
}

/// Non-emergency disclaimer (step 4.10F).
///
/// TODO(clinical-copy): wording must be reviewed and made configurable with the
/// clinical supervisor before release.
class _DisclaimerBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.warning, size: 18.0),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Cette messagerie est destinée au suivi habituel et ne remplace '
              'pas les services d\'urgence.',
              style:
                  AppTypography.labelMedium.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}