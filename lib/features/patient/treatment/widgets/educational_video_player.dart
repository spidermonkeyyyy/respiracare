import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../models/educational_video.dart';

class EducationalVideoPlayer extends StatefulWidget {
  final EducationalVideo video;
  final VoidCallback? onComplete;

  const EducationalVideoPlayer({
    super.key,
    required this.video,
    this.onComplete,
  });

  @override
  State<EducationalVideoPlayer> createState() => _EducationalVideoPlayerState();
}

class _EducationalVideoPlayerState extends State<EducationalVideoPlayer> {
  bool _isPlaying = false;
  double _progress = 0.0;
  Timer? _timer;
  bool _completed = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    if (_completed) return;
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
        final increment = 250 / widget.video.duration.inMilliseconds;
        setState(() {
          _progress = (_progress + increment).clamp(0.0, 1.0);
          if (_progress >= 1.0) {
            _completePlayback();
          }
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  void _completePlayback() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _progress = 1.0;
      _completed = true;
    });
    widget.onComplete?.call();
  }

  void _enterFullScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: const Text('Lecture vidéo'),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _playerContent(fullscreen: true),
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return _playerContent();
  }

  Widget _playerContent({bool fullscreen = false}) {
    final completedLabel =
        _completed ? '✓ Tutoriel consulté' : 'Tutoriel non terminé';
    final completedColor =
        _completed ? AppColors.success : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: fullscreen ? 260.0 : 180.0,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  size: fullscreen ? 72.0 : 48.0,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
              ),
              Positioned(
                bottom: AppSpacing.md,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: AppColors.surfaceVariant,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formattedTime(_progress),
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.surface),
                        ),
                        Text(
                          '${widget.video.duration.inMinutes}:${(widget.video.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.surface),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: AppSpacing.md,
                top: AppSpacing.md,
                child: IconButton(
                  onPressed: _enterFullScreen,
                  icon: const Icon(Icons.fullscreen, color: AppColors.surface),
                  tooltip: 'Plein écran',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(widget.video.title, style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(widget.video.description, style: AppTypography.bodyMedium),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            ElevatedButton(
              onPressed: _togglePlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
              ),
              child:
                  Text(_isPlaying ? 'Pause' : (_completed ? 'Revoir' : 'Lire')),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(completedLabel,
                style:
                    AppTypography.bodyMedium.copyWith(color: completedColor)),
          ],
        ),
      ],
    );
  }

  String _formattedTime(double progress) {
    final totalSeconds = widget.video.duration.inSeconds;
    final currentSeconds = (totalSeconds * progress).round();
    final minutes = (currentSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (currentSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
