import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respiracare/features/nurse/alerts/models/alert_priority.dart';
import 'package:respiracare/features/nurse/alerts/models/alert_status.dart';
import 'package:respiracare/features/nurse/alerts/models/alert.dart';
import 'package:respiracare/features/nurse/alerts/providers/alert_provider.dart';
import 'package:respiracare/features/nurse/alerts/repositories/mock_alert_repository.dart';

void main() {
  group('MockAlertRepository', () {
    late MockAlertRepository repository;

    setUp(() => repository = MockAlertRepository());

    test('seeds five alerts with one high-priority open', () async {
      final alerts = await repository.getAlerts();
      expect(alerts.length, equals(5));
      final high = await repository.getAlertsByPriority(AlertPriority.high);
      expect(high.length, equals(1));
      expect(high.first.id, equals('alert_001'));
    });

    test('acknowledge moves an unread alert to acknowledged and assigns nurse', () async {
      final updated = await repository.acknowledgeAlert('alert_001', 'nurse_7');
      expect(updated.status, equals(AlertStatus.acknowledged));
      expect(updated.assignedNurseId, equals('nurse_7'));
      expect(updated.acknowledgedAt, isNotNull);
    });

    test('recordAction requires an acknowledgement first', () async {
      expect(
        () => repository.recordAction(
          'alert_002',
          action: NurseAction.monitoring,
          decision: NurseDecision.actionRequired,
        ),
        throwsStateError,
      );
    });

    test('overriding with notConcerning requires a justification', () async {
      await repository.acknowledgeAlert('alert_002', 'nurse_7');
      expect(
        () => repository.recordAction(
          'alert_002',
          action: NurseAction.monitoring,
          decision: NurseDecision.notConcerning,
        ),
        throwsStateError,
      );

      final updated = await repository.recordAction(
        'alert_002',
        action: NurseAction.monitoring,
        decision: NurseDecision.notConcerning,
        justification: 'Stable à la revue suivante.',
      );
      expect(updated.status, equals(AlertStatus.inProgress));
      expect(updated.justification, isNotEmpty);
    });

    test('resolve requires acknowledgement and rejects a second resolve', () async {
      expect(
        () => repository.resolveAlert('alert_001'),
        throwsStateError,
      );
      await repository.acknowledgeAlert('alert_001', 'nurse_7');
      final resolved = await repository.resolveAlert('alert_001', resolutionNote: 'Ok');
      expect(resolved.status, equals(AlertStatus.resolved));
      expect(resolved.resolvedAt, isNotNull);
    });
  });

  group('AlertListNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          alertRepositoryProvider.overrideWithValue(MockAlertRepository()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loadAlerts populates the list and counts', () async {
      await container.read(alertListProvider.notifier).loadAlerts();
      final state = container.read(alertListProvider);
      expect(state.isLoading, isFalse);
      expect(state.alerts.length, equals(5));
      expect(state.openCount, equals(4));
      expect(state.unreadCount, equals(2));
    });

    test('filters keep only matching alerts', () async {
      await container.read(alertListProvider.notifier).loadAlerts();
      final notifier = container.read(alertListProvider.notifier);

      notifier.setFilter(AlertFilter.unhandled);
      expect(container.read(alertListProvider).filteredAlerts.length, equals(2));

      notifier.setFilter(AlertFilter.highPriority);
      expect(container.read(alertListProvider).filteredAlerts.length, equals(1));

      notifier.setFilter(AlertFilter.toReview);
      expect(container.read(alertListProvider).filteredAlerts.length, equals(2));
    });

    test('alerts are grouped per patient by highest priority', () async {
      await container.read(alertListProvider.notifier).loadAlerts();
      final groups = container.read(alertListProvider).filteredGroups;
      // p1 (x2), p2 (x2), p3 (x1)
      expect(groups.length, equals(3));
      final p1 = groups.firstWhere((group) => group.patientId == 'p1');
      expect(p1.count, equals(2));
      expect(p1.priority, equals(AlertPriority.high));
      expect(p1.concernedMetrics, contains('SpO₂'));
    });

    test('acknowledging through the provider updates state', () async {
      await container.read(alertListProvider.notifier).loadAlerts();
      final ok = await container.read(alertListProvider.notifier).acknowledge('alert_001');
      expect(ok, isTrue);
      final updated = container.read(alertByIdProvider('alert_001'));
      expect(updated?.status, equals(AlertStatus.acknowledged));
    });

    test('an invalid recordAction surfaces a French error message', () async {
      await container.read(alertListProvider.notifier).loadAlerts();
      await container.read(alertListProvider.notifier).acknowledge('alert_002');
      final ok = await container.read(alertListProvider.notifier).recordAction(
            'alert_002',
            action: NurseAction.monitoring,
            decision: NurseDecision.notConcerning,
          );
      expect(ok, isFalse);
      expect(container.read(alertListProvider).errorMessage, isNotNull);
    });
  });
}
