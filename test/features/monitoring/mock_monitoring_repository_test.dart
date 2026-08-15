import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/features/monitoring/models/measurement_type.dart';
import 'package:respiracare/features/monitoring/models/monitoring_submission.dart';
import 'package:respiracare/features/monitoring/repositories/mock_monitoring_repository.dart';

import 'monitoring_test_helpers.dart';

void main() {
  group('MockMonitoringRepository.getHistoricalMeasurements', () {
    test('filters by type set', () async {
      final repo = MockMonitoringRepository(
        historicalMeasurements: [
          spo2Reading(id: 'a', value: 96, at: DateTime(2025, 1, 1, 9)),
          heartRateReading(id: 'b', value: 72, at: DateTime(2025, 1, 1, 9)),
        ],
      );

      final result = await repo.getHistoricalMeasurements(
        start: DateTime(2025, 1, 1),
        end: DateTime(2025, 1, 2),
        types: {MeasurementType.heartRate},
      );

      expect(result, hasLength(1));
      expect(result.single.type, MeasurementType.heartRate);
    });

    test('returns only measurements inside the inclusive range', () async {
      final repo = MockMonitoringRepository(
        historicalMeasurements: [
          spo2Reading(id: 'a', value: 96, at: DateTime(2025, 1, 1, 9)),
          spo2Reading(id: 'b', value: 97, at: DateTime(2025, 1, 3, 9)),
          spo2Reading(id: 'c', value: 98, at: DateTime(2025, 1, 5, 9)),
        ],
      );

      final result = await repo.getHistoricalMeasurements(
        start: DateTime(2025, 1, 2),
        end: DateTime(2025, 1, 4),
        types: {MeasurementType.spo2},
      );

      expect(result, hasLength(1));
      expect(result.single.id, 'b');
    });

    test('sorts results oldest to newest', () async {
      final repo = MockMonitoringRepository(
        historicalMeasurements: [
          spo2Reading(id: 'z', value: 98, at: DateTime(2025, 1, 3, 9)),
          spo2Reading(id: 'a', value: 96, at: DateTime(2025, 1, 1, 9)),
        ],
      );

      final result = await repo.getHistoricalMeasurements(
        start: DateTime(2025, 1, 1),
        end: DateTime(2025, 1, 5),
        types: {MeasurementType.spo2},
      );

      expect(result.first.id, 'a');
      expect(result.last.id, 'z');
    });

    test('normalizes an inverted range instead of returning data outside it',
        () async {
      final repo = MockMonitoringRepository(
        historicalMeasurements: [
          spo2Reading(id: 'a', value: 96, at: DateTime(2025, 1, 1, 9)),
        ],
      );

      final result = await repo.getHistoricalMeasurements(
        start: DateTime(2025, 1, 5),
        end: DateTime(2025, 1, 1),
        types: {MeasurementType.spo2},
      );

      // Inverted bounds are swapped, so the reading still falls inside.
      expect(result, hasLength(1));
      expect(result.single.id, 'a');
    });

    test('persists submitted SpO₂ readings into the history', () async {
      final repo = MockMonitoringRepository(
        historicalMeasurements: [
          spo2Reading(id: 'a', value: 96, at: DateTime(2025, 1, 1, 9)),
        ],
      );

      await repo.submitMonitoring(
        MonitoringSubmission(
          id: 'sub-1',
          patientId: 'patient-1',
          timestamp: DateTime(2025, 1, 1, 10),
          answers: const {},
          spo2Value: 92,
        ),
      );

      final result = await repo.getHistoricalMeasurements(
        start: DateTime(2025, 1, 1),
        end: DateTime(2025, 1, 2),
        types: {MeasurementType.spo2},
      );

      // Original reading + the submitted one.
      expect(result, hasLength(2));
    });
  });
}
