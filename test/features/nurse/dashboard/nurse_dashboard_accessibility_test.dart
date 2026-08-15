import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:respiracare/core/components/feedback/respi_skeleton.dart';
import 'package:respiracare/core/navigation/route_names.dart';
import 'package:respiracare/core/widgets/feedback/app_error_state.dart';
import 'package:respiracare/features/authentication/models/app_user.dart';
import 'package:respiracare/features/authentication/providers/auth_provider.dart';
import 'package:respiracare/features/authentication/repositories/auth_repository.dart';
import 'package:respiracare/features/communication/models/communication_task.dart';
import 'package:respiracare/features/communication/models/conversation.dart';
import 'package:respiracare/features/communication/providers/patient_messages_provider.dart';
import 'package:respiracare/features/communication/repositories/mock_conversation_repository.dart';
import 'package:respiracare/features/nurse/alerts/models/alert.dart';
import 'package:respiracare/features/nurse/alerts/models/alert_priority.dart';
import 'package:respiracare/features/nurse/alerts/models/alert_status.dart';
import 'package:respiracare/features/nurse/alerts/providers/alert_provider.dart';
import 'package:respiracare/features/nurse/alerts/repositories/mock_alert_repository.dart';
import 'package:respiracare/features/nurse/dashboard/models/dashboard_summary.dart';
import 'package:respiracare/features/nurse/dashboard/models/monitoring_rule.dart';
import 'package:respiracare/features/nurse/dashboard/providers/nurse_dashboard_provider.dart';
import 'package:respiracare/features/nurse/dashboard/screens/nurse_dashboard_view.dart';
import 'package:respiracare/features/nurse/dashboard/widgets/worklist_item_card.dart';
import 'package:respiracare/features/nurse/dashboard/repositories/mock_nurse_dashboard_repository.dart';
import 'package:respiracare/features/nurse/monitoring/models/monitoring_submission.dart';
import 'package:respiracare/features/nurse/patients/models/nurse_patient.dart';
import 'package:respiracare/features/nurse/patients/providers/nurse_patients_provider.dart';
import 'package:respiracare/features/nurse/patients/repositories/mock_nurse_patient_repository.dart';

// ---------------------------------------------------------------------------
// Step 12.12 — Accessibility, responsive, theme & reduced-motion verification
// for the Nurse Dashboard and its Clinical Worklist.
// ---------------------------------------------------------------------------

/// Fixed clock used across fixtures so ordering is deterministic.
final t1 = DateTime(2026, 8, 12, 9, 42);
final t2 = DateTime(2026, 8, 12, 10, 5);
final t3 = DateTime(2026, 8, 11, 8, 0);

const nurse = AppUser(
  id: 'nurse-001',
  name: 'Sarah Bennani',
  email: 'nurse@respiracare.org',
  role: UserRole.nurse,
);

// --- Deterministic fixtures (mirror the main screen test) ---

Alert openAlert() => Alert(
      id: 'alert_001',
      patientId: 'p1',
      patientName: 'Ahmed B.',
      patientSummary: 'BPCO · GOLD III',
      reason: 'Données respiratoires à revoir',
      priority: AlertPriority.high,
      status: AlertStatus.unread,
      createdAt: t1,
    );

CommunicationTask openTask() => CommunicationTask(
      id: 'task_1',
      patientId: 'p1',
      type: TaskType.monitoring,
      title: 'Nouveau suivi respiratoire',
      description: '',
      actionRoute: RouteNames.patientMonitor,
      status: TaskStatus.open,
      createdAt: t2,
    );

Conversation conversation() => Conversation(
      id: 'conv_p1',
      patientId: 'p1',
      patientName: 'Ahmed B.',
      patientSummary: 'BP-OC · GOLD III',
      createdAt: t3,
      updatedAt: t2,
      tasks: [openTask()],
    );

MonitoringSubmission reviewSubmission() => MonitoringSubmission(
      id: 'ms-7',
      patientId: 'p1',
      submittedAt: t3,
      spo2: 91,
      dyspneaScore: 2,
      coughStatus: 'Stable',
      sputumStatus: 'Stable',
      overallStatus: 'À surveiller',
      ruleResults: const [
        RuleEvaluationResult(
          ruleId: 'r1',
          title: 'Saturation basse',
          matched: true,
          evidence: ['SpO₂ 91 %'],
          summary: 'Saturation à surveiller',
          priority: PriorityLevel.high,
        ),
      ],
    );

