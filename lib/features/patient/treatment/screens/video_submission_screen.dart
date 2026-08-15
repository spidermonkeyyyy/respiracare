import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../providers/video_submission_provider.dart';

class VideoSubmissionScreen extends ConsumerStatefulWidget {
  final String patientId;

  const VideoSubmissionScreen({super.key, required this.patientId});

  @override
  ConsumerState<VideoSubmissionScreen> createState() =>
      _VideoSubmissionScreenState();
}

class _VideoSubmissionScreenState extends ConsumerState<VideoSubmissionScreen> {
  Timer? _recordingTimer;
  static const _maxDuration = Duration(seconds: 60);

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    ref
        .read(videoSubmissionProvider(widget.patientId).notifier)
        .requestPermission();
  }

  void _grantPermission() {
    ref
        .read(videoSubmissionProvider(widget.patientId).notifier)
        .onPermissionResult(granted: true);
    _beginRecordingTimer();
  }

  void _denyPermission() {
    ref
        .read(videoSubmissionProvider(widget.patientId).notifier)
        .onPermissionResult(granted: false);
  }

  void _beginRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final notifier =
          ref.read(videoSubmissionProvider(widget.patientId).notifier);
      final state = ref.read(videoSubmissionProvider(widget.patientId));
      final next = state.recordingDuration + const Duration(seconds: 1);
      notifier.updateRecordingDuration(next);
      if (next >= _maxDuration) {
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    ref
        .read(videoSubmissionProvider(widget.patientId).notifier)
        .stopRecording();
  }

  void _retake() {
    ref.read(videoSubmissionProvider(widget.patientId).notifier).retake();
    _beginRecordingTimer();
  }

  Future<void> _submit() async {
    await ref
        .read(videoSubmissionProvider(widget.patientId).notifier)
        .submitVideo();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(videoSubmissionProvider(widget.patientId));
    final notifier =
        ref.read(videoSubmissionProvider(widget.patientId).notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vérification de la technique'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: _buildContent(provider, notifier),
        ),
      ),
    );
  }

  Widget _buildContent(
      VideoSubmissionState state, VideoSubmissionNotifier notifier) {
    switch (state.status) {
      case SubmissionStatus.idle:
        return _buildIntro();
      case SubmissionStatus.requestingPermission:
        return _buildPermissionRequest();
      case SubmissionStatus.permissionDenied:
        return _buildPermissionDenied();
      case SubmissionStatus.recording:
        return _buildRecording(state);
      case SubmissionStatus.previewing:
        return _buildPreview(state);
      case SubmissionStatus.uploading:
        return _buildUploading();
      case SubmissionStatus.success:
        return _buildSuccess();
      case SubmissionStatus.error:
        return _buildError(state, notifier);
    }
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            'Enregistrez une courte vidéo montrant comment vous utilisez votre dispositif.',
            style: AppTypography.bodyLarge),
        const SizedBox(height: AppSpacing.md),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Conseils :', style: AppTypography.titleMedium),
              SizedBox(height: AppSpacing.sm),
              Text('• Placez-vous dans un endroit bien éclairé',
                  style: AppTypography.bodyMedium),
              SizedBox(height: AppSpacing.xs),
              Text('• Gardez le dispositif visible',
                  style: AppTypography.bodyMedium),
              SizedBox(height: AppSpacing.xs),
              Text('• Suivez les instructions de votre équipe',
                  style: AppTypography.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
            'Votre vidéo sera transmise à votre équipe soignante pour vérification.',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
            text: 'Commencer l’enregistrement', onPressed: _startRecording),
      ],
    );
  }

  Widget _buildPermissionRequest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Permission demandée', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'L’accès à la caméra est nécessaire pour enregistrer votre vidéo.',
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
                child:
                    AppButton(text: 'Accorder', onPressed: _grantPermission)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: AppButton(
                    text: 'Refuser',
                    onPressed: _denyPermission,
                    variant: AppButtonVariant.outlined)),
          ],
        ),
      ],
    );
  }

  Widget _buildPermissionDenied() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Accès à la caméra refusé', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'L’accès à la caméra est nécessaire pour enregistrer votre vidéo.',
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(text: 'Réessayer', onPressed: _startRecording),
      ],
    );
  }

  Widget _buildRecording(VideoSubmissionState state) {
    final remaining = _maxDuration - state.recordingDuration;
    final timerLabel =
        '${remaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${remaining.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam,
                      size: 64.0, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Enregistrement en cours',
                      style: AppTypography.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(timerLabel, style: AppTypography.headlineSmall),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(text: 'Arrêter l’enregistrement', onPressed: _stopRecording),
      ],
    );
  }

  Widget _buildPreview(VideoSubmissionState state) {
    final durationLabel = '${state.recordingDuration.inSeconds}s';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Votre vidéo', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: const Center(
                    child: Icon(Icons.play_arrow_rounded,
                        size: 48.0, color: AppColors.primary)),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(durationLabel, style: AppTypography.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
                child: AppButton(
                    text: 'Refaire',
                    onPressed: _retake,
                    variant: AppButtonVariant.secondary)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: AppButton(text: 'Envoyer', onPressed: _submit)),
          ],
        ),
      ],
    );
  }

  Widget _buildUploading() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: AppSpacing.xl),
        CircularProgressIndicator(),
        SizedBox(height: AppSpacing.md),
        Text('Transmission en cours...', style: AppTypography.bodyLarge),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('✓ Vidéo envoyée',
            style: AppTypography.titleLarge.copyWith(color: AppColors.success)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Votre vidéo est maintenant en attente de vérification par votre infirmier.',
          style:
              AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildError(
      VideoSubmissionState state, VideoSubmissionNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('La vidéo n’a pas pu être envoyée.',
            style: AppTypography.titleLarge.copyWith(color: AppColors.danger)),
        const SizedBox(height: AppSpacing.sm),
        if (state.errorMessage != null)
          Text(state.errorMessage!,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.lg),
        AppButton(text: 'Réessayer', onPressed: _submit),
      ],
    );
  }
}
