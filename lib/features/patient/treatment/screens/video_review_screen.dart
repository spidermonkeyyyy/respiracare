import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/inhaler_video.dart';

class VideoReviewScreen extends StatelessWidget {
  final InhalerVideo video;

  const VideoReviewScreen({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statut de la vidéo'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Technique d’inhalation',
                    style: AppTypography.titleLarge),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(
                      video.reviewStatus == VideoReviewStatus.reviewed
                          ? Icons.verified
                          : video.reviewStatus ==
                                  VideoReviewStatus.pendingReview
                              ? Icons.hourglass_empty
                              : Icons.refresh,
                      size: 28.0,
                      color: video.reviewStatus == VideoReviewStatus.reviewed
                          ? AppColors.success
                          : AppColors.secondary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(video.reviewStatus.patientLabel,
                              style: AppTypography.titleMedium),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _statusSubtitle(video),
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Détails de la vidéo',
                    style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                _infoRow('Envoyée le', _formattedDate(video.uploadedAt)),
                if (video.reviewedAt != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _infoRow('Date de revue', _formattedDate(video.reviewedAt!)),
                ],
                if (video.reviewerNote != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Text('Note de l’infirmier',
                      style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(video.reviewerNote!, style: AppTypography.bodyMedium),
                ],
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusSubtitle(InhalerVideo video) {
    switch (video.reviewStatus) {
      case VideoReviewStatus.pendingReview:
        return 'Votre infirmier examine votre vidéo.';
      case VideoReviewStatus.reviewed:
        return 'Votre infirmier a validé votre technique.';
      case VideoReviewStatus.retryRequested:
        return 'Votre équipe souhaite une nouvelle vidéo.';
    }
  }

  String _formattedDate(DateTime dateTime) {
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

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTypography.bodyMedium),
      ],
    );
  }
}
