import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/colors.dart';
import '../../../../core/components/feedback/respi_badge.dart';
import '../../../../core/theme/tokens/respi_colors.dart';
import '../../../../core/theme/tokens/respi_shapes.dart';
import '../../../../core/theme/tokens/respi_spacing.dart';
import '../../../../core/theme/tokens/respi_typography.dart';
import '../../../../core/utils/date/app_date_format.dart';
import '../models/nurse_worklist_item.dart';

/// Reusable row for a single nurse worklist item.
///
/// Renders the patient name, item title/description, status label, and a
/// relative timestamp. The card is tappable only when the item already has an
/// existing [NurseWorklistItem.actionRoute] pointing at a real route
/// (route_names.dart). Cards with no action route render as static content —
/// no fake/finctional buttons are created.
class WorklistItemCard extends StatelessWidget {
  final NurseWorklistItem item;

  const WorklistItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final background = isDark ? RespiColors.cardDark : RespiColors.card;
    final outline = isDark ? RespiColors.borderDark : RespiColors.border;
    final foregroundMuted =
        isDark ? RespiColors.mutedForegroundDark : RespiColors.mutedForeground;

    final typeInfo = _typeInfo(item.type);
    final timeLabel = AppDateFormat.shortRelative(item.timestamp);

    // No fake buttons: tappable only when an existing route is present.
    final bool isNavigable = item.actionRoute != null;

    return Semantics(
      button: isNavigable,
      container: true,
      // Single coherent label for screen readers.
      label: _semanticLabel(),
      onTap: isNavigable ? () => _openRoute(context) : null,
      child: InkWell(
        onTap: isNavigable ? () => _openRoute(context) : null,
        borderRadius: RespiShapes.mdRadius,
        child: Container(
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: outline, width: 1),
            borderRadius: RespiShapes.mdRadius,
          ),
          // The semantic label above fully describes the card's content, so
          // inner Text/badge/icon nodes are excluded to avoid double-announcement.
          child: ExcludeSemantics(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: RespiSpacing.md,
                vertical: RespiSpacing.sm,
              ),
              leading: CircleAvatar(
                backgroundColor: typeInfo.color.withValues(alpha: 0.12),
                foregroundColor: typeInfo.color,
                child: Icon(typeInfo.icon, size: 20),
              ),
              title: Text(
                item.patientName,
                style: RespiTypography.titleMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: RespiSpacing.xs),
                  Text(
                    item.title,
                    style: RespiTypography.bodyMedium
                        .copyWith(color: foregroundMuted),
                  ),
                  if (item.description != null && item.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: RespiSpacing.xs),
                      child: Text(
                        item.description!,
                        style: RespiTypography.bodySmall.copyWith(
                            color: foregroundMuted.withValues(alpha: 0.85)),
                      ),
                    ),
                  const SizedBox(height: RespiSpacing.xs),
                  Wrap(
                    spacing: RespiSpacing.xs,
                    runSpacing: RespiSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _PriorityBadge(priorityRank: item.priorityRank),
                      RespiBadge(
                        label: item.statusLabel,
                        variant: item.isActionable
                            ? RespiBadgeVariant.warning
                            : RespiBadgeVariant.neutral,
                      ),
                      Text(
                        timeLabel,
                        style: RespiTypography.bodySmall.copyWith(
                            color: foregroundMuted.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: isNavigable
                  ? Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: foregroundMuted.withValues(alpha: 0.5),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  /// Plain-language summary for screen-reader users.
  String _semanticLabel() {
    final priorityLabel = _priorityLabel(item.priorityRank);
    return '${item.patientName}. ${item.title}. '
        '${item.description?.isNotEmpty == true ? '${item.description}. ' : ''}'
        'Priorité $priorityLabel. ${item.statusLabel}. ${AppDateFormat.shortRelative(item.timestamp)}.';
  }

  void _openRoute(BuildContext context) {
    final route = item.actionRoute;
    if (route == null) return;
    GoRouter.of(context).push(route);
  }
}

/// Nurse-friendly priority label for a worklist item's rank.
/// Rank 0 = highest priority, higher ranks = lower priority.
String _priorityLabel(int rank) {
  switch (rank) {
    case 0:
      return 'Urgent';
    case 1:
      return 'Élevée';
    case 2:
      return 'Modérée';
    case 3:
      return 'Faible';
    default:
      return 'Priorité';
  }
}

/// Priority badge for worklist items.
///
/// Displays the priority rank as a small badge. Priority is derived from the
/// underlying domain (alert priority, rule priority, or fixed task default).
/// When priorityRank is null, no badge is shown (e.g. for items without a
/// supported priority model).
class _PriorityBadge extends StatelessWidget {
  final int priorityRank;

  const _PriorityBadge({required this.priorityRank});

  @override
  Widget build(BuildContext context) {
    // Map priorityRank to a nurse-friendly label and color.
    final label = _priorityLabel(priorityRank);
    final variant = _priorityVariant(priorityRank);

    return RespiBadge(
      label: label,
      variant: variant,
    );
  }

  RespiBadgeVariant _priorityVariant(int rank) {
    switch (rank) {
      case 0:
        return RespiBadgeVariant.error;
      case 1:
        return RespiBadgeVariant.warning;
      case 2:
        return RespiBadgeVariant.info;
      case 3:
        return RespiBadgeVariant.neutral;
      default:
        return RespiBadgeVariant.neutral;
    }
  }
}

class _TypeInfo {
  final IconData icon;
  final Color color;
  const _TypeInfo({required this.icon, required this.color});
}

_TypeInfo _typeInfo(NurseWorklistItemType type) {
  switch (type) {
    case NurseWorklistItemType.alert:
      return const _TypeInfo(
          icon: Icons.campaign_outlined, color: RespiColors.destructive);
    case NurseWorklistItemType.task:
      return const _TypeInfo(icon: Icons.task_outlined, color: AppColors.info);
    case NurseWorklistItemType.monitoring:
      return const _TypeInfo(
          icon: Icons.monitor_heart_outlined, color: RespiColors.warning);
  }
}
