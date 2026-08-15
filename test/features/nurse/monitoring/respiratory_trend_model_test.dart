import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/features/nurse/monitoring/models/respiratory_trend.dart';

void main() {
  group('TrendTimeframe', () {
    test('exposes French labels and day counts', () {
      expect(TrendTimeframe.days7.label, '7 jours');
      expect(TrendTimeframe.days7.days, 7);
      expect(TrendTimeframe.days14.days, 14);
      expect(TrendTimeframe.days30.days, 30);
      expect(TrendTimeframe.days90.days, 90);
    });

    test('window computed relative to an injected reference date', () {
      final window = TrendTimeframe.days14
          .window(now: DateTime(2025, 5, 10, 14, 30));

      // 14 inclusive days: start day = end day minus 13 days.
      expect(window.start, DateTime(2025, 4, 27));
      expect(window.end, DateTime(2025, 5, 10, 23, 59, 59));
    });

    test('days7 window spans seven inclusive days', () {
      final window = TrendTimeframe.days7
          .window(now: DateTime(2025, 3, 20, 8));

      expect(window.start, DateTime(2025, 3, 14));
      expect(window.end, DateTime(2025, 3, 20, 23, 59, 59));
    });
  });

  group('SputumSeverity', () {
    test('exposes French labels', () {
      expect(SputumSeverity.none.label, 'Aucun');
      expect(SputumSeverity.low.label, 'Peu');
      expect(SputumSeverity.moderate.label, 'Modéré');
      expect(SputumSeverity.high.label, 'Important');
    });
  });

  group('RespiratoryTrendPoint', () {
    test('holds nullable metrics without coercion', () {
      final point = RespiratoryTrendPoint(
          date: DateTime(2025, 1, 1), spo2: 92);

      expect(point.spo2, 92);
      expect(point.catScore, isNull);
      expect(point.mmrcGrade, isNull);
      expect(point.sputum, isNull);
      expect(point.hasAlert, isFalse);
    });

    test('equality respects all fields', () {
      final a = RespiratoryTrendPoint(
          date: DateTime(2025, 1, 1), spo2: 92, hasAlert: true);
      final b = RespiratoryTrendPoint(
          date: DateTime(2025, 1, 1), spo2: 92, hasAlert: true);
      final c = RespiratoryTrendPoint(
          date: DateTime(2025, 1, 1), spo2: 91, hasAlert: true);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
