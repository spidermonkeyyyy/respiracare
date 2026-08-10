import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/educational_video.dart';
import '../../../../features/authentication/providers/auth_provider.dart';
import '../providers/video_submission_provider.dart';
import '../widgets/educational_video_card.dart';
import '../widgets/educational_video_player.dart';
import '../widgets/inhaler_status_card.dart';
import 'video_review_screen.dart';
import 'video_submission_screen.dart';

class InhalerEducationScreen extends ConsumerStatefulWidget {
  const InhalerEducationScreen({super.key});

  @override
  ConsumerState<InhalerEducationScreen> createState() =>
      _InhalerEducationScreenState();
}

class _InhalerEducationScreenState
    extends ConsumerState<InhalerEducationScreen> {
  late List<EducationalVideo> _videos;

  @override
  void initState() {
    super.initState();
    _videos = const [
      EducationalVideo(
        id: 'video-use',
        title: 'Utilisation du dispositif',
        description:
            'Les étapes essentielles pour préparer et inhaler correctement.',
        duration: Duration(minutes: 3),
      ),
      EducationalVideo(
        id: 'video-errors',
        title: 'Erreurs fréquentes',
        description:
            'Repérez les habitudes à éviter pour une meilleure efficacité.',
        duration: Duration(minutes: 2),
      ),
    ];
  }

  void _openVideo(EducationalVideo video) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(video.title),
            backgroundColor: AppColors.surface,
            elevation: 0,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: EducationalVideoPlayer(
                video: video,
                onComplete: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ),
          ),
        ),
      ),
    );

    if (completed == true) {
      setState(() {
        _videos = _videos.map((item) {
          return item.id == video.id ? item.copyWith(completed: true) : item;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final patientId = authState.currentUser?.id ?? 'patient-001';
    final videoState = ref.watch(videoSubmissionProvider(patientId));
    final latestSubmission = videoState.latestSubmission;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Technique d’inhalation'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ListView(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Technique d’inhalation',
                        style: AppTypography.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Apprenez les étapes essentielles pour utiliser correctement votre dispositif inhalé.',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: latestSubmission == null
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => VideoSubmissionScreen(
                                        patientId: patientId)),
                              )
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => VideoReviewScreen(
                                        video: latestSubmission)),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                      ),
                      child: Text(latestSubmission == null
                          ? 'Enregistrer une vidéo'
                          : 'Voir le statut de la vidéo'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              InhalerStatusCard(
                latestSubmission: latestSubmission,
                onSubmitVideo: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) =>
                          VideoSubmissionScreen(patientId: patientId)),
                ),
                onReviewDetails: () {
                  if (latestSubmission != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) =>
                              VideoReviewScreen(video: latestSubmission)),
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Tutoriels', style: AppTypography.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              ..._videos.map(
                (video) => EducationalVideoCard(
                  video: video,
                  onTap: () => _openVideo(video),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
