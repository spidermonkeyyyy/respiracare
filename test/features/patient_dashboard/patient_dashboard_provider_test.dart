import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respiracare/features/patient_dashboard/models/patient_dashboard_data.dart';
import 'package:respiracare/features/patient_dashboard/providers/patient_dashboard_provider.dart';
import 'package:respiracare/features/patient_dashboard/repositories/mock_patient_dashboard_repository.dart';

void main() {
  group('PatientDashboardNotifier Tests', () {
    late ProviderContainer container;
    late MockPatientDashboardRepository mockRepository;

    setUp(() {
      mockRepository = MockPatientDashboardRepository();
      container = ProviderContainer(
        overrides: [
          patientDashboardRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial loading state fetches mock dashboard data', () async {
      final notifier = container.read(patientDashboardProvider.notifier);

      // Initially loading
      expect(container.read(patientDashboardProvider).isLoading, isTrue);

      await notifier.loadDashboard();
      final state = container.read(patientDashboardProvider);

      expect(state.isLoading, isFalse);
      expect(state.data, isNotNull);
      expect(state.data?.spo2Value, equals(94));
      expect(state.data?.statusText, equals('Suivi normal'));
      expect(state.data?.nurseName, equals('Sarah Bennani'));
    });

    test('Completing daily questionnaire updates state to completed', () async {
      final notifier = container.read(patientDashboardProvider.notifier);

      await notifier.loadDashboard();
      expect(container.read(patientDashboardProvider).data?.questionnaireState, equals(DailyQuestionnaireState.inProgress));

      await notifier.completeQuestionnaire();
      final state = container.read(patientDashboardProvider);

      expect(state.data?.questionnaireState, equals(DailyQuestionnaireState.completed));
      expect(state.data?.questionnaireProgress, equals(1.0));
      expect(state.data?.questionnaireCompletedTime, isNotNull);
    });

    test('Force error state triggers error message', () async {
      final notifier = container.read(patientDashboardProvider.notifier);

      await notifier.loadDashboard(forceError: true);
      final state = container.read(patientDashboardProvider);

      expect(state.isLoading, isFalse);
      expect(state.errorMessage, contains('Impossible de charger votre suivi'));
    });

    test('Force empty state triggers empty state', () async {
      final notifier = container.read(patientDashboardProvider.notifier);

      await notifier.loadDashboard(forceEmpty: true);
      final state = container.read(patientDashboardProvider);

      expect(state.isLoading, isFalse);
      expect(state.isEmpty, isTrue);
      expect(state.data, isNull);
    });
  });
}
