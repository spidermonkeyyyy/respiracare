import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/utils/date/app_date_format.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/conversation.dart';

/// A conversation row for the nurse list (and the single care-team row the
/// patient sees).
///
/// Unread state is conveyed with both a dot **and** a text label so it is never
/// colour-only (step 4.10N).
class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final int unreadCount;
  final bool isPatientView;
  final VoidCallback? onTap;

  const ConversationCard({
    super.key,
    required this.conversation,
    this.unreadCount = 0,
    this.isPatientView = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        isPatientView ? 'Équipe de pneumologie' : conversation.patientName;
    final subtitle = isPatientView
        ? conversation.patientSummary
        : conversation.lastMessagePreview;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor: unreadCount > 0
          ? AppColors.primary.withValues(alpha: 0.35)
          : AppColors.border,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style:
                            AppTypography.titleLarge.copyWith(fontSize: 16.0),
                      ),
                    ),
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.circle,
                                size: 8.0, color: AppColors.danger),
                            const SizedBox(width: 4.0),
                            Text(
                              'Non lu',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppDateFormat.friendlyTimestamp(conversation.updatedAt),
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

/// Helper so screens can push a conversation without duplicating the route.
void openConversation(BuildContext context, Conversation conversation,
    {bool patient = false}) {
  context.push(
    patient
        ? '/patient/messages/${conversation.id}'
        : '/nurse/messages/${conversation.id}',
  );
}
