import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../models/alert_priority.dart';
import '../models/alert_status.dart';
import '../models/supporting_measurement.dart';

/// Maps domain enums to presentation attributes.
///
/// Colour lives here rather than on the model so the domain layer stays pure
/// Dart and testable without Flutter.
///
/// Accessibility rule for this feature: **priority and status are never
/// communicated by colour alone.** Every mapping supplies an icon and a text
/// label alongside the colour, and all badges render all three. This matters
/// for colour-vision-deficient users and in poor lighting on ward devices.
abstract class AlertVisuals {
  static Color priorityColor(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.high:
        return AppColors.danger;
      case AlertPriority.medium:
        return AppColors.warning;
      case AlertPriority.low:
        return AppColors.info;
      case AlertPriority.informational:
        return AppColors.textSecondary;
    }
  }

  static IconData priorityIcon(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.high:
        return Icons.priority_high_rounded;
      case AlertPriority.medium:
        return Icons.remove_red_eye_outlined;
      case AlertPriority.low:
        return Icons.low_priority_rounded;
      case AlertPriority.informational:
        return Icons.info_outline_rounded;
    }
  }

  static Color statusColor(AlertStatus status) {
    switch (status) {
      case AlertStatus.unread:
        return AppColors.danger;
      case AlertStatus.acknowledged:
        return AppColors.warning;
      case AlertStatus.inProgress:
        return AppColors.primary;
      case AlertStatus.resolved:
        return AppColors.success;
    }
  }

  static IconData statusIcon(AlertStatus status) {
    switch (status) {
      case AlertStatus.unread:
        return Icons.mark_email_unread_outlined;
      case AlertStatus.acknowledged:
        return Icons.assignment_ind_outlined;
      case AlertStatus.inProgress:
        return Icons.hourglass_top_rounded;
      case AlertStatus.resolved:
        return Icons.check_circle_outline_rounded;
    }
  }

  static IconData trendIcon(MeasurementTrend trend) {
    switch (trend) {
      case MeasurementTrend.up:
        return Icons.trending_up_rounded;
      case MeasurementTrend.down:
        return Icons.trending_down_rounded;
      case MeasurementTrend.stable:
        return Icons.trending_flat_rounded;
      case MeasurementTrend.unknown:
        return Icons.help_outline_rounded;
    }
  }

  /// Trend is rendered in a neutral tone on purpose.
  ///
  /// Colouring a downward trend red would be the UI asserting that the change
  /// is clinically bad — that judgement belongs to the nurse, not the frontend.
  static Color trendColor(MeasurementTrend trend) {
    switch (trend) {
      case MeasurementTrend.up:
      case MeasurementTrend.down:
        return AppColors.textPrimary;
      case MeasurementTrend.stable:
      case MeasurementTrend.unknown:
        return AppColors.textSecondary;
    }
  }
}
