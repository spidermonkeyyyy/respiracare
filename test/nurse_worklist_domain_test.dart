import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/features/nurse/alerts/models/alert.dart';
import 'package:respiracare/features/nurse/alerts/models/alert_priority.dart';
import 'package:respiracare/features/nurse/alerts/models/alert_status.dart';
import 'package:respiracare/features/nurse/dashboard/models/nurse_worklist_item.dart';
import 'package:respiracare/features/nurse/dashboard/providers/nurse_worklist_provider.dart';
import 'package:respiracare/features/communication/models/communication_task.dart';

/// All timestamps are fixed to avoid depending on DateTime.now().
Alert _alert({
  required String id,
  required AlertPriority priority,
  required AlertStatus status,
  required DateTime createdAt,
}) {
  return Alert(
    id: id,
    patientId: 'patient_1',
    patientName: 'Ahmed Ben Ali',
    patientSummary: '',
    reason: 'Données respiratoires à revoir',
    priority: priority,
    status: status,
    createdAt: createdAt,
  );
}

CommunicationTask _task({
  required String id,
  required TaskStatus status,
  required DateTime createdAt,
}) {
  return CommunicationTask(
    id: id,
    patientId: 'patient_2',
    conversationId: 'conv_1',
    type: TaskType.followUp,
    title: 'Nouveau suivi respiratoire',
    description: 'Veuillez effectuer votre suivi respiratoire',
    actionRoute: '/nurse/patients/patient_2',
    status: status,
    createdAt: createdAt,
  );
}

