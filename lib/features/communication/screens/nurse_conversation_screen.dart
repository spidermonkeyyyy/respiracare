import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../../../core/widgets/feedback/app_empty_state.dart';
import '../../nurse/alerts/models/alert_status.dart';
import '../../nurse/alerts/providers/alert_provider.dart';
import '../../nurse/patients/models/nurse_patient.dart';
import '../../nurse/patients/providers/nurse_patients_provider.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../providers/nurse_messages_provider.dart';
import '../widgets/care_request_card.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_composer.dart';
import '../widgets/patient_context_panel.dart';

/// Nurse conversation view (step 4.10H / 4.10I / 4.10J / 4.10S).
///
/// Keeps the nurse in context: a [PatientContextPanel], the conversation, care
/// requests, a strictly separated internal-notes area, and a care timeline.
/// Internal notes are rendered apart from patient messages so they can never
/// leak into the patient view (step 4.10Q / 4.10R).
class NurseConversationScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const NurseConversationScreen({super.key, required this.conversationId});

  @override
  ConsumerState<NurseConversationScreen> createState() =>
      _NurseConversationScreenState();
}

class _NurseConversationScreenState
    extends ConsumerState<NurseConversationScreen> {
  NursePatient? _patient;
  int _activeAlerts = 0;
  bool _noteExpanded = false;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final notifier = ref.read(nurseMessagesProvider.notifier);
      await notifier.openConversation(widget.conversationId);

      final conversation = _currentConversation();
      if (conversation == null) return;
      await _loadContext(conversation.patientId);
    });
  }

  Conversation? _currentConversation() {
    final conversations = ref.read(nurseMessagesProvider).conversations;
    final matches =
        conversations.where((c) => c.id == widget.conversationId).toList();
    return matches.isEmpty ? null : matches.first;
  }

  Future<void> _loadContext(String patientId) async {
    final patientRepo = ref.read(nursePatientRepositoryProvider);
    final alertRepo = ref.read(alertRepositoryProvider);
    final patient = await patientRepo.getPatient(patientId);
    final alerts = await alertRepo.getAlerts();
    final active = alerts
        .where(
            (a) => a.patientId == patientId && a.status != AlertStatus.resolved)
        .length;

    if (mounted) {
      setState(() {
        _patient = patient;
        _activeAlerts = active;
      });
    }
  }

  String get _latestSpo2 {
    final spo2 = _patient?.latestSubmission?.spo2;
    return spo2 == null ? '—' : '$spo2 %';
  }

  String get _latestDyspnea {
    final score = _patient?.latestSubmission?.dyspneaScore;
    if (score != null) return 'mMRC $score';
    return _patient?.latestObservation ?? '—';
  }

  int get _adherenceRate {
    final adherence = _patient?.adherence;
    return adherence == null ? 0 : (adherence.weeklyCompliance * 100).round();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nurseMessagesProvider);
    final notifier = ref.read(nurseMessagesProvider.notifier);
    final conversation = _currentConversation();

    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Conversation')),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : const AppEmptyState(
                title: 'Conversation introuvable',
                message: 'Cette conversation n\'est plus disponible.',
              ),
      );
    }

    final timeline = _buildTimeline(conversation);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(conversation.patientName),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        if (_patient != null)
                          PatientContextPanel(
                            patientName: _patient!.fullName,
                            latestSpo2: _latestSpo2,
                            latestDyspnea: _latestDyspnea,
                            activeAlertCount: _activeAlerts,
                            adherenceRate: _adherenceRate,
                            patientId: conversation.patientId,
                          ),
                        const SizedBox(height: AppSpacing.md),
                        _ActionsCard(
                          onRequestMonitoring: () => context.push(
                            '/nurse/messages/${conversation.id}/request?type=newMonitoring',
                          ),
                          onRequestVideo: () => context.push(
                            '/nurse/messages/${conversation.id}/request?type=inhalerVideo',
                          ),
                          onAddNote: () => setState(() => _noteExpanded = true),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _MessagesSection(conversation: conversation),
                        if (conversation.careRequests.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          const Text('Demandes de soins',
                              style: AppTypography.titleLarge),
                          const SizedBox(height: AppSpacing.sm),
                          for (final request in conversation.careRequests)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: CareRequestCard(
                                request: request,
                                onComplete: () =>
                                    notifier.completeCareRequest(request.id),
                              ),
                            ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        _InternalNotesSection(
                          notes: conversation.internalNotes,
                          expanded: _noteExpanded,
                          controller: _noteController,
                          onSave: () async {
                            final ok = await notifier.addInternalNote(
                              conversation.id,
                              _noteController.text,
                            );
                            if (ok && mounted) {
                              _noteController.clear();
                              setState(() => _noteExpanded = false);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _TimelineSection(events: timeline),
                      ],
                    ),
                  ),
                  MessageComposer(
                    onSend: (text) =>
                        notifier.sendMessage(conversation.id, text),
                    hintText: 'Écrire à l\'équipe soignante...',
                  ),
                ],
              ),
      ),
    );
  }

  List<CareTimelineEvent> _buildTimeline(Conversation conversation) {
    final events = <CareTimelineEvent>[];

    for (final message in conversation.messages) {
      events.add(CareTimelineEvent(
        id: 'ev_${message.id}',
        type: CareEventType.message,
        title: message.isFromPatient ? 'Message patient' : 'Réponse équipe',
        timestamp: message.createdAt,
        detail: message.text,
      ));
    }

    for (final request in conversation.careRequests) {
      events.add(CareTimelineEvent(
        id: 'ev_${request.id}',
        type: CareEventType.monitoringRequested,
        title: 'Demande: ${request.type.label}',
        timestamp: request.createdAt,
        detail: request.reason,
      ));
    }

    for (final note in conversation.internalNotes) {
      events.add(CareTimelineEvent(
        id: 'ev_${note.id}',
        type: CareEventType.internalNote,
        title: 'Note interne',
        timestamp: note.createdAt,
        detail: note.text,
      ));
    }

    events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return events;
  }
}