NursePatient nursePatient() => const NursePatient(
      id: 'p1',
      fullName: 'Ahmed B.',
      condition: 'BPCO',
      classification: 'GOLD III',
      priority: PriorityLevel.high,
      hasNewSubmission: true,
    );

// --- Zero-latency fake repositories ---

class _FixedAlertRepo extends MockAlertRepository {
  _FixedAlertRepo(this._alerts);
  final List<Alert> _alerts;

  @override
  Future<List<Alert>> getAlerts() async => List<Alert>.unmodifiable(_alerts);
}

class _ThrowingAlertRepo extends MockAlertRepository {
  @override
  Future<List<Alert>> getAlerts() async => throw Exception('backend down');
}

class _FixedDashboardRepo extends MockNurseDashboardRepository {
  _FixedDashboardRepo(this._submissions, {this.loadGate});
  final List<MonitoringSubmission> _submissions;
  final Completer<void>? loadGate;

  @override
  Future<DashboardSummary> getDashboardSummary() async =>
      const DashboardSummary(
        totalPatients: 0,
        highPriorityCount: 0,
        reviewRequiredCount: 0,
        newSubmissionsCount: 0,
      );

  @override
  Future<List<NursePatient>> getPriorityQueue() async => const [];

  @override
  Future<List<MonitoringSubmission>> getRecentSubmissions(
      {int limit = 5}) async {
    if (loadGate != null) await loadGate!.future;
    return _submissions;
  }

  @override
  Future<List<MonitoringRule>> getMonitoringRules() async => const [];
}

class _FixedConversationRepo extends MockConversationRepository {
  _FixedConversationRepo(this._conversations);
  final List<Conversation> _conversations;

  @override
  List<Conversation> get initialConversations => const [];

  @override
  Future<List<Conversation>> getConversations() async => _conversations;
}

class _FixedPatientRepo extends MockNursePatientRepository {
  _FixedPatientRepo(this._patients);
  final List<NursePatient> _patients;

  @override
  Future<List<NursePatient>> getPatients() async => _patients;

  @override
  Future<List<NursePatient>> getAssignedPatients(String nurseId) async =>
      _patients;
}

class _FixedAuthRepo implements AuthRepository {
  _FixedAuthRepo(this.user);
  final AppUser? user;

  @override
  Future<AppUser?> getCurrentUser() async => user;

  @override
  Future<bool> isOnboardingCompleted() async => true;

  @override
  Future<void> setOnboardingCompleted() async {}

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? dateOfBirth,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> resetPassword({required String email}) async {}
}

// --- Widget harness ---

Widget buildTestDashboard({
  MockAlertRepository? alerts,
  MockNurseDashboardRepository? dashboard,
  MockConversationRepository? conversations,
  MockNursePatientRepository? patients,
  AppUser? authUser,
  ThemeData? theme,
  bool overrideAuth = true,
  bool reduceMotion = false,
}) {
  return ProviderScope(
    overrides: [
      alertRepositoryProvider
          .overrideWithValue(alerts ?? _FixedAlertRepo([openAlert()])),
      alertListProvider.overrideWith((ref) {
        final repo = ref.watch(alertRepositoryProvider);
        final notifier = AlertListNotifier(repo);
        notifier.loadAlerts();
        return notifier;
      }),
      nurseDashboardRepositoryProvider.overrideWithValue(
          dashboard ?? _FixedDashboardRepo([reviewSubmission()])),
      conversationRepositoryProvider.overrideWithValue(
          conversations ?? _FixedConversationRepo([conversation()])),
      nursePatientRepositoryProvider
          .overrideWithValue(patients ?? _FixedPatientRepo([nursePatient()])),
      if (overrideAuth)
        authRepositoryProvider.overrideWithValue(_FixedAuthRepo(authUser)),
    ],
    child: MaterialApp.router(
      theme: theme,
      builder: reduceMotion
          ? (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              )
          : null,
      routerConfig: GoRouter(
        initialLocation: RouteNames.nurseDashboard,
        routes: [
          GoRoute(
            path: RouteNames.nurseDashboard,
            builder: (_, __) => const Scaffold(body: NurseDashboardView()),
          ),
          GoRoute(
            path: RouteNames.nursePatientDetail,
            builder: (context, state) {
              final patientId = state.pathParameters['patientId'] ?? '';
              return Placeholder(key: Key('patient-detail-$patientId'));
            },
          ),
          GoRoute(
            path: RouteNames.patientMonitor,
            builder: (_, __) => const Placeholder(key: Key('patient-monitor')),
          ),
        ],
      ),
    ),
  );
}

