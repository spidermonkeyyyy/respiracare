import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/features/nurse/dashboard/models/dashboard_summary.dart';
import 'package:respiracare/features/nurse/dashboard/models/monitoring_rule.dart';
import 'package:respiracare/features/nurse/dashboard/providers/nurse_dashboard_provider.dart';
import 'package:respiracare/features/nurse/dashboard/repositories/mock_nurse_dashboard_repository.dart';
import 'package:respiracare/features/nurse/monitoring/models/monitoring_submission.dart';
import 'package:respiracare/features/nurse/patients/models/nurse_patient.dart';

/// Deterministic, zero-latency dashboard repository used to observe the
/// [NurseDashboardNotifier]'s loading/data/empty/error/refresh lifecycle.
class _FakeDashboardRepo extends MockNurseDashboardRepository {
  _FakeDashboardRepo({
    this.summary = const DashboardSummary(
      totalPatients: 0,
      highPriorityCount: 0,
      reviewRequiredCount: 0,
      newSubmissionsCount: 0,
    ),
    this.priorityQueue = const [],
    this.recentSubmissions = const [],
    this.monitoringRules = const [],
    this.throwOnLoad = false,
    this.onLoad,
    this.loadGate,
  });

  final DashboardSummary summary;
  final List<NursePatient> priorityQueue;
  final List<MonitoringSubmission> recentSubmissions;
  final List<MonitoringRule> monitoringRules;

  /// When true, the first repository call throws so an error state is produced.
  bool throwOnLoad;

  /// Called once per `getDashboardSummary` invocation, to prove refresh
  /// actually re-invokes the repository.
  void Function()? onLoad;

  /// Optional gate held open to observe the in-flight loading state.
  Completer<void>? loadGate;

  int _loads = 0;
  int get loads => _loads;

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    _loads++;
    if (loadGate != null) {
      await loadGate!.future;
    }
    onLoad?.call();
    if (throwOnLoad) throw Exception('backend down');
    return summary;
  }

  @override
  Future<List<NursePatient>> getPriorityQueue() async => priorityQueue;

  @override
  Future<List<MonitoringSubmission>> getRecentSubmissions(
      {int limit = 5}) async {
    return recentSubmissions;
  }

  @override
  Future<List<MonitoringRule>> getMonitoringRules() async => monitoringRules;
}

void main() {
  const patient = NursePatient(
    id: 'p1',
    fullName: 'Ahmed Bensalem',
    condition: 'BPCO',
    classification: 'GOLD III',
    priority: PriorityLevel.high,
    hasNewSubmission: true,
  );

  MonitoringSubmission submission() => MonitoringSubmission(
        id: 'ms-1',
        patientId: 'p1',
        submittedAt: DateTime(2026, 8, 12, 9, 42),
        spo2: 91,
        dyspneaScore: 2,
        coughStatus: 'Stable',
        sputumStatus: 'Stable',
        overallStatus: 'À surveiller',
      );

  group('NurseDashboardNotifier', () {
    late ProviderContainer container;

    tearDown(() => container.dispose());

    ProviderContainer build(_FakeDashboardRepo repo) => ProviderContainer(
          overrides: [
            nurseDashboardRepositoryProvider.overrideWithValue(repo),
          ],
        );

    Future<void> pump() async {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    test('exposes an explicit loading state before the first load completes',
        () async {
      final gate = Completer<void>();
      final repo = _FakeDashboardRepo(
        summary: const DashboardSummary(
          totalPatients: 3,
          highPriorityCount: 1,
          reviewRequiredCount: 2,
          newSubmissionsCount: 1,
        ),
        loadGate: gate,
      );
      container = build(repo);

      // Constructing the notifier starts loadDashboard; the gate keeps the
      // first repository call pending so we can observe the loading state.
      container.read(nurseDashboardProvider);
      await pump();

      final loading = container.read(nurseDashboardProvider);
      expect(loading.isLoading, isTrue);
      expect(loading.summary, isNull);

      // Release the gate: loading resolves to data.
      gate.complete();
      await pump();
      await pump();

      final loaded = container.read(nurseDashboardProvider);
      expect(loaded.isLoading, isFalse);
      expect(loaded.errorMessage, isNull);
      expect(loaded.summary?.totalPatients, 3);
    });
test('exposes loaded dashboard data and summary', () async {
      final repo = _FakeDashboardRepo(
        summary: const DashboardSummary(
          totalPatients: 3,
          highPriorityCount: 1,
          reviewRequiredCount: 2,
          newSubmissionsCount: 1,
        ),
        priorityQueue: [patient],
        recentSubmissions: [submission()],
        monitoringRules: [
          const MonitoringRule(
            id: 'rule-1',
            title: 'Saturation basse',
            description: 'Revoir la stabilité respiratoire.',
            condition: RuleCondition(
              field: 'spo2',
              operator: '<',
              value: '90',
            ),
            action: RuleAction(
              type: RuleActionType.nurseReview,
              label: 'Revue infirmière',
              priority: PriorityLevel.high,
            ),
          ),
        ],
      );
      container = build(repo);
      container.read(nurseDashboardProvider);
      await pump();
      await pump();

      final state = container.read(nurseDashboardProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.summary?.totalPatients, 3);
      expect(state.priorityQueue, hasLength(1));
      expect(state.recentSubmissions, hasLength(1));
      expect(state.monitoringRules, hasLength(1));
    });

    test('surfaces a safe error without presenting it as empty data', () async {
      final repo = _FakeDashboardRepo(throwOnLoad: true);
      container = build(repo);
      container.read(nurseDashboardProvider);
      await pump();
      await pump();

      final state = container.read(nurseDashboardProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNotNull);
      // Failure must not be converted into a zero-data "empty" dashboard.
      expect(state.summary, isNull);
    });

    test('refresh re-invokes the underlying repository', () async {
      final repo = _FakeDashboardRepo(
        summary: const DashboardSummary(
          totalPatients: 2,
          highPriorityCount: 1,
          reviewRequiredCount: 0,
          newSubmissionsCount: 1,
        ),
        onLoad: () {},
      );
      container = build(repo);
      final notifier = container.read(nurseDashboardProvider.notifier);
      await pump();
      await pump();

      final before = repo.loads;
      await notifier.loadDashboard();
      expect(repo.loads, greaterThan(before));
      // Data remains available after the refresh resolves.
      final state = container.read(nurseDashboardProvider);
      expect(state.isLoading, isFalse);
      expect(state.summary?.totalPatients, 2);
    });
  });
}