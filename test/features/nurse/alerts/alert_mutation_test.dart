import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/features/nurse/alerts/models/alert.dart';
import 'package:respiracare/features/nurse/alerts/models/alert_priority.dart';
import 'package:respiracare/features/nurse/alerts/models/alert_status.dart';
import 'package:respiracare/features/nurse/alerts/providers/alert_provider.dart';
import 'package:respiracare/features/nurse/alerts/repositories/mock_alert_repository.dart';

/// Fixed, zero-latency alert repository with mutable seeded alerts so we can
/// simulate a successful mutation by updating the in-memory list between calls.
class _FakeAlertRepo extends MockAlertRepository {
  _FakeAlertRepo(List<Alert> initial) {
    _alerts.addAll(initial);
  }

  final List<Alert> _alerts = [];
  final List<String> callLog = [];

  @override
  Future<List<Alert>> getAlerts() async {
    callLog.add('getAlerts');
    return List<Alert>.unmodifiable(_alerts);
  }

  void seed(List<Alert> alerts) {
    _alerts
      ..clear()
      ..addAll(alerts);
  }
}

/// Repository whose mutation methods throw on command.
class _ThrowingAlertRepo extends MockAlertRepository {
  @override
  Future<Alert> acknowledgeAlert(String alertId, String nurseId) async {
    throw StateError('La justification est requise pour cette décision.');
  }

  @override
  Future<Alert> resolveAlert(String alertId, {String? resolutionNote}) async {
    throw Exception('backend down');
  }
}

void main() {
  final t = DateTime(2026, 8, 12, 9, 42);

  Alert alert({
    required String id,
    AlertPriority priority = AlertPriority.high,
    AlertStatus status = AlertStatus.unread,
  }) =>
      Alert(
        id: id,
        patientId: 'p1',
        patientName: 'Ahmed Bensalem',
        patientSummary: 'BPCO · GOLD III',
        reason: 'Données respiratoires à revoir',
        priority: priority,
        status: status,
        createdAt: t,
      );

  group('AlertListNotifier mutations', () {
    late ProviderContainer container;
    late _FakeAlertRepo repo;

    tearDown(() => container.dispose());

    Future<ProviderContainer> buildAndLoad(_FakeAlertRepo repository) async {
      repo = repository;
      final c = ProviderContainer(
        overrides: [
          alertRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await c.read(alertListProvider.notifier).loadAlerts();
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);
      return c;
    }

    test('acknowledge swaps the alert to acknowledged on success', () async {
      repo = _FakeAlertRepo([alert(id: 'alert_001')]);
      container = await buildAndLoad(repo);

      final before = container.read(alertListProvider);
      expect(before.alerts.first.status, AlertStatus.unread);

      final notifier = container.read(alertListProvider.notifier);
      repo.seed([
        alert(id: 'alert_001', status: AlertStatus.acknowledged)
            .copyWith(acknowledgedAt: t),
      ]);

      final result = await notifier.acknowledge('alert_001');
      expect(result, isTrue);
      await Future.delayed(Duration.zero);

      final after = container.read(alertListProvider);
      expect(after.alerts.first.status, AlertStatus.acknowledged);
      expect(after.pendingAlertId, isNull);
    });

    test('failed mutation preserves original alert + safe error', () async {
      container = ProviderContainer(
        overrides: [
          alertRepositoryProvider.overrideWithValue(_ThrowingAlertRepo()),
        ],
      );
      await container.read(alertListProvider.notifier).loadAlerts();
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      final notifier = container.read(alertListProvider.notifier);
      final result = await notifier.acknowledge('alert_001');

      expect(result, isFalse);
      final after = container.read(alertListProvider);
      expect(after.alerts.first.status, AlertStatus.unread);
      expect(after.pendingAlertId, isNull);
      expect(after.errorMessage, isNotNull);
      expect(after.errorMessage, isNot(contains('Exception')));
    });
  });
}
