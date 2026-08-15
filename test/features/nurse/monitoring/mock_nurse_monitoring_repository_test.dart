import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/features/nurse/monitoring/models/respiratory_trend.dart';
import 'package:respiracare/features/nurse/monitoring/repositories/mock_nurse_monitoring_repository.dart';

void main() {
  final repository = MockNurseMonitoringRepository();

  group('MockNurseMonitoringRepository.getRespiratoryTrend', () {
    test('returns oldest → newest points for a patient', () async {
      final points = await repository.getRespiratoryTrend('p3');

      expect(points, isNotEmpty);
      // Ascending dates.
      for (var i = 1; i < points.length; i++) {
        expect(points[i].date.isAfter(points[i - 1].date), isTrue);
      }
    });

    test('filters the series to the requested timeframe', () async {
      final days7 = await repository.getRespiratoryTrend('p1',
          timeframe: TrendTimeframe.days7);
      final days90 = await repository.getRespiratoryTrend('p1',
          timeframe: TrendTimeframe.days90);

      expect(days7.length, 7);
      expect(days90.length, 90);
    });

    test('seeds the high-priority patient with a deterioration profile',
        () async {
      final points = await repository.getRespiratoryTrend('p1',
          timeframe: TrendTimeframe.days90);

      final first = points.first;
      final last = points.last;

      // Gradual SpO₂ decline across the window.
      expect(last.spo2!, lessThan(first.spo2!));
      expect(points.any((p) => p.hasAlert), isTrue);
      expect(last.mmrcGrade!, greaterThanOrEqualTo(first.mmrcGrade!));
    });
  });
}
