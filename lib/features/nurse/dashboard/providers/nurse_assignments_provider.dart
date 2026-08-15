import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/models/app_user.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../alerts/providers/alert_provider.dart';
import '../../patients/models/nurse_patient.dart';
import '../../patients/providers/nurse_patients_provider.dart';
import '../../patients/repositories/nurse_patient_repository.dart';
import '../models/monitoring_rule.dart';
import '../providers/nurse_dashboard_provider.dart';

/// Deterministic state for the nurse's assigned-patient view.
///
/// This provider bridges the authenticated nurse identity (from
/// [authProvider]) and the patient roster (from
/// [NursePatientRepository.getAssignedPatients]).
class NurseAssignmentsState {
  final bool isLoading;
  final String? errorMessage;
  final String? nurseId;
  final String? nurseName;

  /// Patients directly assigned to the authenticated nurse.
  final List<NursePatient> assignedPatients;

  /// Number of assigned patients that require some nurse attention:
  /// either a new submission or a non-informational priority.
  final int attentionCount;

  const NurseAssignmentsState({
    this.isLoading = true,
    this.errorMessage,
    this.nurseId,
    this.nurseName,
    this.assignedPatients = const [],
    this.attentionCount = 0,
  });

  NurseAssignmentsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? nurseId,
    String? nurseName,
    List<NursePatient>? assignedPatients,
    int? attentionCount,
  }) {
    return NurseAssignmentsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      nurseId: nurseId ?? this.nurseId,
      nurseName: nurseName ?? this.nurseName,
      assignedPatients: assignedPatients ?? this.assignedPatients,
      attentionCount: attentionCount ?? this.attentionCount,
    );
  }
}

/// Aggregates the total number of items a nurse needs to act on.
///
/// Combines:
/// - Dashboard summary counts (high-priority + review-required)
/// - Open alerts that have not yet been resolved
final nurseAttentionCountProvider = Provider<int>((ref) {
  final dashboard = ref.watch(nurseDashboardProvider);
  final alerts = ref.watch(alertListProvider);

  var count = 0;

  if (dashboard.summary != null) {
    count += dashboard.summary!.highPriorityCount;
    count += dashboard.summary!.reviewRequiredCount;
  }

  count += alerts.openCount;

  return count;
});

/// Bridge between [authProvider] and [NursePatientRepository.getAssignedPatients].
///
/// Watches the auth state and, once a nurse session is available, loads the
/// nurse's assigned patient roster. When the auth state changes (e.g. on
/// logout) the provider is recreated by Riverpod with the new state.
final nurseAssignmentsProvider =
    StateNotifierProvider<NurseAssignmentsNotifier, NurseAssignmentsState>(
        (ref) {
  final authState = ref.watch(authProvider);
  final repository = ref.watch(nursePatientRepositoryProvider);

  String? nurseId;
  String? nurseName;
  if (authState.status == AuthStatus.authenticated &&
      authState.currentUser?.role == UserRole.nurse) {
    nurseId = authState.currentUser!.id;
    nurseName = authState.currentUser!.name;
  }

  return NurseAssignmentsNotifier(repository, nurseId, nurseName);
});

class NurseAssignmentsNotifier extends StateNotifier<NurseAssignmentsState> {
  final NursePatientRepository _repository;

  NurseAssignmentsNotifier(
    this._repository,
    String? nurseId,
    String? nurseName,
  )   : assert(nurseId == null || nurseName != null),
        super(const NurseAssignmentsState()) {
    if (nurseId != null) {
      state = state.copyWith(
        isLoading: true,
        nurseId: nurseId,
        nurseName: nurseName,
      );
      _loadAssigned(nurseId);
    } else {
      // No authenticated nurse session: settle into a stable empty/idle state
      // rather than a perpetual "loading" state. Loading and empty must remain
      // distinct (Step 12 rules); "not logistically applicable" is not "loading".
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadAssigned(String nurseId) async {
    try {
      final patients = await _repository.getAssignedPatients(nurseId);
      state = state.copyWith(
        isLoading: false,
        assignedPatients: patients,
        attentionCount: _countAttentionItems(patients),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger les patients assignés.',
      );
    }
  }

  /// Explicit refresh entry point for pull-to-refresh on the dashboard.
  Future<void> refresh() async {
    if (state.nurseId != null) {
      await _loadAssigned(state.nurseId!);
    }
  }

  int _countAttentionItems(List<NursePatient> patients) {
    return patients
        .where((patient) =>
            patient.hasNewSubmission ||
            patient.priority != PriorityLevel.informational)
        .length;
  }
}

/// Local, case-insensitive search over the already-authorized assigned
/// patients.
///
/// The source [NurseAssignmentsState.assignedPatients] is never mutated:
/// clearing the query restores the full authorized roster. This is
/// presentation-scoped filtering, not an authorization boundary — access
/// remains enforced by the assignment-aware repository/backend.
final nurseAssignedPatientSearchProvider =
    Provider.autoDispose.family<List<NursePatient>, String>((ref, query) {
  final assignments = ref.watch(nurseAssignmentsProvider);
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return assignments.assignedPatients;
  }
  return assignments.assignedPatients
      .where((patient) => patient.fullName.toLowerCase().contains(normalized))
      .toList();
});
