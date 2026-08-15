import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:respiracare/features/authentication/models/app_user.dart';
import 'package:respiracare/features/authentication/providers/auth_provider.dart';
import 'package:respiracare/features/authentication/repositories/auth_repository.dart';
import 'package:respiracare/features/nurse/dashboard/models/monitoring_rule.dart';
import 'package:respiracare/features/nurse/dashboard/providers/nurse_assignments_provider.dart';
import 'package:respiracare/features/nurse/patients/models/nurse_patient.dart';
import 'package:respiracare/features/nurse/patients/providers/nurse_patients_provider.dart';
import 'package:respiracare/features/nurse/patients/repositories/mock_nurse_patient_repository.dart';

/// Fixed auth repository exposing a chosen user so the real [authProvider]
/// bridge resolves to a deterministic identity.
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

/// Deterministic, zero-latency patient repository that records which nurse id
/// it was called with (to prove no id is hardcoded or injected from the UI).
class _FixedPatientRepo extends MockNursePatientRepository {
  _FixedPatientRepo(this.patients, {this.throwOnLoad = false});
  final List<NursePatient> patients;
  bool throwOnLoad;

  int loads = 0;
  String? lastNurseId;

  @override
  Future<List<NursePatient>> getAssignedPatients(String nurseId) async {
    loads++;
    lastNurseId = nurseId;
    if (throwOnLoad) throw Exception('backend down');
    return patients;
  }
}

void main() {
  NursePatient patient(String id, String fullName) => NursePatient(
        id: id,
        fullName: fullName,
        condition: 'BPCO',
        classification: 'GOLD III',
        priority: PriorityLevel.high,
        hasNewSubmission: true,
      );

  const nurse = AppUser(
    id: 'nurse-001',
    name: 'Sarah Bennani',
    email: 'nurse@respiracare.org',
    role: UserRole.nurse,
  );

  group('NurseAssignmentsNotifier (auth-bridged)', () {
    late ProviderContainer container;
    late _FixedPatientRepo patientRepo;

    tearDown(() => container.dispose());

    void build({AppUser? user, bool throwOnLoad = false}) {
      patientRepo = _FixedPatientRepo(
        [patient('p1', 'Ahmed Bensalem'), patient('p2', 'Mariem K.')],
        throwOnLoad: throwOnLoad,
      );
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FixedAuthRepo(user)),
          nursePatientRepositoryProvider.overrideWithValue(patientRepo),
        ],
      );
    }

    /// Lets the auth → provider-rebuild → patient-load chain fully resolve.
    ///
    /// First waits until [authProvider] settles on a terminal status, then —
    /// when [expectNurseLoad] is true — waits until the assignments provider has
    /// actually recorded the nurse identity and finished loading. Tracking the
    /// recorded nurse id avoids the pitfall of polling only on `isLoading`,
    /// which is already false during the pre-auth idle state.
    Future<void> settle({bool expectNurseLoad = false}) async {
      for (var i = 0; i < 300; i++) {
        final auth = container.read(authProvider);
        if (auth.status == AuthStatus.authenticated ||
            auth.status == AuthStatus.unauthenticated) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      for (var i = 0; i < 300; i++) {
        final state = container.read(nurseAssignmentsProvider);
        if (!expectNurseLoad) break;
        if (state.nurseId != null && !state.isLoading) break;
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
    }

    test('loads assigned patients using the auth-derived nurse id (no hardcode)',
        () async {
      build(user: nurse);
      container.read(nurseAssignmentsProvider);
      await settle(expectNurseLoad: true);

      final state = container.read(nurseAssignmentsProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.nurseId, 'nurse-001');
      expect(state.nurseName, 'Sarah Bennani');
      expect(state.assignedPatients, hasLength(2));
      // The id passed to the repository is the authenticated identity.
      expect(patientRepo.lastNurseId, 'nurse-001');
    });

    test('is an explicit empty state when no patients are assigned', () async {
      patientRepo = _FixedPatientRepo([]);
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FixedAuthRepo(nurse)),
          nursePatientRepositoryProvider.overrideWithValue(patientRepo),
        ],
      );
      container.read(nurseAssignmentsProvider);
      await settle(expectNurseLoad: true);

      final state = container.read(nurseAssignmentsProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      // Empty (no assigned patients) is not an error.
      expect(state.assignedPatients, isEmpty);
    });

    test('surfaces an error distinctly from an empty roster', () async {
      build(user: nurse, throwOnLoad: true);
      container.read(nurseAssignmentsProvider);
      await settle(expectNurseLoad: true);

      final state = container.read(nurseAssignmentsProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNotNull);
    });

    test('refresh re-invokes the assigned-patient repository', () async {
      build(user: nurse);
      container.read(nurseAssignmentsProvider);
      await settle(expectNurseLoad: true);

      // Read the notifier only after auth resolution so we hold the current
      // (non-disposed) instance after the provider rebuild.
      final notifier = container.read(nurseAssignmentsProvider.notifier);
      final before = patientRepo.loads;
      await notifier.refresh();
      await settle(expectNurseLoad: true);
      expect(patientRepo.loads, greaterThan(before));
      expect(container.read(nurseAssignmentsProvider).isLoading, isFalse);
    });

    test('does not load when no authenticated nurse session exists', () async {
      build(user: null);
      container.read(nurseAssignmentsProvider);
      await settle();

      final state = container.read(nurseAssignmentsProvider);
      // Idle/empty — not a perpetual loading state.
      expect(state.isLoading, isFalse);
      expect(state.nurseId, isNull);
      expect(state.assignedPatients, isEmpty);
      expect(patientRepo.lastNurseId, isNull);
    });

    test('does not load for an authenticated non-nurse user', () async {
      build(
        user: const AppUser(
          id: 'patient-001',
          name: 'Ahmed Bensalem',
          email: 'patient@respiracare.org',
          role: UserRole.patient,
        ),
      );
      container.read(nurseAssignmentsProvider);
      await settle();

      final state = container.read(nurseAssignmentsProvider);
      expect(state.isLoading, isFalse);
      expect(state.nurseId, isNull);
      expect(state.assignedPatients, isEmpty);
      expect(patientRepo.lastNurseId, isNull);
    });
  });
}