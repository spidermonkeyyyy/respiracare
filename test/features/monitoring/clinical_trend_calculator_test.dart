import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/features/monitoring/models/clinical_measurement.dart';
import 'package:respiracare/features/monitoring/models/measurement_type.dart';
import 'package:respiracare/features/monitoring/utils/clinical_trend_calculator.dart';

import 'monitoring_test_helpers.dart';

void main() {
  group('ClinicalTrendCalculator', () {
    test('returns insufficientData when there are fewer than 2 readings', () {
      final single = [
        spo2Reading(id: 'a', value: 96, at: DateTime(2025, 1, 1, 9)),
      ];

      final summary =
          ClinicalTrendCalculator.calculate(single, MeasurementType.spo2);

      expect(summary.direction, TrendDirection.insufficientData);
      expect(summary.readingCount, 1);
      expect(summary.change, isNull);
    });

    test('returns insufficientData for an empty list', () {
      final summary =
          ClinicalTrendCalculator.calculate([], MeasurementType.spo2);
      expect(summary.direction, TrendDirection.insufficientData);
      expect(summary.readingCount, 0);
    });

    test('ignores invalid measurements (NaN / empty unit)', () {
      final measurements = <ClinicalMeasurement>[
        ClinicalMeasurement(
          id: 'bad',
          type: MeasurementType.spo2,
          value: double.nan,
          unit: '%',
          measuredAt: DateTime(2025, 1, 1, 8),
        ),
        spo2Reading(id: 'a', value: 96, at: DateTime(2025, 1, 1, 9)),
        spo2Reading(id: 'b', value: 92, at: DateTime(2025, 1, 2, 9)),
      ];

      final summary =
          ClinicalTrendCalculator.calculate(measurements, MeasurementType.spo2);
      expect(summary.readingCount, 2);
      expect(summary.direction, TrendDirection.downward);
    });

    test('classifies a rise beyond the threshold as upward', () {
      final readings = [
        spo2Reading(id: 'a', value: 94, at: DateTime(2025, 1, 1, 9)),
        spo2Reading(id: 'b', value: 98, at: DateTime(2025, 1, 2, 9)),
      ];

      final summary =
          ClinicalTrendCalculator.calculate(readings, MeasurementType.spo2);
      expect(summary.direction, TrendDirection.upward);
      expect(summary.change, 4.0);
    });

    test('classifies a fall beyond the threshold as downward', () {
      final readings = [
        spo2Reading(id: 'a', value: 98, at: DateTime(2025, 1, 1, 9)),
        spo2Reading(id: 'b', value: 90, at: DateTime(2025, 1, 2, 9)),
      ];

      final summary =
          ClinicalTrendCalculator.calculate(readings, MeasurementType.spo2);
      expect(summary.direction, TrendDirection.downward);
      expect(summary.change, -8.0);
    });

    test('classifies small changes within threshold as stable', () {
      final readings = [
        spo2Reading(id: 'a', value: 95, at: DateTime(2025, 1, 1, 9)),
        spo2Reading(id: 'b', value: 96, at: DateTime(2025, 1, 2, 9)),
      ];

      final summary =
          ClinicalTrendCalculator.calculate(readings, MeasurementType.spo2);
      expect(summary.direction, TrendDirection.stable);
    });

    test('uses a larger threshold for heart rate (5 bpm)', () {
      final readings = [
        heartRateReading(id: 'a', value: 70, at: DateTime(2025, 1, 1, 9)),
        heartRateReading(id: 'b', value: 73, at: DateTime(2025, 1, 2, 9)),
      ];

      final summary = ClinicalTrendCalculator.calculate(
          readings, MeasurementType.heartRate);
      expect(summary.direction, TrendDirection.stable);
    });

    test('sorts unsorted readings by time before classifying', () {
      final readings = [
        spo2Reading(id: 'a', value: 98, at: DateTime(2025, 1, 2, 9)),
        spo2Reading(id: 'b', value: 94, at: DateTime(2025, 1, 1, 9)),
      ];

      final summary =
          ClinicalTrendCalculator.calculate(readings, MeasurementType.spo2);
      // Oldest (94) vs latest (98) → upward.
      expect(summary.direction, TrendDirection.upward);
    });

    test('description is descriptive and never diagnostic', () {
      final readings = [
        spo2Reading(id: 'a', value: 96, at: DateTime(2025, 1, 1, 9)),
        spo2Reading(id: 'b', value: 92, at: DateTime(2025, 1, 2, 9)),
      ];

      final summary =
          ClinicalTrendCalculator.calculate(readings, MeasurementType.spo2);
      expect(summary.direction, TrendDirection.downward);
      expect(summary.description.toLowerCase(), contains('reading'));
      expect(summary.description, isNot(contains('abnormal')));
      expect(summary.description, isNot(contains('diagnos')));
    });
  });
}
