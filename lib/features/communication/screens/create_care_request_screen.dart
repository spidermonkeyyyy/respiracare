import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../models/care_request.dart';
import '../providers/nurse_messages_provider.dart';

/// Screen to raise a care request (step 4.10K / 4.10L).
///
/// The request and its matching patient task are created together by the
/// repository, so the patient sees an actionable item rather than a chat
/// message to hunt for. No clinical recommendation is encoded here — only the
/// nurse's reason text, captured verbatim.
class CreateCareRequestScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const CreateCareRequestScreen({super.key, required this.conversationId});

  @override
  ConsumerState<CreateCareRequestScreen> createState() =>
      _CreateCareRequestScreenState();
}

class _CreateCareRequestScreenState
    extends ConsumerState<CreateCareRequestScreen> {
  final _reason = TextEditingController();
  final Set<String> _requestedData = {'spo2', 'dyspnea'};
  int _dueOffsetDays = 1;
  bool _dueInitialized = false;

  static const List<(String, int)> _dueOptions = [
    ('Aujourd\'hui', 0),
    ('Demain', 1),
    ('Dans 2 jours', 2),
    ('Dans 7 jours', 7),
  ];

  static const List<(String, String)> _dataOptions = [
    ('Saturation', 'spo2'),
    ('Dyspnée', 'dyspnea'),
    ('Toux', 'cough'),
    ('Expectorations', 'sputum'),
  ];

  CareRequestType _parseType(String? typeParam) {
    return switch (typeParam) {
      'inhalerVideo' => CareRequestType.inhalerVideo,
      'other' => CareRequestType.other,
      _ => CareRequestType.newMonitoring,
    };
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type =
        _parseType(GoRouterState.of(context).uri.queryParameters['type']);
    if (!_dueInitialized) {
      _dueOffsetDays = type == CareRequestType.inhalerVideo ? 0 : 1;
      _dueInitialized = true;
    }

    final notifier = ref.read(nurseMessagesProvider.notifier);
    final conversation = ref
        .read(nurseMessagesProvider)
        .conversations
        .where((c) => c.id == widget.conversationId)
        .firstOrNull;

    final canSubmit = _reason.text.trim().isNotEmpty && conversation != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(type.label),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Motif',
              style: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _reason,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Précisez la raison de la demande',
                hintStyle: AppTypography.bodySmall,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
              ),
            ),
            if (type == CareRequestType.newMonitoring) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Données demandées',
                style: AppTypography.labelMedium
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              ..._dataOptions.map((option) {
                return CheckboxListTile(
                  value: _requestedData.contains(option.$2),
                  title: Text(option.$1),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _requestedData.add(option.$2);
                      } else {
                        _requestedData.remove(option.$2);
                      }
                    });
                  },
                );
              }),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              'Échéance',
              style: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: DropdownButton<int>(
                value: _dueOffsetDays,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                items: _dueOptions
                    .map((option) => DropdownMenuItem(
                          value: option.$2,
                          child: Text(option.$1),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _dueOffsetDays = value ?? 1),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: 'Envoyer la demande',
              onPressed: canSubmit
                  ? () async {
                      final goRouter = GoRouter.of(context);
                      final ok = await notifier.createCareRequest(
                        conversationId: widget.conversationId,
                        patientId: conversation.patientId,
                        type: type,
                        reason: _reason.text,
                        requestedData: _requestedData.toList(),
                        dueDate:
                            DateTime.now().add(Duration(days: _dueOffsetDays)),
                      );
                      if (ok && mounted) goRouter.pop();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