void main() {
  group('composeNurseWorklist', () {
    test('returns empty list when no inputs', () {
      final items = composeNurseWorklist(
        alerts: [],
        submissions: [],
        tasks: [],
        patientNames: {},
      );
      expect(items, isEmpty);
    });

    test('includes alert items from the alert list', () {
      final items = composeNurseWorklist(
        alerts: [
          _alert(
            id: 'alert_1',
            priority: AlertPriority.high,
            status: AlertStatus.unread,
            createdAt: DateTime(2026, 8, 13, 10, 0),
          ),
        ],
        submissions: [],
        tasks: [],
        patientNames: {'patient_1': 'Ahmed Ben Ali'},
      );
      expect(items.length, 1);
      expect(items.first.type, NurseWorklistItemType.alert);
      expect(items.first.patientName, 'Ahmed Ben Ali');
    });

    test('includes task items from the task list', () {
      final items = composeNurseWorklist(
        alerts: [],
        submissions: [],
        tasks: [
          _task(
            id: 'task_1',
            status: TaskStatus.open,
            createdAt: DateTime(2026, 8, 13, 10, 0),
          ),
        ],
        patientNames: {'patient_2': 'Patient Two'},
      );
      expect(items.length, 1);
      expect(items.first.type, NurseWorklistItemType.task);
    });

    test('sorts actionable items before non-actionable', () {
      final items = composeNurseWorklist(
        alerts: [
          _alert(
            id: 'alert_1',
            priority: AlertPriority.high,
            status: AlertStatus.resolved, // Not actionable
            createdAt: DateTime(2026, 8, 13, 10, 0),
          ),
          _alert(
            id: 'alert_2',
            priority: AlertPriority.medium,
            status: AlertStatus.unread, // Actionable
            createdAt: DateTime(2026, 8, 13, 9, 0),
          ),
        ],
        submissions: [],
        tasks: [],
        patientNames: {},
      );
      expect(items.length, 2);
      expect(items.first.isActionable, true);
      expect(items.last.isActionable, false);
    });
  });

  group('composeNurseWorklist determinism', () {
    test('sorts by priority rank when both actionable', () {
      final items = composeNurseWorklist(
        alerts: [
          _alert(
            id: 'alert_low',
            priority: AlertPriority.low, // rank 2
            status: AlertStatus.unread,
            createdAt: DateTime(2026, 8, 13, 10, 0),
          ),
          _alert(
            id: 'alert_high',
            priority: AlertPriority.high, // rank 0
            status: AlertStatus.unread,
            createdAt: DateTime(2026, 8, 13, 10, 0),
          ),
        ],
        submissions: [],
        tasks: [],
        patientNames: {},
      );
      // High priority (rank 0) comes before low priority (rank 2).
      expect(items.first.id, 'alert:alert_high');
      expect(items.last.id, 'alert:alert_low');
    });

    test('sorts by timestamp when same priority', () {
      final items = composeNurseWorklist(
        alerts: [
          _alert(
            id: 'alert_older',
            priority: AlertPriority.high,
            status: AlertStatus.unread,
            createdAt: DateTime(2026, 8, 13, 8, 0),
          ),
          _alert(
            id: 'alert_newer',
            priority: AlertPriority.high,
            status: AlertStatus.unread,
            createdAt: DateTime(2026, 8, 13, 10, 0),
          ),
        ],
        submissions: [],
        tasks: [],
        patientNames: {},
      );
      // Newer items come first.
      expect(items.first.id, 'alert:alert_newer');
    });

    test('same inputs always produce same order', () {
      List<String> firstRun() => composeNurseWorklist(
            alerts: [
              _alert(
                id: 'a1',
                priority: AlertPriority.high,
                status: AlertStatus.unread,
                createdAt: DateTime(2026, 8, 13, 10, 0),
              ),
              _alert(
                id: 'a2',
                priority: AlertPriority.medium,
                status: AlertStatus.unread,
                createdAt: DateTime(2026, 8, 13, 9, 0),
              ),
            ],
            submissions: [],
            tasks: [
              _task(
                id: 't1',
                status: TaskStatus.open,
                createdAt: DateTime(2026, 8, 13, 8, 0),
              ),
            ],
            patientNames: {},
          ).map((i) => i.id).toList();

      expect(firstRun(), firstRun());
    });
  });

  group('NurseWorklistFilter', () {
    test('all matches every type', () {
      expect(NurseWorklistFilter.all.matches(_item(NurseWorklistItemType.alert)), isTrue);
      expect(NurseWorklistFilter.all.matches(_item(NurseWorklistItemType.task)), isTrue);
      expect(NurseWorklistFilter.all.matches(_item(NurseWorklistItemType.monitoring)), isTrue);
    });

    test('alerts matches only alert items', () {
      expect(NurseWorklistFilter.alerts.matches(_item(NurseWorklistItemType.alert)), isTrue);
      expect(NurseWorklistFilter.alerts.matches(_item(NurseWorklistItemType.task)), isFalse);
      expect(NurseWorklistFilter.alerts.matches(_item(NurseWorklistItemType.monitoring)), isFalse);
    });

    test('tasks matches only task items', () {
      expect(NurseWorklistFilter.tasks.matches(_item(NurseWorklistItemType.alert)), isFalse);
      expect(NurseWorklistFilter.tasks.matches(_item(NurseWorklistItemType.task)), isTrue);
      expect(NurseWorklistFilter.tasks.matches(_item(NurseWorklistItemType.monitoring)), isFalse);
    });

    test('needsAttention matches only actionable items', () {
      expect(NurseWorklistFilter.needsAttention.matches(_item(NurseWorklistItemType.alert, isActionable: true)), isTrue);
      expect(NurseWorklistFilter.needsAttention.matches(_item(NurseWorklistItemType.alert, isActionable: false)), isFalse);
    });
  });

  group('NurseWorklistItem Equatable', () {
    test('items with same fields are equal', () {
      expect(
        _item(NurseWorklistItemType.alert),
        equals(_item(NurseWorklistItemType.alert)),
      );
    });
  });
}

NurseWorklistItem _item(NurseWorklistItemType type, {bool isActionable = true}) {
  return NurseWorklistItem(
    id: '${type.name}:alert_1',
    type: type,
    patientId: 'patient_1',
    patientName: 'Ahmed Ben Ali',
    title: 'Test item',
    relatedEntityId: 'alert_1',
    timestamp: DateTime(2026, 8, 13, 10, 0),
    priorityRank: 0,
    statusLabel: 'Ouvert',
    isActionable: isActionable,
  );
}

