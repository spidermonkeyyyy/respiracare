import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/widgets/feedback/app_empty_state.dart';
import '../../../core/widgets/feedback/app_error_state.dart';
import '../models/communication_task.dart';
import '../providers/patient_messages_provider.dart';
import '../widgets/conversation_card.dart';
import '../widgets/task_card.dart';

/// Patient messaging home (step 4.10B).
///
/// Shows the single care-team conversation plus the patient's "À faire" tasks,
/// so requested actions are never buried in chat (step 4.10M).
class PatientMessagesScreen extends ConsumerStatefulWidget {
  const PatientMessagesScreen({super.key});

  @override
  ConsumerState<PatientMessagesScreen> createState() =>
      _PatientMessagesScreenState();
}

class _PatientMessagesScreenState extends ConsumerState<PatientMessagesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(patientMessagesProvider.notifier);
      if (notifier.state.conversation == null) notifier.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientMessagesProvider);
    final notifier = ref.read(patientMessagesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
                ? AppErrorState(
                    title: 'Impossible de charger vos messages',
                    message: state.errorMessage!,
                    retryLabel: 'Réessayer',
                    onRetry: notifier.load,
                  )
                : state.conversation == null
                    ? const AppEmptyState(
                        title: 'Aucun message pour le moment.',
                        message: 'Votre équipe soignante vous contactera ici.',
                        icon: Icons.chat_bubble_outline_rounded,
                      )
                    : ListView(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        children: [
                          ConversationCard(
                            conversation: state.conversation!,
                            isPatientView: true,
                            onTap: () => context.push(
                                '/patient/messages/${state.conversation!.id}'),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _TasksSection(
                            tasks: state.tasks,
                            onComplete: notifier.completeTask,
                          ),
                        ],
                      ),
      ),
    );
  }
}

class _TasksSection extends StatelessWidget {
  final List<CommunicationTask> tasks;
  final ValueChanged<String> onComplete;

  const _TasksSection({required this.tasks, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final open = tasks.where((task) => task.status.isOpen).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.checklist_rounded, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'À faire',
              style: AppTypography.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (open.isEmpty)
          const AppEmptyState(
            title: 'Aucune action à effectuer.',
            message: 'Votre équipe vous demandera ici ce qu\'il faut faire.',
            icon: Icons.check_circle_outline_rounded,
          )
        else
          for (final task in open)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: TaskCard(
                task: task,
                onComplete: () => onComplete(task.id),
              ),
            ),
      ],
    );
  }
}