/// Pumps a fully-loaded dashboard using the standard fixtures and settles it.
Future<void> pumpLoadedDashboard(WidgetTester tester) async {
  await tester.pumpWidget(
    buildTestDashboard(
      alerts: _FixedAlertRepo([openAlert()]),
      dashboard: _FixedDashboardRepo([reviewSubmission()]),
      conversations: _FixedConversationRepo([conversation()]),
      patients: _FixedPatientRepo([nursePatient()]),
      authUser: nurse,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // -------------------------------------------------------------------------
  // Screen-reader semantics for worklist cards
  // -------------------------------------------------------------------------
  group('WorklistItemCard — screen-reader semantics', () {
    testWidgets(
        'exposes one coherent label with patient, title, priority, status',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpLoadedDashboard(tester);

      // Worklist composition order (actionable first, then priority desc):
      // 0 = alert (high), 1 = monitoring review (high), 2 = task (default).
      final alertCard =
          tester.getSemantics(find.byType(WorklistItemCard).at(0));
      expect(alertCard.label, contains('Ahmed B.'));
      expect(alertCard.label, contains('Données respiratoires à revoir'));
      expect(alertCard.label, contains('BPCO · GOLD III'));
      expect(alertCard.label, contains('Priorité Urgent'));
      expect(alertCard.label, contains('Non traitée'));

      // Time is dynamic relative text; just ensure a non-empty fragment exists.
      expect(alertCard.label, isNotEmpty);

      handle.dispose();
    });

    testWidgets('marks only navigable tasks as buttons', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpLoadedDashboard(tester);

      // The open task has an actionRoute -> exposed as a button.
      final taskCard = tester.getSemantics(find.byType(WorklistItemCard).at(2));
      expect(taskCard.flagsCollection.isButton, isTrue);
      expect(
          taskCard.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      expect(taskCard.label, contains('Priorité Faible'));
      expect(taskCard.label, contains('À faire'));

      handle.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // Worklist filter bar accessibility
  // -------------------------------------------------------------------------
  group('WorklistFilterBar — selection semantics & touch targets', () {
    testWidgets('selected filter chip is announced as selected',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpLoadedDashboard(tester);

      // 'Tous' is the initial filter.
      final selected = find.bySemanticsLabel('Tous, sélectionné');
      expect(selected, findsOneWidget);
      final selectedNode = tester.getSemantics(selected);
      expect(selectedNode.flagsCollection.isSelected, Tristate.isTrue);
      expect(selectedNode.flagsCollection.isButton, isTrue);

      // Unselected chips do not carry the selected flag.
      final unselectedNode =
          tester.getSemantics(find.bySemanticsLabel('Alertes'));
      expect(unselectedNode.flagsCollection.isSelected, isNot(Tristate.isTrue));

      handle.dispose();
    });

    testWidgets('filter chips meet the 48dp minimum touch target',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpLoadedDashboard(tester);

      for (final label in [
        'Tous, sélectionné',
        'Alertes',
        'Tâches',
        'Suivis',
        'À traiter'
      ]) {
        final chip = find.bySemanticsLabel(label);
        if (chip.evaluate().isNotEmpty) {
          final rect = tester.getRect(chip);
          expect(rect.width, greaterThanOrEqualTo(48), reason: '$label width');
          expect(rect.height, greaterThanOrEqualTo(48),
              reason: '$label height');
        }
      }

      handle.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // Assigned-patient card semantics
  // -------------------------------------------------------------------------
  group('Assigned patient cards — screen-reader semantics', () {
    testWidgets('expose name, condition, classification and pending count',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpLoadedDashboard(tester);

      // p1 has 3 actionable worklist items (alert + review + task).
      final patientLabel = find.bySemanticsLabel(
        RegExp(r'Ahmed B.*GOLD III.*tâches en attente', dotAll: true),
        skipOffstage: false,
      );
      expect(patientLabel, findsOneWidget);

      handle.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // Error state accessibility
  // -------------------------------------------------------------------------
  group('Error state — live region semantics', () {
    testWidgets('AppErrorState is a live region with a readable summary',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        buildTestDashboard(
          alerts: _ThrowingAlertRepo(),
          dashboard: _FixedDashboardRepo([reviewSubmission()]),
          conversations: _FixedConversationRepo([conversation()]),
          patients: _FixedPatientRepo([nursePatient()]),
          authUser: nurse,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorState), findsWidgets);
      final firstError = tester.getSemantics(find.byType(AppErrorState).first);
      expect(firstError.flagsCollection.isLiveRegion, isTrue);
      expect(firstError.label, contains('Impossible de charger'));
      expect(firstError.label, contains('Impossible de charger les alertes.'));

      handle.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // Text scaling (WCAG 1.4.4 / Android 200% font)
  // -------------------------------------------------------------------------
  group('Text scaling', () {
    testWidgets(
        'dashboard renders without layout exceptions at 200% text scale',
        (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpLoadedDashboard(tester);

      // Headings and key content must remain reachable.
      expect(find.text('File de travail'), findsOneWidget);
      expect(
          find.text('Patients assignés', skipOffstage: false), findsOneWidget);
      expect(find.byType(WorklistItemCard, skipOffstage: false), findsWidgets);

      // Scroll to the very bottom and back to exercise every layout branch.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 4000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Dark-mode theme compliance
  // -------------------------------------------------------------------------
  group('Theme — dark mode', () {
    testWidgets('dashboard renders under a dark color scheme without failures',
        (tester) async {
      await tester.pumpWidget(
        buildTestDashboard(
          alerts: _FixedAlertRepo([openAlert()]),
          dashboard: _FixedDashboardRepo([reviewSubmission()]),
          conversations: _FixedConversationRepo([conversation()]),
          patients: _FixedPatientRepo([nursePatient()]),
          authUser: nurse,
          theme: ThemeData(brightness: Brightness.dark),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(WorklistItemCard).first);
      expect(Theme.of(context).brightness, Brightness.dark);

      expect(find.text('File de travail'), findsOneWidget);
      expect(
          find.text('Patients assignés', skipOffstage: false), findsOneWidget);
      expect(find.byType(WorklistItemCard, skipOffstage: false), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Responsive layouts
  // -------------------------------------------------------------------------
  group('Responsive layout', () {
    testWidgets('fits a narrow phone width without overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLoadedDashboard(tester);

      expect(find.byType(WorklistItemCard), findsWidgets);
      expect(find.text('File de travail'), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders at tablet width without overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpLoadedDashboard(tester);

      expect(find.byType(WorklistItemCard), findsWidgets);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Reduced-motion compliance
  // -------------------------------------------------------------------------
  group('Reduced motion', () {
    testWidgets('RespiSkeleton stops its pulse when reduce-motion is enabled',
        (tester) async {
      final gate = Completer<void>();

      await tester.pumpWidget(
        buildTestDashboard(
          alerts: _FixedAlertRepo([openAlert()]),
          dashboard: _FixedDashboardRepo([reviewSubmission()], loadGate: gate),
          conversations: _FixedConversationRepo([conversation()]),
          patients: _FixedPatientRepo([nursePatient()]),
          authUser: nurse,
          reduceMotion: true,
        ),
      );
      await tester.pump();

      expect(find.byType(RespiSkeleton), findsWidgets);
      // With reduced motion the controller must not repeat -> no running ticker.
      expect(tester.hasRunningAnimations, isFalse);

      gate.complete();
      await tester.pumpAndSettle();
    });
  });
}
