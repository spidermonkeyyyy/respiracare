import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/utils/animations/app_animations.dart';
import '../../../core/utils/date/app_date_format.dart';
import '../models/message.dart';
import '../models/message_status.dart';
import '../models/message_type.dart';

/// A single message bubble.
///
/// Alignment follows the sender (patient left, care team right, system
/// centred) so the conversation reads naturally. Care-update / follow-up
/// messages may carry an action button that opens an existing workflow.
class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onAction;

  const MessageBubble({
    super.key,
    required this.message,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (message.sender == MessageSender.system) {
      return _SystemBubble(message: message);
    }

    final isCareTeam = message.sender.isCareTeam;

    return AppFadeAnimation(
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          mainAxisAlignment:
              isCareTeam ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color:
                      isCareTeam ? AppColors.primary : AppColors.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(AppRadius.medium).subtract(
                    BorderRadius.only(
                      bottomLeft: isCareTeam
                          ? const Radius.circular(AppRadius.medium)
                          : Radius.zero,
                      bottomRight: isCareTeam
                          ? Radius.zero
                          : const Radius.circular(AppRadius.medium),
                    ),
                  ),
                  border:
                      isCareTeam ? null : Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.type != MessageType.text)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              message.type.icon,
                              size: 14.0,
                              color: isCareTeam
                                  ? AppColors.surface
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              message.type.label,
                              style: AppTypography.labelMedium.copyWith(
                                color: isCareTeam
                                    ? AppColors.surface.withValues(alpha: 0.85)
                                    : AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      message.text,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isCareTeam
                            ? AppColors.surface
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppDateFormat.friendlyTimestamp(message.createdAt),
                          style: AppTypography.labelMedium.copyWith(
                            color: isCareTeam
                                ? AppColors.surface.withValues(alpha: 0.8)
                                : AppColors.textMuted,
                            fontSize: 11.0,
                          ),
                        ),
                        if (isCareTeam) ...[
                          const SizedBox(width: 4.0),
                          Icon(
                            message.status.icon,
                            size: 14.0,
                            color: message.status == MessageStatus.read
                                ? AppColors.surface.withValues(alpha: 0.85)
                                : AppColors.surface.withValues(alpha: 0.6),
                          ),
                        ],
                      ],
                    ),
                    if (message.hasAction) ...[
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onAction,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isCareTeam
                                ? AppColors.surface
                                : AppColors.primary,
                            side: BorderSide(
                              color: isCareTeam
                                  ? AppColors.surface.withValues(alpha: 0.6)
                                  : AppColors.primary,
                            ),
                          ),
                          child: Text(message.actionLabel!),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemBubble extends StatelessWidget {
  final Message message;

  const _SystemBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(message.type.icon,
                  size: 14.0, color: AppColors.textSecondary),
              const SizedBox(width: 4.0),
              Flexible(
                child: Text(
                  message.text,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
