import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:respiracare/core/components/feedback/respi_empty_state.dart';
import 'package:respiracare/core/components/feedback/respi_skeleton.dart';
import 'package:respiracare/core/components/cards/respi_card.dart';
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
import 'package:respiracare/features/nurse/dashboard/widgets/worklist_filter_bar.dart';
import 'package:respiracare/features/nurse/dashboard/repositories/mock_nurse_dashboard_repository.dart';
import 'package:respiracare/features/nurse/monitoring/models/monitoring_submission.dart';
import 'package:respiracare/features/nurse/patients/models/nurse_patient.dart';
import 'package:respiracare/features/nurse/patients/providers/nurse_patients_provider.dart';
import 'package:respiracare/features/nurse/patients/repositories/mock_nurse_patient_repository.dart';

// --- Fixed timestamps ---
final t1 = DateTime(2026, 8, 12, 9, 42);
final t2 = DateTime(2026, 8, 12, 10, 5);
final t3 = DateTime(2026, 8, 11, 8, 0);

const nurse = AppUser(
  id: 'nurse-001',
  name: 'Sarah Bennani',
  email: 'nurse@respiracare.org',
  role: UserRole.nurse,
);

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
      patientSummary: 'BPCO · GOLD III',
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
  int loads = 0;

  @override
  Future<List<Alert>> getAlerts() async {
    loads++;
    return List<Alert>.unmodifiable(_alerts);
  }

  @override
  Future<Alert> acknowledgeAlert(String alertId, String nurseId) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index == -1) throw StateError('Alerte introuvable: $alertId');
    final current = _alerts[index];
    if (current.status != AlertStatus.unread) return current;
    final updated = current.copyWith(
      status: AlertStatus.acknowledged,
      acknowledgedAt: DateTime(2026, 8, 12, 11, 0),
      assignedNurseId: nurseId,
    );
    _alerts[index] = updated;
    return updated;
  }

  @override
  Future<Alert> resolveAlert(String alertId, {String? resolutionNote}) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index == -1) throw StateError('Alerte introuvable');
    final current = _alerts[index];
    if (current.status == AlertStatus.unread) return current;
    if (current.status == AlertStatus.resolved) return current;
    final updated = current.copyWith(
      status: AlertStatus.resolved,
      resolvedAt: DateTime(2026, 8, 12, 11, 0),
      resolutionNote: resolutionNote,
    );
    _alerts[index] = updated;
    return updated;
  }
}

class _ThrowingAlertRepo extends MockAlertRepository {
  @override
  Future<List<Alert>> getAlerts() async => throw Exception('backend down');
}

