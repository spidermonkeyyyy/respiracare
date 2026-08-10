import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../providers/video_submission_provider.dart';

class VideoSubmissionStatus extends StatelessWidget {
  final SubmissionStatus status;
  final String? message;

  const VideoSubmissionStatus({
    super.key,
    required this.status,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _statusIcon;
    final color = _statusColor;
    final title = _statusTitle;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28.0, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message!,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData get _statusIcon {
    switch (status) {
      case SubmissionStatus.requestingPermission:
      case SubmissionStatus.recording:
      case SubmissionStatus.uploading:
        return Icons.videocam;
      case SubmissionStatus.previewing:
      case SubmissionStatus.success:
        return Icons.check_circle_outline_rounded;
      case SubmissionStatus.permissionDenied:
      case SubmissionStatus.error:
        return Icons.error_outline;
      case SubmissionStatus.idle:
        return Icons.photo_camera_outlined;
    }
  }

  Color get _statusColor {
    switch (status) {
      case SubmissionStatus.success:
        return AppColors.success;
      case SubmissionStatus.error:
      case SubmissionStatus.permissionDenied:
        return AppColors.danger;
      case SubmissionStatus.recording:
      case SubmissionStatus.uploading:
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _statusTitle {
    switch (status) {
      case SubmissionStatus.idle:
        return 'Vidéo prête à être enregistrée';
      case SubmissionStatus.requestingPermission:
        return 'Demande d’accès à la caméra';
      case SubmissionStatus.permissionDenied:
        return 'Accès à la caméra refusé';
      case SubmissionStatus.recording:
        return 'Enregistrement en cours';
      case SubmissionStatus.previewing:
        return 'Prévisualisation de la vidéo';
      case SubmissionStatus.uploading:
        return 'Transmission en cours...';
      case SubmissionStatus.success:
        return 'Vidéo envoyée';
      case SubmissionStatus.error:
        return 'Erreur lors de l’envoi';
    }
  }
}
