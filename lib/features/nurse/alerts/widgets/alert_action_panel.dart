import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../models/alert.dart';
import '../models/alert_status.dart';

/// Nurse-facing controls for an open alert.
///
/// The key design point: the system raised the alert, but the nurse owns the
/// meaning. The panel exposes a full triage flow (acknowledge -> decide ->
/// act -> resolve) and crucially supports *disagreeing* with the system via
/// [NurseDecision.notConcerning], which is only allowed with a written
/// justification. That keeps overrides auditable instead of silent.
class AlertActionPanel extends StatelessWidget {
  final Alert alert;
  final bool isPending;
  final ValueChanged<String>? onError;
  final VoidCallback? onChanged;
  final Future<bool> Function(String alertId) onAcknowledge;
  final Future<bool> Function(
    String alertId, {
    required NurseAction action,
    required NurseDecision decision,
    String? actionNote,
    String? justification,
  }) onRecordAction;
  final Future<bool> Function(String alertId, {String? resolutionNote})
      onResolve;

  const AlertActionPanel({
    super.key,
    required this.alert,
    required this.isPending,
    this.onError,
    this.onChanged,
    required this.onAcknowledge,
    required this.onRecordAction,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    if (alert.status == AlertStatus.resolved) {
      return _ResolvedSummary(alert: alert);
    }

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
          Text(
            'Action de l\'infirmière',
            style:
                AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (alert.status == AlertStatus.unread) ...[
            AppButton(
              text: 'Prendre en charge',
              onPressed: isPending
                  ? null
                  : () async {
                      final ok = await onAcknowledge(alert.id);
                      if (!ok && onError != null) {
                        onError!('L\'alerte n\'a pas pu être prise en charge.');
                      }
                      onChanged?.call();
                    },
              loading: isPending,
            ),
          ] else ...[
            _DecisionForm(
              alert: alert,
              isPending: isPending,
              onError: onError,
              onChanged: onChanged,
              onRecordAction: onRecordAction,
              onResolve: onResolve,
            ),
          ],
        ],
      ),
    );
  }
}

class _ResolvedSummary extends StatelessWidget {
  final Alert alert;

  const _ResolvedSummary({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Alerte résolue',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (alert.nurseDecision != null)
            Text(
              'Décision: ${alert.nurseDecision!.label}',
              style: AppTypography.bodyMedium,
            ),
          if (alert.actionNote != null && alert.actionNote!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Suivi: ${alert.actionNote}',
              style: AppTypography.bodySmall,
            ),
          ],
          if (alert.justification != null &&
              alert.justification!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Justification: ${alert.justification}',
              style: AppTypography.bodySmall,
            ),
          ],
          if (alert.resolutionNote != null &&
              alert.resolutionNote!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Clôture: ${alert.resolutionNote}',
              style: AppTypography.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _DecisionForm extends StatefulWidget {
  final Alert alert;
  final bool isPending;
  final ValueChanged<String>? onError;
  final VoidCallback? onChanged;
  final Future<bool> Function(
    String alertId, {
    required NurseAction action,
    required NurseDecision decision,
    String? actionNote,
    String? justification,
  }) onRecordAction;
  final Future<bool> Function(String alertId, {String? resolutionNote})
      onResolve;

  const _DecisionForm({
    required this.alert,
    required this.isPending,
    this.onError,
    this.onChanged,
    required this.onRecordAction,
    required this.onResolve,
  });

  @override
  State<_DecisionForm> createState() => _DecisionFormState();
}

class _DecisionFormState extends State<_DecisionForm> {
  late NurseDecision _decision;
  late NurseAction _action;
  final _actionNote = TextEditingController();
  final _justification = TextEditingController();
  final _resolutionNote = TextEditingController();

  @override
  void initState() {
    super.initState();
    _decision = widget.alert.nurseDecision ?? NurseDecision.actionRequired;
    _action = widget.alert.nurseAction ?? NurseAction.monitoring;
    _actionNote.text = widget.alert.actionNote ?? '';
    _justification.text = widget.alert.justification ?? '';
    _resolutionNote.text = widget.alert.resolutionNote ?? '';
  }

  @override
  void dispose() {
    _actionNote.dispose();
    _justification.dispose();
    _resolutionNote.dispose();
    super.dispose();
  }

  Future<void> _submitAction() async {
    if (_decision.requiresJustification && _justification.text.trim().isEmpty) {
      widget.onError
          ?.call('Une justification est requise pour cette décision.');
      return;
    }
    if (_action.requiresNote && _actionNote.text.trim().isEmpty) {
      widget.onError?.call('Un commentaire est requis pour cette action.');
      return;
    }

    final ok = await widget.onRecordAction(
      widget.alert.id,
      action: _action,
      decision: _decision,
      actionNote: _actionNote.text.trim(),
      justification: _justification.text.trim(),
    );
    if (!ok && widget.onError != null) {
      widget.onError!('L\'action n\'a pas pu être enregistrée.');
    }
    widget.onChanged?.call();
  }

  Future<void> _resolve() async {
    final ok = await widget.onResolve(
      widget.alert.id,
      resolutionNote: _resolutionNote.text.trim(),
    );
    if (!ok && widget.onError != null) {
      widget.onError!('L\'alerte n\'a pas pu être résolue.');
    }
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final started = widget.alert.status == AlertStatus.inProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Décision', style: AppTypography.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          children: NurseDecision.values
              .map((decision) => ChoiceChip(
                    label: Text(decision.label),
                    selected: _decision == decision,
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    onSelected: (_) => setState(() => _decision = decision),
                  ))
              .toList(),
        ),
        if (_decision.requiresJustification) ...[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _justification,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Justifiez pourquoi l\'alerte n\'est pas préoccupante',
              hintStyle: AppTypography.bodySmall,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        const Text('Action', style: AppTypography.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          children: NurseAction.values
              .map((action) => ChoiceChip(
                    label: Text(action.label),
                    selected: _action == action,
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    onSelected: (_) => setState(() => _action = action),
                  ))
              .toList(),
        ),
        if (_action.requiresNote) ...[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _actionNote,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Commentaire sur l\'action',
              hintStyle: AppTypography.bodySmall,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: started ? 'Mettre à jour' : 'Enregistrer',
                onPressed: widget.isPending ? null : _submitAction,
                loading: widget.isPending,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Résoudre l\'alerte',
                onPressed: widget.isPending ? null : _resolve,
                variant: AppButtonVariant.outlined,
                loading: widget.isPending,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
