import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/radius.dart';
import '../../../../app/theme/spacing.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/utils/animations/app_animations.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../models/exercise.dart';
import '../models/exercise_session.dart';
import '../providers/rehabilitation_provider.dart';

/// Exercise session screen with timer, pause/resume, and completion
class ExerciseSessionScreen extends ConsumerStatefulWidget {
  final String exerciseId;

  const ExerciseSessionScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  ConsumerState<ExerciseSessionScreen> createState() =>
      _ExerciseSessionScreenState();
}

class _ExerciseSessionScreenState extends ConsumerState<ExerciseSessionScreen>
    with TickerProviderStateMixin {
  Exercise? _exercise;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isCompleted = false;
  late AnimationController _progressController;
  late AnimationController _completionController;

  @override
  void initState() {
    super.initState();
    _loadExercise();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void _loadExercise() {
    final state = ref.read(rehabilitationProvider);
    if (state.program != null) {
      try {
        _exercise = state.program!.exercises
            .firstWhere((e) => e.id == widget.exerciseId);
        setState(() {});
      } catch (_) {
        // Exercise not found
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null) return;

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    _progressController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed = Duration(seconds: _elapsed.inSeconds + 1);
        });
        _updateProgress();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
    _progressController.reverse();
  }

  void _resumeTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    _progressController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed = Duration(seconds: _elapsed.inSeconds + 1);
        });
        _updateProgress();
      }
    });
  }

  void _completeSession() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
      _isCompleted = true;
    });
    _progressController.reverse();
    _completionController.forward();

    // Record the session
    _recordSession();
  }

  void _recordSession() {
    if (_exercise == null) return;

    final session = ExerciseSession(
      id: 'sess-${DateTime.now().millisecondsSinceEpoch}',
      exerciseId: _exercise!.id,
      exerciseName: _exercise!.name,
      completedAt: DateTime.now(),
      actualDuration: _elapsed,
    );

    ref.read(rehabilitationProvider.notifier).completeExerciseSession(session);
  }

  void _updateProgress() {
    if (_exercise == null) return;
    final targetSeconds = _exercise!.duration.inSeconds;
    final progress = (_elapsed.inSeconds / targetSeconds).clamp(0.0, 1.0);
    _progressController.value = progress;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_exercise == null) {
      return _buildNotFound();
    }

    if (_isCompleted) {
      return _buildCompletionScreen();
    }

    final targetDuration = _exercise!.duration;
    final progress = targetDuration.inSeconds > 0
        ? (_elapsed.inSeconds / targetDuration.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => context.pop(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_exercise!.name),
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: _isRunning
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => context.pop(),
                ),
          automaticallyImplyLeading: !_isRunning,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Progress indicator
                AppFadeAnimation(
                  child: Column(
                    children: [
                      Text(
                        _isPaused ? 'En pause' : 'Séance en cours',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Circular progress
                      SizedBox(
                        width: 200.0,
                        height: 200.0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background circle
                            SizedBox(
                              width: 200.0,
                              height: 200.0,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 8.0,
                                backgroundColor: AppColors.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _isPaused
                                      ? AppColors.warning
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            // Timer text
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatDuration(_elapsed),
                                  style: AppTypography.displayLarge.copyWith(
                                    fontSize: 48.0,
                                    fontWeight: FontWeight.w300,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'sur ${_exercise!.formattedDuration}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Control buttons
                AppSlideAnimation(
                  direction: SlideDirection.up,
                  child: _buildControls(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    if (_isRunning) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Pause',
              icon: Icons.pause_rounded,
              variant: AppButtonVariant.outlined,
              onPressed: _pauseTimer,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppButton(
              text: 'Terminer',
              icon: Icons.stop_rounded,
              variant: AppButtonVariant.danger,
              onPressed: _completeSession,
            ),
          ),
        ],
      );
    }

    if (_isPaused) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Reprendre',
              icon: Icons.play_arrow_rounded,
              variant: AppButtonVariant.primary,
              onPressed: _resumeTimer,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppButton(
              text: 'Terminer',
              icon: Icons.stop_rounded,
              variant: AppButtonVariant.danger,
              onPressed: _completeSession,
            ),
          ),
        ],
      );
    }

    // Not started yet
    return AppButton(
      text: 'Commencer',
      icon: Icons.play_arrow_rounded,
      fullWidth: true,
      onPressed: _startTimer,
    );
  }

  Widget _buildCompletionScreen() {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => context.pop(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Séance terminée'),
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          automaticallyImplyLeading: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Completion animation
                ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _completionController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 64.0,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Completion text
                FadeTransition(
                  opacity: _completionController,
                  child: Column(
                    children: [
                      Text(
                        'Séance terminée',
                        style: AppTypography.displayLarge.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Bravo ! Vous avez complété votre exercice.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Duration summary
                FadeTransition(
                  opacity: _completionController,
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              icon: Icons.access_time_rounded,
                              label: 'Durée réelle',
                              value: _formatDuration(_elapsed),
                              color: AppColors.primary,
                            ),
                            _buildStatItem(
                              icon: Icons.flag_rounded,
                              label: 'Objectif',
                              value: _exercise!.formattedDuration,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Action buttons
                FadeTransition(
                  opacity: _completionController,
                  child: Column(
                    children: [
                      AppButton(
                        text: 'Retour au programme',
                        icon: Icons.arrow_back_rounded,
                        fullWidth: true,
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        text: 'Voir ma progression',
                        icon: Icons.trending_up_rounded,
                        variant: AppButtonVariant.outlined,
                        fullWidth: true,
                        onPressed: () {
                          context.pop();
                          context.push('/patient/education/rehabilitation');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Icon(icon, size: 24.0, color: color),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            fontSize: 18.0,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNotFound() {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => context.pop(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Séance'),
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          automaticallyImplyLeading: true,
        ),
        body: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center_outlined,
                      size: 64, color: AppColors.textMuted),
                  SizedBox(height: AppSpacing.md),
                  Text('Exercice non trouvé', style: AppTypography.headlineLarge),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Cet exercice n\'existe pas dans votre programme.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}