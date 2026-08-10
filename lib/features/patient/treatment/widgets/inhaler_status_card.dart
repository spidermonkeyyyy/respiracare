import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/inhaler_video.dart';

class InhalerStatusCard extends StatelessWidget {
  final InhalerVideo? latestSubmission;
  final VoidCallback onSubmitVideo;
  final VoidCallback onReviewDetails;

  const InhalerStatusCard({
    super.key,
    required this.latestSubmission,
    required this.onSubmitVideo,
    required this.onReviewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (latestSubmission == null) {
      return _buildEmptyCard(context);
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vérification de votre technique',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                latestSubmission!.reviewStatus == VideoReviewStatus.reviewed
                    ? Icons.verified
                    : latestSubmission!.reviewStatus == VideoReviewStatus.pendingReview
                        ? Icons.hourglass_empty
                        : Icons.refresh,
                color: latestSubmission!.reviewStatus == VideoReviewStatus.reviewed
                    ? AppColors.success
                    : AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      latestSubmission!.reviewStatus.patientLabel,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      latestSubmission!.reviewStatus == VideoReviewStatus.reviewed
                          ? 'Date : ${_formatDate(latestSubmission!.reviewedAt)}'
                          : 'Votre infirmier examinera votre vidéo.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onReviewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Voir les détails'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: onSubmitVideo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Enregistrer une vidéo'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vérification de votre technique',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enregistrez une courte vidéo montrant comment vous utilisez votre dispositif.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: 'Commencer l’enregistrement',
            onPressed: onSubmitVideo,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '—';
    final monthNames = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${dateTime.day} ${monthNames[dateTime.month - 1]} ${dateTime.year}';
  }
}