class _ActionsCard extends StatelessWidget {
  final VoidCallback onRequestMonitoring;
  final VoidCallback onRequestVideo;
  final VoidCallback onAddNote;

  const _ActionsCard({
    required this.onRequestMonitoring,
    required this.onRequestVideo,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actions',
              style: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ActionChip(
                icon: Icons.monitor_heart_outlined,
                label: 'Demander un nouveau suivi',
                onTap: onRequestMonitoring,
              ),
              _ActionChip(
                icon: Icons.videocam_outlined,
                label: 'Demander une vidéo',
                onTap: onRequestVideo,
              ),
              _ActionChip(
                icon: Icons.note_add_outlined,
                label: 'Consigner un contact',
                onTap: onAddNote,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.0, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style:
                  AppTypography.labelMedium.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesSection extends StatelessWidget {
  final Conversation conversation;

  const _MessagesSection({required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Conversation', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        if (conversation.messages.isEmpty)
          const AppEmptyState(
            title: 'Aucun message',
            message: 'Démarrez la conversation avec le patient.',
            icon: Icons.chat_bubble_outline_rounded,
          )
        else
          for (final message in conversation.messages)
            MessageBubble(message: message),
      ],
    );
  }
}

class _InternalNotesSection extends StatelessWidget {
  final List<InternalNote> notes;
  final bool expanded;
  final TextEditingController controller;
  final VoidCallback onSave;

  const _InternalNotesSection({
    required this.notes,
    required this.expanded,
    required this.controller,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor: AppColors.warning.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: 16.0, color: AppColors.warning),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Notes internes',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Text(
            'Non visible par le patient.',
            style:
                AppTypography.labelMedium.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final note in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(note.text, style: AppTypography.bodyMedium),
              ),
            ),
          if (expanded) ...[
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Note interne (ex. contact consigné, escalade)...',
                hintStyle: AppTypography.bodySmall,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Enregistrer la note',
                onPressed: controller.text.trim().isEmpty ? null : onSave,
                variant: AppButtonVariant.outlined,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  final List<CareTimelineEvent> events;

  const _TimelineSection({required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chronologie des soins', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        if (events.isEmpty)
          const AppEmptyState(
            title: 'Aucun événement',
            message: 'La chronologie apparaîtra ici.',
            icon: Icons.timeline_outlined,
          )
        else
          for (final event in events)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(event.type.icon,
                      size: 18.0, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${event.title} · ${_format(event.timestamp)}',
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (event.detail != null)
                          Text(
                            event.detail!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  String _format(DateTime value) {
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')} · $time';
  }
}
