import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/typography.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/feedback/app_error_state.dart';
import '../../../core/widgets/feedback/app_loading.dart';
import '../models/monitoring_question.dart';
import '../providers/monitoring_provider.dart';
import '../widgets/monitoring_progress.dart';
import '../widgets/question_renderer.dart';

class MonitoringQuestionScreen extends ConsumerStatefulWidget {
  const MonitoringQuestionScreen({super.key});

  @override
  ConsumerState<MonitoringQuestionScreen> createState() =>
      _MonitoringQuestionScreenState();
}

class _MonitoringQuestionScreenState
    extends ConsumerState<MonitoringQuestionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _goingForward = true;

  // Local transient answer for numeric input (before user taps next)
  dynamic _pendingAnswer;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _buildAnimations();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _buildAnimations() {
    _slideAnimation = Tween<Offset>(
      begin: Offset(_goingForward ? 0.15 : -0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeIn),
    );
  }

  Future<void> _animateTransition({required bool forward}) async {
    _goingForward = forward;
    _buildAnimations();
    _slideController.reset();
    await _slideController.forward();
  }

  void _handleNext(MonitoringState state) {
    final question = state.currentQuestion;
    if (question == null) return;

    // For single choice: check selection
    if (question.type == QuestionType.singleChoice) {
      final current = state.answers[question.id];
      if (question.required && current == null) {
        setState(() => _validationError = 'Veuillez sélectionner une réponse pour continuer.');
        return;
      }
    }

    // For numeric input: validate pending answer
    if (question.type == QuestionType.numericInput) {
      final existing = state.answers[question.id];
      if (question.required && _pendingAnswer == null && existing == null) {
        setState(() => _validationError = 'Veuillez entrer une valeur valide pour continuer.');
        return;
      }
      // Save pending numeric answer
      if (_pendingAnswer != null) {
        ref.read(monitoringProvider.notifier).saveAnswer(
              question.id,
              _pendingAnswer,
              _pendingAnswer.toString(),
            );
      }
    }

    setState(() => _validationError = null);

    if (state.isLastStep) {
      _animateTransition(forward: true).then((_) {
        if (mounted) context.go('/patient/monitoring/review');
      });
      return;
    }

    _animateTransition(forward: true).then((_) {
      if (mounted) {
        ref.read(monitoringProvider.notifier).nextStep();
        _pendingAnswer = null;
      }
    });
  }

  void _handleBack(MonitoringState state) {
    if (state.isFirstStep) {
      context.go('/patient/monitoring');
      return;
    }
    setState(() => _validationError = null);
    _animateTransition(forward: false).then((_) {
      if (mounted) {
        ref.read(monitoringProvider.notifier).previousStep();
        _pendingAnswer = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(monitoringProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: AppLoading(message: 'Chargement du questionnaire...', fullScreen: true),
      );
    }

    if (state.errorMessage != null && state.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: AppErrorState(
          title: 'Questionnaire indisponible',
          message: state.errorMessage!,
          onRetry: () => ref.read(monitoringProvider.notifier).loadQuestions(),
        ),
      );
    }

    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final displayStep = state.currentStepIndex + 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _handleBack(state),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => _handleBack(state),
          ),
          title: MonitoringProgress(
            currentStep: displayStep,
            totalSteps: state.totalSteps,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      key: ValueKey(state.currentStepIndex),
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.title,
                            style: AppTypography.headlineLarge.copyWith(
                              fontSize: 22.0,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          MonitoringQuestionRenderer(
                            question: question,
                            currentAnswer: question.type == QuestionType.numericInput
                                ? (_pendingAnswer ?? state.answers[question.id]?.value)
                                : state.answers[question.id]?.value,
                            measurementSource: state.measurementSource,
                            onAnswerChanged: (value) {
                              setState(() => _validationError = null);
                              if (question.type == QuestionType.singleChoice) {
                                final option = question.options
                                    .firstWhere((o) => o.id == value);
                                ref.read(monitoringProvider.notifier).saveAnswer(
                                      question.id,
                                      value,
                                      option.label,
                                    );
                              } else {
                                setState(() => _pendingAnswer = value);
                              }
                            },
                          ),

                          // Validation error message
                          if (_validationError != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _validationError!,
                              style: AppTypography.secondaryText.copyWith(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    if (!state.isFirstStep)
                      Expanded(
                        flex: 1,
                        child: AppButton(
                          text: 'Retour',
                          variant: AppButtonVariant.outlined,
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => _handleBack(state),
                          fullWidth: true,
                        ),
                      ),
                    if (!state.isFirstStep) const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        text: state.isLastStep ? 'Vérifier mes réponses' : 'Suivant',
                        icon: state.isLastStep
                            ? Icons.checklist_rounded
                            : Icons.arrow_forward_rounded,
                        onPressed: () => _handleNext(state),
                        fullWidth: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
