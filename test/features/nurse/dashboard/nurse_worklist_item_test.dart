import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/features/communication/models/communication_task.dart';
import 'package:respiracare/features/nurse/alerts/models/alert.dart';
import 'package:respiracare/features/nurse/alerts/models/alert_priority.dart';
import 'package:respiracare/features/nurse/alerts/models/alert_status.dart';
import 'package:respiracare/features/nurse/dashboard/models/monitoring_rule.dart';
import 'package:respiracare/features/nurse/dashboard/models/nurse_worklist_item.dart';
import 'package:respiracare/features/nurse/monitoring/models/monitoring_submission.dart';

void main() {
  // Fixed clock-independent timestamps (Step 12 rule: no DateTime.now()).
  final t1 = DateTime(2026, 8, 12, 9, 42);
  final t2 = DateTime(2026, 8, 12, 10, 5);
  final t3 = DateTime(2026, 8, 11, 8, 0);

  Alert alert({
    AlertPriority priority = AlertPriority.high,
    AlertStatus status = AlertStatus.unread,
    DateTime? createdAt,
    String id = 'alert_001',
  }) {
    return Alert(
      id: id,
      patientId: 'p1',
      patientName: 'Ahmed B.',
      patientSummary: 'BPCO · GOLD III',
      reason: 'Données respiratoires à revoir',
      priority: priority,
      status: status,
      createdAt: createdAt ?? t1,
    );
  }

  CommunicationTask task({
    TaskStatus status = TaskStatus.open,
    String id = 'task_001',
    DateTime? createdAt,
  }) {
    return CommunicationTask(
      id: id,
      patientId: 'p2',
      type: TaskType.followUp,
      title: 'Suivi demandé',
      description: 'Demande de nouveau suivi',
      actionRoute: '/patient/monitoring',
      status: status,
      createdAt: createdAt ?? t2,
    );
  }

  MonitoringSubmission submission({
    List<RuleEvaluationResult> results = const [],
    String id = 'ms-7',
    DateTime? submittedAt,
  }) {
    return MonitoringSubmission(
      id: id,
      patientId: 'p1',
      submittedAt: submittedAt ?? t3,
      spo2: 91,
      dyspneaScore: 2,
      coughStatus: 'Stable',
      sputumStatus: 'Stable',
      overallStatus: 'À surveiller',
      ruleResults: results,
    );
  }

  RuleEvaluationResult matchedHigh({String id = 'r1'}) {
    return RuleEvaluationResult(
      ruleId: id,
      title: 'Saturation basse',
      matched: true,
      evidence: const ['SpO₂ 91 %'],
      summary: 'Saturation à surveiller',
      priority: PriorityLevel.high,
    );
  }

  RuleEvaluationResult matchedInformational({String id = 'r2'}) {
    return RuleEvaluationResult(
      ruleId: id,
      title: 'Heure de saisie inhabituelle',
      matched: true,
      evidence: const ['Saisi le soir'],
      summary: 'Information',
      priority: PriorityLevel.informational,
    );
  }

  const names = {'p1': 'Ahmed B.', 'p2': 'Nsiri K.'};

  group('composeNurseWorklist — mapping', () {
    test('returns empty list when every source is empty', () {
      final items = composeNurseWorklist(
        alerts: [],
        submissions: [],
        tasks: [],
        patientNames: names,
      );
      expect(items, isEmpty);
    });

    test('maps an open alert with patient association and stable id', () {
      final items = composeNurseWorklist(
        alerts: [alert()],
        submissions: [],
        tasks: [],
        patientNames: names,
      );
      expect(items, hasLength(1));
      final item = items.single;
      expect(item.id, 'alert:alert_001');
      expect(item.type, NurseWorklistItemType.alert);
      expect(item.patientId, 'p1');
      expect(item.relatedEntityId, 'alert_001');
      expect(item.priorityRank, 0);
      expect(item.isActionable, isTrue);
      expect(item.timestamp, t1);
    });

    test('maps an open task with action route and default priority rank', () {
      final items = composeNurseWorklist(
        alerts: [],
        submissions: [],
        tasks: [task()],
        patientNames: names,
      );
      expect(items, hasLength(1));
      final item = items.single;
      expect(item.id, 'task:task_001');
      expect(item.type, NurseWorklistItemType.task);
      expect(item.patientId, 'p2');
      expect(item.priorityRank, 3);
      expect(item.isActionable, isTrue);
      expect(item.actionRoute, '/patient/monitoring');
    });

    test('includes a submission when a matched rule requires review', () {
      final items = composeNurseWorklist(
        alerts: [],
        submissions: [
          submission(results: [matchedHigh()])
        ],
        tasks: [],
        patientNames: names,
      );
      expect(items, hasLength(1));
      final item = items.single;
      expect(item.id, 'monitoring:ms-7');
      expect(item.type, NurseWorklistItemType.monitoring);
      expect(item.relatedEntityId, 'ms-7');
      expect(item.priorityRank, 0);
      expect(item.isActionable, isTrue);
      expect(item.patientName, 'Ahmed B.');
    });

    test('excludes a submission whose only matched rules are informational',
        () {
      final items = composeNurseWorklist(
        alerts: [],
        submissions: [
          submission(results: [matchedInformational()])
        ],
        tasks: [],
        patientNames: names,
      );
      expect(items, isEmpty);
    });

    test('an alert keeps its own domain display name even without a roster map',
        () {
      final items = composeNurseWorklist(
        alerts: [alert()],
        submissions: [],
        tasks: [],
        patientNames: const {},
      );
      // The alert carries its own patient name (domain truth); it is not
      // fabricated from a roster that is absent.
      expect(items.single.patientName, 'Ahmed B.');
      expect(items.single.patientId, 'p1');
    });

    test('assigns stable unique ids within a mixed dataset', () {
      final items = composeNurseWorklist(
        alerts: [
          alert(),
          alert(id: 'alert_002', priority: AlertPriority.medium, createdAt: t2),
        ],
        submissions: [
          submission(results: [matchedHigh()])
        ],
        tasks: [task()],
        patientNames: names,
      );
      final ids = items.map((e) => e.id).toSet();
      expect(ids, hasLength(items.length));
      expect(items.length, 4);
    });
  });
  group('composeNurseWorklist — deterministic ordering', () {
    test('actionable items sort before resolved/done items', () {
      final items = composeNurseWorklist(
        alerts: [alert(status: AlertStatus.resolved, createdAt: t2)],
        submissions: [],
        tasks: [task(status: TaskStatus.done, createdAt: t3)],
        patientNames: names,
      );
      expect(items.where((e) => e.isActionable), isEmpty);
      expect(items, hasLength(2));
      expect(items.first.isActionable, isFalse);
      expect(items.last.isActionable, isFalse);
    });

    test('orders by priority rank (review before medium alert)', () {
      final items = composeNurseWorklist(
        alerts: [alert(priority: AlertPriority.medium, createdAt: t3)],
        submissions: [
          submission(results: [matchedHigh()], submittedAt: t2)
        ],
        tasks: [],
        patientNames: names,
      );
      // monitoring review (rank 0, high) before medium alert (rank 1).
      expect(items[0].type, NurseWorklistItemType.monitoring);
      expect(items[1].type, NurseWorklistItemType.alert);
    });

    test('task items rank below actionable alerts', () {
      final items = composeNurseWorklist(
        alerts: [alert(priority: AlertPriority.informational, createdAt: t3)],
        submissions: [],
        tasks: [task(createdAt: t2)],
        patientNames: names,
      );
      // Alert informational (rank 3) sorts before open task (rank 3),
      // then timestamp: alert is older (t3) → task is newer (t2) so task first.
      expect(items.first.type, NurseWorklistItemType.task);
      expect(items.last.type, NurseWorklistItemType.alert);
    });

    test('is deterministic for equal keys', () {
      List<String> run() => composeNurseWorklist(
            alerts: [
              alert(priority: AlertPriority.low, createdAt: t1),
              alert(priority: AlertPriority.low, createdAt: t1),
            ],
            submissions: [],
            tasks: [],
            patientNames: names,
          ).map((e) => e.id).toList();
      expect(run(), run());
    });
  });
}
