import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respiracare/features/monitoring/models/measurement_type.dart';
import 'package:respiracare/features/monitoring/providers/monitoring_history_provider.dart';
import 'package:respiracare/features/monitoring/providers/monitoring_provider.dart';
import 'package:respiracare/features/monitoring/utils/clinical_time_range.dart';

import 'monitoring_test_helpers.dart';

void main() {
  late ProviderContainer container;
  late FakeMonitoringRepository fake;

  setUp(() {
    fake = FakeMonitoringRepository();
    container = ProviderContainer(
      overrides: [
        monitoringRepositoryProvider.overrideWithValue(fake),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Future<void> settle() async {
    // Let the async notifier load complete.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  // ─── PASTE-MORE ─────────────────────────────────────────────────

  test('exposes initial state with default SpO₂ selection and 7-day window',
      () {
    final state = container.read(monitoringHistoryProvider);
    expect(state.selectedTypes, {MeasurementType.spo2});
    expect(state.selectedRange, ClinicalTimeRange.days7);
    expect(state.isLoading, isTrue);
  });

  test('loads historical measurements on first read', () async {
    fake.measurements = [
      spo2Reading(id: 'a', value: 96, at: DateTime(2025, 1, 1)),
      heartRateReading(id: 'b', value: 72, at: DateTime(2025, 1, 1)),
    ];

    container.read(monitoringHistoryProvider);
    await settle();

    final state = container.read(monitoringHistoryProvider);
    expect(state.isLoading, isFalse);
    expect(state.hasError, isFalse);
    expect(fake.lastRequestedTypes, {MeasurementType.spo2});
    expect(state.measurementsFor(MeasurementType.spo2), hasLength(1));
    expect(state.measurementsFor(MeasurementType.heartRate), hasLength(0));
  });

  test('sorts measurementsFor oldest to newest', () async {
    fake.measurements = [
      spo2Reading(id: 'later', value: 98, at: DateTime(2025, 1, 3)),
      spo2Reading(id: 'earlier', value: 96, at: DateTime(2025, 1, 1)),
    ];

    container.read(monitoringHistoryProvider);
    await settle();

    final list = container
        .read(monitoringHistoryProvider)
        .measurementsFor(MeasurementType.spo2);
    expect(list.first.id, 'earlier');
    expect(list.last.id, 'later');
  });

  test('changeRange requests a new window and reloads', () async {
    fake.measurements = [
      spo2Reading(id: 'a', value: 96, at: DateTime(2025, 6, 1)),
    ];

    final notifier = container.read(monitoringHistoryProvider.notifier);
    container.read(monitoringHistoryProvider);
    await settle();
    expect(fake.historyCallCount, 1);

    await notifier.changeRange(ClinicalTimeRange.days30);
    await settle();

    expect(container.read(monitoringHistoryProvider).selectedRange,
        ClinicalTimeRange.days30);
    expect(fake.historyCallCount, 2);
  });

  test('changeRange to the same range does not reload', () async {
    final notifier = container.read(monitoringHistoryProvider.notifier);
    container.read(monitoringHistoryProvider);
    await settle();

    await notifier.changeRange(ClinicalTimeRange.days7);
    await settle();

    expect(fake.historyCallCount, 1);
  });

  // ─── PASTE-MORE-2 ───────────────────────────────────────────────

  test('toggleType adds heart rate and reloads both types', () async {
    fake.measurements = [
      spo2Reading(id: 'a', value: 96, at: DateTime(2025, 1, 1)),
      heartRateReading(id: 'b', value: 72, at: DateTime(2025, 1, 1)),
    ];

    final notifier = container.read(monitoringHistoryProvider.notifier);
    container.read(monitoringHistoryProvider);
    await settle();
    expect(fake.lastRequestedTypes, {MeasurementType.spo2});

    await notifier.toggleType(MeasurementType.heartRate);
    await settle();

    final state = container.read(monitoringHistoryProvider);
    expect(
        state.selectedTypes, {MeasurementType.spo2, MeasurementType.heartRate});
    expect(fake.lastRequestedTypes,
        {MeasurementType.spo2, MeasurementType.heartRate});
    expect(state.measurementsFor(MeasurementType.heartRate), hasLength(1));
  });

  test('toggling off the last type keeps a default selected', () async {
    final notifier = container.read(monitoringHistoryProvider.notifier);
    container.read(monitoringHistoryProvider);
    await settle();

    await notifier.toggleType(MeasurementType.spo2);
    await settle();

    expect(container.read(monitoringHistoryProvider).selectedTypes,
        {MeasurementType.spo2});
  });

  test('refresh replaces measurements', () async {
    fake.measurements = [
      spo2Reading(id: 'a', value: 94, at: DateTime(2025, 1, 1)),
    ];
    container.read(monitoringHistoryProvider);
    await settle();

    fake.measurements = [
      spo2Reading(id: 'a', value: 94, at: DateTime(2025, 1, 1)),
      spo2Reading(id: 'b', value: 97, at: DateTime(2025, 1, 2)),
    ];
    await container.read(monitoringHistoryProvider.notifier).refresh();
    await settle();

    final state = container.read(monitoringHistoryProvider);
    expect(state.measurementsFor(MeasurementType.spo2), hasLength(2));
    expect(state.latestFor(MeasurementType.spo2)?.value, 97.0);
  });

  test('surfaces an error when the repository throws', () async {
    fake.throwOnHistory = true;

    container.read(monitoringHistoryProvider);
    await settle();

    final state = container.read(monitoringHistoryProvider);
    expect(state.hasError, isTrue);
    expect(state.isLoading, isFalse);
  });

  test('latestFor returns the newest reading for a type', () async {
    fake.measurements = [
      spo2Reading(id: 'a', value: 94, at: DateTime(2025, 1, 1, 9)),
      spo2Reading(id: 'b', value: 98, at: DateTime(2025, 1, 2, 9)),
    ];
    container.read(monitoringHistoryProvider);
    await settle();

    final latest = container
        .read(monitoringHistoryProvider)
        .latestFor(MeasurementType.spo2);
    expect(latest?.id, 'b');
    expect(latest?.value, 98.0);
  });

  test('trendFor delegates to the trend calculator', () async {
    fake.measurements = [
      spo2Reading(id: 'a', value: 94, at: DateTime(2025, 1, 1, 9)),
      spo2Reading(id: 'b', value: 98, at: DateTime(2025, 1, 2, 9)),
    ];
    container.read(monitoringHistoryProvider);
    await settle();

    final trend = container
        .read(monitoringHistoryProvider)
        .trendFor(MeasurementType.spo2);
    expect(trend.direction.toString(), contains('upward'));
  });
}
