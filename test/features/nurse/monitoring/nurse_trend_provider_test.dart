import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/features/nurse/monitoring/models/respiratory_trend.dart';
import 'package:respiracare/features/nurse/monitoring/providers/nurse_monitoring_provider.dart';
import 'package:respiracare/features/nurse/monitoring/providers/nurse_trend_provider.dart';
import 'package:respiracare/features/nurse/monitoring/repositories/mock_nurse_monitoring_repository.dart';

void main() {
  group('NurseTrendNotifier', () {
    late ProviderContainer container;
    late MockNurseMonitoringRepository mockRepository;

    setUp(() {
      mockRepository = MockNurseMonitoringRepository();
      container = ProviderContainer(
        overrides: [
          nurseMonitoringRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads the trend series for a patient (default timeframe)', () async {
      final notifier = container.read(nurseTrendProvider.notifier);
      await notifier.load('p1');

      final state = container.read(nurseTrendProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.patientId, 'p1');
      expect(state.timeframe, TrendTimeframe.days14);
      expect(state.points.length, 14);
    });

    test('switches timeframe and refetches', () async {
      final notifier = container.read(nurseTrendProvider.notifier);
      await notifier.load('p1');
      await notifier.setTimeframe(TrendTimeframe.days30);

      final state = container.read(nurseTrendProvider);
      expect(state.timeframe, TrendTimeframe.days30);
      expect(state.points.length, 30);
    });

    test('ignores an identical timeframe selection', () async {
      final notifier = container.read(nurseTrendProvider.notifier);
      await notifier.load('p1');

      await notifier.setTimeframe(TrendTimeframe.days14);
      // No reload triggered → points stay unchanged (still loading=false).
      expect(container.read(nurseTrendProvider).isLoading, isFalse);
    });

    test('surfaces an error state when the repository throws', () async {
      final throwingContainer = ProviderContainer(
        overrides: [
          nurseMonitoringRepositoryProvider.overrideWithValue(
              _ThrowingTrendRepository()),
        ],
      );
      addTearDown(throwingContainer.dispose);

      final notifier =
          throwingContainer.read(nurseTrendProvider.notifier);
      await notifier.load('p1');

      final state = throwingContainer.read(nurseTrendProvider);
      expect(state.isLoading, isFalse);
      expect(state.points, isEmpty);
      expect(state.errorMessage, contains('tendances'));
    });
  });
}

class _ThrowingTrendRepository extends MockNurseMonitoringRepository {
  @override
  Future<List<RespiratoryTrendPoint>> getRespiratoryTrend(
    String patientId, {
    TrendTimeframe timeframe = TrendTimeframe.days14,
  }) async {
    throw Exception('network down');
  }
}
