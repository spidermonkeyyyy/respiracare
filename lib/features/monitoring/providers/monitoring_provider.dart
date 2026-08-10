import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/evaluation_result.dart';
import '../models/monitoring_answer.dart';
import '../models/monitoring_question.dart';
import '../models/monitoring_submission.dart';
import '../repositories/mock_monitoring_repository.dart';
import '../repositories/monitoring_repository.dart';

class MonitoringState {
  final bool isLoading;
  final List<MonitoringQuestion> questions;
  final int currentStepIndex;
  final Map<String, MonitoringAnswer> answers;
  final MeasurementSource measurementSource;
  final bool isSubmitting;
  final EvaluationResult? evaluationResult;
  final String? errorMessage;

  const MonitoringState({
    this.isLoading = true,
    this.questions = const [],
    this.currentStepIndex = 0,
    this.answers = const {},
    this.measurementSource = MeasurementSource.manual,
    this.isSubmitting = false,
    this.evaluationResult,
    this.errorMessage,
  });

  bool get isFirstStep => currentStepIndex == 0;
  bool get isLastStep => questions.isNotEmpty && currentStepIndex == questions.length - 1;
  int get totalSteps => questions.length;
  double get progress => totalSteps == 0 ? 0.0 : (currentStepIndex + 1) / totalSteps;

  MonitoringQuestion? get currentQuestion =>
      questions.isNotEmpty && currentStepIndex < questions.length
          ? questions[currentStepIndex]
          : null;

  MonitoringState copyWith({
    bool? isLoading,
    List<MonitoringQuestion>? questions,
    int? currentStepIndex,
    Map<String, MonitoringAnswer>? answers,
    MeasurementSource? measurementSource,
    bool? isSubmitting,
    EvaluationResult? evaluationResult,
    String? errorMessage,
  }) {
    return MonitoringState(
      isLoading: isLoading ?? this.isLoading,
      questions: questions ?? this.questions,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      answers: answers ?? this.answers,
      measurementSource: measurementSource ?? this.measurementSource,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      evaluationResult: evaluationResult ?? this.evaluationResult,
      errorMessage: errorMessage,
    );
  }
}

final monitoringRepositoryProvider = Provider<MonitoringRepository>((ref) {
  return MockMonitoringRepository();
});

final monitoringProvider =
    StateNotifierProvider<MonitoringNotifier, MonitoringState>((ref) {
  final repository = ref.watch(monitoringRepositoryProvider);
  return MonitoringNotifier(repository);
});

class MonitoringNotifier extends StateNotifier<MonitoringState> {
  final MonitoringRepository _repository;

  MonitoringNotifier(this._repository) : super(const MonitoringState()) {
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final questions = await _repository.getQuestions();
      state = state.copyWith(
        isLoading: false,
        questions: questions,
        currentStepIndex: 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger le questionnaire de suivi.',
      );
    }
  }

  void saveAnswer(String questionId, dynamic value, String displayLabel) {
    final newAnswers = Map<String, MonitoringAnswer>.from(state.answers);
    newAnswers[questionId] = MonitoringAnswer(
      questionId: questionId,
      value: value,
      displayLabel: displayLabel,
    );
    state = state.copyWith(answers: newAnswers);
  }

  void setMeasurementSource(MeasurementSource source) {
    state = state.copyWith(measurementSource: source);
  }

  bool nextStep() {
    if (state.currentStepIndex < state.questions.length - 1) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
      return true;
    }
    return false;
  }

  bool previousStep() {
    if (state.currentStepIndex > 0) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
      return true;
    }
    return false;
  }

  void goToStep(int index) {
    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(currentStepIndex: index);
    }
  }

  Future<bool> submitMonitoring(String patientId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final spo2Answer = state.answers['spo2'];
      final spo2Val = (spo2Answer?.value as num?)?.toInt() ?? 94;

      final submission = MonitoringSubmission(
        id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        timestamp: DateTime.now(),
        answers: state.answers,
        spo2Value: spo2Val,
        measurementSource: state.measurementSource,
      );

      final result = await _repository.submitMonitoring(submission);

      state = state.copyWith(
        isSubmitting: false,
        evaluationResult: result,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Une erreur s\'est produite lors de l\'envoi du suivi.',
      );
      return false;
    }
  }

  void reset() {
    state = state.copyWith(
      currentStepIndex: 0,
      answers: {},
      isSubmitting: false,
      evaluationResult: null,
      errorMessage: null,
    );
  }
}
