import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/features/monitoring/utils/clinical_time_range.dart';

void main() {
  group('ClinicalTimeRange', () {
    test('exposes human-friendly labels', () {
      expect(ClinicalTimeRange.days7.label, '7 days');
      expect(ClinicalTimeRange.days30.label, '30 days');
      expect(ClinicalTimeRange.days90.label, '90 days');
    });

    test('exposes the correct day count', () {
      expect(ClinicalTimeRange.days7.days, 7);
      expect(ClinicalTimeRange.days30.days, 30);
      expect(ClinicalTimeRange.days90.days, 90);
    });

    test('toDateTimeRange builds an inclusive window for 7 days', () {
      final range = ClinicalTimeRange.days7
          .toDateTimeRange(now: DateTime(2025, 5, 10, 14, 30));

      expect(range.start, DateTime(2025, 5, 4));
      expect(range.end, DateTime(2025, 5, 10, 23, 59, 59));
    });

    test('toDateTimeRange includes the whole end day', () {
      final range = ClinicalTimeRange.days30
          .toDateTimeRange(now: DateTime(2025, 5, 1, 8));

      // Start = end day minus 29 days.
      expect(range.start, DateTime(2025, 4, 2));
      expect(range.end, DateTime(2025, 5, 1, 23, 59, 59));
    });

    test('TimeRangeOption.all is consistent with the enum', () {
      expect(TimeRangeOption.all.length, ClinicalTimeRange.values.length);
      for (final option in TimeRangeOption.all) {
        expect(option.days, option.range.days);
        expect(option.label, option.range.label);
      }
    });
  });
}