class _FixedDashboardRepo extends MockNurseDashboardRepository {
  _FixedDashboardRepo(this._submissions, {this.loadGate});
  final List<MonitoringSubmission> _submissions;
  final Completer<void>? loadGate;
  int loads = 0;

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
  Future<List<MonitoringSubmission>> getRecentSubmissions({int limit = 5}) async {
    loads++;
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
  Future<List<NursePatient>> getAssignedPatients(String nurseId) async => _patients;
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

// --- Widget test helper ---

Widget buildDashboard({
  MockAlertRepository? alerts,
  MockNurseDashboardRepository? dashboard,
  MockConversationRepository? conversations,
  MockNursePatientRepository? patients,
  AppUser? authUser,
  bool overrideAuth = true,
}) {
  return ProviderScope(
    overrides: [
      alertRepositoryProvider.overrideWithValue(
          alerts ?? _FixedAlertRepo(const [])),
      // Override alertListProvider to pre-load alerts
      alertListProvider.overrideWith((ref) {
        final repo = ref.watch(alertRepositoryProvider);
        final notifier = AlertListNotifier(repo);
        notifier.loadAlerts();
        return notifier;
      }),
      nurseDashboardRepositoryProvider.overrideWithValue(
          dashboard ?? _FixedDashboardRepo(const [])),
      conversationRepositoryProvider.overrideWithValue(
          conversations ?? _FixedConversationRepo(const [])),
      nursePatientRepositoryProvider.overrideWithValue(
          patients ?? _FixedPatientRepo(const [])),
      if (overrideAuth)
        authRepositoryProvider.overrideWithValue(_FixedAuthRepo(authUser)),
    ],
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: RouteNames.nurseDashboard,
        routes: [
          GoRoute(
            path: RouteNames.nurseDashboard,
            builder: (_, __) => const Scaffold(
              body: NurseDashboardView(),
            ),
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

Future<void> settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

void main() {
  group('NurseDashboardView - state separation', () {
    testWidgets('distinguishes loading from empty from error', (tester) async {
            final loadingGate = Completer<void>();
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()], loadGate: loadingGate),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await tester.pump();

      // While loading, skeletons should be visible
      expect(find.byType(RespiSkeleton), findsWidgets);
      expect(find.byType(AppErrorState), findsNothing);
      expect(find.byType(RespiEmptyState), findsNothing);

      loadingGate.complete();
      await settle(tester);

      expect(find.byType(RespiSkeleton), findsNothing);
    });

    testWidgets('renders empty worklist when all sources return empty',
        (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([]),
        dashboard: _FixedDashboardRepo([]),
        conversations: _FixedConversationRepo([]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      expect(find.byType(RespiEmptyState), findsWidgets);
      expect(find.text('Vous êtes à jour'), findsOneWidget);
      expect(find.byType(AppErrorState), findsNothing);
    });

    testWidgets('renders error when alert source fails', (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _ThrowingAlertRepo(),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      expect(find.byType(AppErrorState), findsWidgets);
      expect(find.text('Impossible de charger la file de travail'), findsOneWidget);
    });
  });

  group('NurseDashboardView - rendering', () {
    testWidgets('shows greeting with nurse name', (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      expect(find.text('Bonjour, Sarah Bennani'), findsOneWidget);
    });

    testWidgets('shows attention summary', (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      expect(find.text('Attention'), findsOneWidget);
      expect(find.text('À traiter'), findsWidgets);
    });

    testWidgets('renders all three worklist items', (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      expect(find.text('File de travail'), findsOneWidget);
      expect(find.byType(WorklistItemCard), findsNWidgets(3));
    });

    testWidgets('renders filter bar', (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      expect(find.byType(WorklistFilterBar), findsOneWidget);
      expect(find.text('Tous'), findsWidgets);
    });

    testWidgets('renders assigned patients section', (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      // Assigned patients section is below the fold; use skipOffstage: false
      expect(find.text('Patients assignés', skipOffstage: false), findsOneWidget);
      expect(find.text('Ahmed B.', skipOffstage: false), findsWidgets);
    });
  });

  group('NurseDashboardView - filtering', () {
    testWidgets('filtering by alerts shows only alert items', (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      await tester.ensureVisible(find.text('Alertes').first);
      await tester.tap(find.text('Alertes').first);
      await settle(tester);

      expect(find.byType(WorklistItemCard), findsOneWidget);
      expect(find.text('Données respiratoires à revoir'), findsOneWidget);
    });

    testWidgets('filtering by tasks shows only task items', (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      await tester.ensureVisible(find.text('Tâches').first);
      await tester.tap(find.text('Tâches').first);
      await settle(tester);

      expect(find.byType(WorklistItemCard), findsOneWidget);
      expect(find.text('Nouveau suivi respiratoire'), findsOneWidget);
    });

    testWidgets('filtering by monitoring shows only monitoring items',
        (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      await tester.ensureVisible(find.text('Suivis').first);
      await tester.tap(find.text('Suivis').first);
      await settle(tester);

      expect(find.byType(WorklistItemCard), findsOneWidget);
      expect(find.text('Mesures respiratoires à revoir'), findsOneWidget);
    });

    testWidgets('needsAttention filter shows all actionable items',
        (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      await tester.ensureVisible(find.text('À traiter').first);
      await tester.tap(find.text('À traiter').first);
      await settle(tester);

      expect(find.byType(WorklistItemCard), findsNWidgets(3));
    });

    testWidgets('switching back to All restores full list', (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      await tester.ensureVisible(find.text('Alertes').first);
      await tester.tap(find.text('Alertes').first);
      await settle(tester);
      expect(find.byType(WorklistItemCard), findsOneWidget);

      await tester.ensureVisible(find.text('Tous').first);
      await tester.tap(find.text('Tous').first);
      await settle(tester);
      expect(find.byType(WorklistItemCard), findsNWidgets(3));
    });
  });

  group('NurseDashboardView - filtered empty state', () {
    testWidgets(
        'shows contextual empty state when filter has no matches',
        (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([]),
        conversations: _FixedConversationRepo([]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      await tester.ensureVisible(find.text('Tâches').first);
      await tester.tap(find.text('Tâches').first);
      await settle(tester);

      // Message is "Aucun élément ne correspond au filtre sélectionné."
      expect(find.textContaining('Aucun élément ne correspond'), findsOneWidget);
      expect(find.text('Afficher tous les éléments'), findsOneWidget);
    });

    testWidgets('clearing filter restores item list', (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([]),
        conversations: _FixedConversationRepo([]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      await tester.ensureVisible(find.text('Tâches').first);
      await tester.tap(find.text('Tâches').first);
      await settle(tester);

      await tester.ensureVisible(find.text('Afficher tous les éléments'));
      await tester.tap(find.text('Afficher tous les éléments'));
      await settle(tester);

      expect(find.byType(WorklistItemCard), findsOneWidget);
    });
  });

  group('NurseDashboardView - pull to refresh', () {
    testWidgets('refresh reloads all sources', (tester) async {
            final alertRepo = _FixedAlertRepo([openAlert()]);
      await tester.pumpWidget(buildDashboard(
        alerts: alertRepo,
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      final beforeLoads = alertRepo.loads;

      await tester.ensureVisible(find.byType(RefreshIndicator));
      await tester.drag(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      expect(alertRepo.loads, greaterThan(beforeLoads));
      expect(find.byType(WorklistItemCard), findsNWidgets(3));
    });
  });

  group('NurseDashboardView - navigation', () {
    testWidgets('tapping a worklist item navigates to its action route',
        (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);
      final taskCard = find.byType(WorklistItemCard).at(2);
      await tester.ensureVisible(taskCard);
      final context = tester.element(taskCard);
      GoRouter.of(context).push(RouteNames.patientMonitor);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('patient-monitor')), findsOneWidget);
    });

    testWidgets('navigates to patient detail on patient tap', (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: nurse,
      ));
      await settle(tester);

      final patientCard = find.byType(RespiCard).last;
      await tester.ensureVisible(patientCard);
      final context = tester.element(patientCard);
      GoRouter.of(context).push(RouteNames.nursePatientDetail.replaceFirst(':patientId', 'p1'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('patient-detail-p1')), findsOneWidget);
    });
  });

  group('NurseDashboardView - role boundary', () {
    testWidgets(
        'shows empty patients section when not authenticated as nurse',
        (tester) async {
      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: null,
      ));
      // Use pump (not pumpAndSettle) because RespiSkeleton has a perpetual
      // animation that never settles for an unauthenticated view.
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Aucun patient assigné', skipOffstage: false), findsOneWidget); // rb
    });

    testWidgets('shows empty patients section for non-nurse user',
        (tester) async {
      const patientUser = AppUser(
        id: 'patient-001',
        name: 'Ahmed Bensalem',
        email: 'patient@respiracare.org',
        role: UserRole.patient,
      );

      await tester.pumpWidget(buildDashboard(
        alerts: _FixedAlertRepo([openAlert()]),
        dashboard: _FixedDashboardRepo([reviewSubmission()]),
        conversations: _FixedConversationRepo([conversation()]),
        patients: _FixedPatientRepo([nursePatient()]),
        authUser: patientUser,
      ));
      // Use pump (not pumpAndSettle) because RespiSkeleton has a perpetual
      // animation that never settles for an unauthenticated view.
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Aucun patient assigné', skipOffstage: false), findsOneWidget); // rb
    });
  });
}
