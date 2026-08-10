import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respiracare/features/monitoring/models/evaluation_result.dart';
import 'package:respiracare/features/monitoring/providers/monitoring_provider.dart';
import 'package:respiracare/features/monitoring/repositories/mock_monitoring_repository.dart';

void main() {
  group('MonitoringNotifier Tests', () {
    late ProviderContainer container;
    late MockMonitoringRepository mockRepository;

    setUp(() {
      mockRepository = MockMonitoringRepository();
      container = ProviderContainer(
        overrides: [
          monitoringRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Loads 4 questions correctly from mock repository', () async {
      final notifier = container.read(monitoringProvider.notifier);
      await notifier.loadQuestions();

      final state = container.read(monitoringProvider);
      expect(state.isLoading, isFalse);
      expect(state.questions.length, equals(4));
      expect(state.questions[0].id, equals('dyspnea'));
      expect(state.questions[1].id, equals('cough'));
      expect(state.questions[2].id, equals('sputum'));
      expect(state.questions[3].id, equals('spo2'));
    });

    test('Saves answer and persists when navigating backward', () async {
      final notifier = container.read(monitoringProvider.notifier);
      await notifier.loadQuestions();

      notifier.saveAnswer('dyspnea', 'mmrc_1', 'Niveau 1');
      notifier.nextStep();

      // Go back
      notifier.previousStep();
      final state = container.read(monitoringProvider);
      expect(state.answers['dyspnea']?.value, equals('mmrc_1'));
      expect(state.currentStepIndex, equals(0));
    });

    test('nextStep advances and previousStep goes back correctly', () async {
      final notifier = container.read(monitoringProvider.notifier);
      await notifier.loadQuestions();

      expect(container.read(monitoringProvider).currentStepIndex, equals(0));
      expect(container.read(monitoringProvider).isFirstStep, isTrue);

      notifier.nextStep();
      expect(container.read(monitoringProvider).currentStepIndex, equals(1));

      notifier.nextStep();
      notifier.nextStep();
      expect(container.read(monitoringProvider).isLastStep, isTrue);
    });

    test('Submitting monitoring with normal SpO2 returns normal result',
        () async {
      final notifier = container.read(monitoringProvider.notifier);
      await notifier.loadQuestions();

      notifier.saveAnswer('dyspnea', 'mmrc_0', 'Niveau 0');
      notifier.saveAnswer('cough', 'cough_normal', 'Pas plus que d\'habitude');
      notifier.saveAnswer('sputum', 'sputum_normal', 'Pas de changement');
      notifier.saveAnswer('spo2', 96, '96');

      final success = await notifier.submitMonitoring('patient-001');
      expect(success, isTrue);

      final state = container.read(monitoringProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.evaluationResult, isNotNull);
      expect(state.evaluationResult?.status, equals(EvaluationStatus.normal));
    });

    test('Submitting with low SpO2 triggers reviewRequired result', () async {
      final notifier = container.read(monitoringProvider.notifier);
      await notifier.loadQuestions();

      notifier.saveAnswer('dyspnea', 'mmrc_0', 'Niveau 0');
      notifier.saveAnswer('cough', 'cough_normal', 'Pas plus que d\'habitude');
      notifier.saveAnswer('sputum', 'sputum_normal', 'Pas de changement');
      notifier.saveAnswer('spo2', 88, '88'); // Below 92 threshold

      final success = await notifier.submitMonitoring('patient-001');
      expect(success, isTrue);

      final state = container.read(monitoringProvider);
      expect(state.evaluationResult?.status,
          equals(EvaluationStatus.reviewRequired));
      expect(
          state.evaluationResult?.patientMessage, contains('équipe soignante'));
      // Must NOT expose technical rule IDs to patient
      expect(state.evaluationResult?.patientMessage, isNot(contains('RULE_')));
    });

    test('Reset clears all answers and evaluation result', () async {
      final notifier = container.read(monitoringProvider.notifier);
      await notifier.loadQuestions();

      notifier.saveAnswer('dyspnea', 'mmrc_1', 'Niveau 1');
      notifier.reset();

      final state = container.read(monitoringProvider);
      expect(state.answers.isEmpty, isTrue);
      expect(state.currentStepIndex, equals(0));
      expect(state.evaluationResult, isNull);
    });
  });
}
