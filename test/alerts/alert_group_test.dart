import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/features/nurse/alerts/models/alert.dart';
import 'package:respiracare/features/nurse/alerts/models/alert_group.dart';
import 'package:respiracare/features/nurse/alerts/models/alert_priority.dart';
import 'package:respiracare/features/nurse/alerts/models/alert_status.dart';

void main() {
  test('groupByPatient groups alerts by patient and orders by priority', () {
    final now = DateTime.now();
    final a1 = Alert(
      id: 'a1',
      patientId: 'p1',
      patientName: 'P1',
      reason: 'r1',
      priority: AlertPriority.high,
      status: AlertStatus.unread,
      createdAt: now.subtract(const Duration(minutes: 5)),
    );
    final a2 = Alert(
      id: 'a2',
      patientId: 'p1',
      patientName: 'P1',
      reason: 'r2',
      priority: AlertPriority.low,
      status: AlertStatus.unread,
      createdAt: now.subtract(const Duration(minutes: 10)),
    );
    final a3 = Alert(
      id: 'a3',
      patientId: 'p2',
      patientName: 'P2',
      reason: 'r3',
      priority: AlertPriority.medium,
      status: AlertStatus.unread,
      createdAt: now.subtract(const Duration(minutes: 1)),
    );

    final groups = AlertGroup.groupByPatient([a1, a2, a3]);

    // Expect two groups
    expect(groups.length, 2);

    // p1 group should have highest priority = high
    final p1 = groups.firstWhere((g) => g.patientId == 'p1');
    expect(p1.priority, AlertPriority.high);
    expect(p1.count, 2);

    final p2 = groups.firstWhere((g) => g.patientId == 'p2');
    expect(p2.priority, AlertPriority.medium);
    expect(p2.count, 1);
  });
}
