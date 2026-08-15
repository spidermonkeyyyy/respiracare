import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../communication/providers/nurse_messages_provider.dart';
import '../../alerts/providers/alert_provider.dart';
import '../../patients/providers/nurse_patients_provider.dart';
import 'nurse_dashboard_provider.dart';
import '../models/nurse_worklist_item.dart';

/// Supported worklist filter categories (only domain-backed types).
enum NurseWorklistFilter {
  all,
  alerts,
  tasks,
  monitoring,
  needsAttention;

  bool matches(NurseWorklistItem item) {
    switch (this) {
      case NurseWorklistFilter.all:
        return true;
      case NurseWorklistFilter.alerts:
        return item.type == NurseWorklistItemType.alert;
      case NurseWorklistFilter.tasks:
        return item.type == NurseWorklistItemType.task;
      case NurseWorklistFilter.monitoring:
        return item.type == NurseWorklistItemType.monitoring;
      case NurseWorklistFilter.needsAttention:
        return item.isActionable;
    }
  }
}

/// Composed nurse worklist state.
///
/// Loading, empty and error remain distinct: UI later decides how to render
/// each.
///
/// The full composed [items] list is kept separate from the derived
/// [filteredItems] view. Changing [filter] never mutates the source list, so a
/// filter change does not trigger a repository reload and counts stay
/// consistent with the same underlying data.
class NurseWorklistState {
  final bool isLoading;
  final String? errorMessage;

  /// Full, deterministic-ordered composition for the nurse.
  final List<NurseWorklistItem> items;

  final NurseWorklistFilter filter;

  const NurseWorklistState({
    this.isLoading = true,
    this.errorMessage,
    this.items = const [],
    this.filter = NurseWorklistFilter.all,
  });

  NurseWorklistState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<NurseWorklistItem>? items,
    NurseWorklistFilter? filter,
  }) {
    return NurseWorklistState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      items: items ?? this.items,
      filter: filter ?? this.filter,
    );
  }

  /// Items matching the active filter. Deterministic (source order preserved).
  List<NurseWorklistItem> get filteredItems =>
      items.where(filter.matches).toList();

  /// Number of items still needing a nurse action — derived from the same
  /// [items] list so it cannot drift from the visible queue.
  int get attentionCount => items.where((item) => item.isActionable).length;

  int get openAlertsCount => items
      .where((i) => i.type == NurseWorklistItemType.alert && i.isActionable)
      .length;

  int get openTasksCount => items
      .where((i) => i.type == NurseWorklistItemType.task && i.isActionable)
      .length;

  int get monitoringReviewCount =>
      items.where((i) => i.type == NurseWorklistItemType.monitoring).length;

  bool get isEmpty => !isLoading && errorMessage == null && items.isEmpty;
}

/// Composition provider for the nurse clinical queue.
///
/// It reuses the existing per-domain providers (alerts, communication tasks,
/// dashboard monitoring submissions, patient roster) rather than querying any
/// repository or Supabase directly. Widgets never read this source stack.
final nurseWorklistProvider =
    StateNotifierProvider<NurseWorklistNotifier, NurseWorklistState>((ref) {
  return NurseWorklistNotifier(ref);
});

class NurseWorklistNotifier extends StateNotifier<NurseWorklistState> {
  NurseWorklistNotifier(this._ref) : super(const NurseWorklistState()) {
    _ref.listen(alertListProvider, (_, __) => _compose());
    _ref.listen(nurseMessagesProvider, (_, __) => _compose());
    _ref.listen(nursePatientsProvider, (_, __) => _compose());
    _ref.listen(nurseDashboardProvider, (_, __) => _compose());
    _compose();
  }

  final Ref _ref;

  void _compose() {
    final alerts = _ref.read(alertListProvider);
    final messages = _ref.read(nurseMessagesProvider);
    final patients = _ref.read(nursePatientsProvider);
    final dashboard = _ref.read(nurseDashboardProvider);

    final isLoading = alerts.isLoading ||
        messages.isLoading ||
        patients.isLoading ||
        dashboard.isLoading;

    String? errorMessage;
    for (final candidate in [
      alerts.errorMessage,
      messages.errorMessage,
      patients.errorMessage,
      dashboard.errorMessage,
    ]) {
      if (candidate != null) {
        errorMessage = candidate;
        break;
      }
    }

    final items = composeNurseWorklist(
      alerts: alerts.alerts,
      submissions: dashboard.recentSubmissions,
      tasks: [
        for (final conversation in messages.conversations) ...conversation.tasks
      ],
      patientNames: {
        for (final patient in patients.patients) patient.id: patient.fullName
      },
    );

    state = NurseWorklistState(
      isLoading: isLoading,
      errorMessage: errorMessage,
      items: items,
      filter: state.filter,
    );
  }

  /// Reloads every source domain and recomposes the queue.
  ///
  /// The active [NurseWorklistFilter] is preserved across a refresh: the source
  /// `items` are recomposed while `state.filter` remains unchanged.
  Future<void> refresh() async {
    if (state.isLoading) return;
    state = state.copyWith(clearError: true);
    await _ref.read(alertListProvider.notifier).loadAlerts();
    await _ref.read(nurseMessagesProvider.notifier).load();
    await _ref.read(nursePatientsProvider.notifier).loadPatients();
    await _ref.read(nurseDashboardProvider.notifier).loadDashboard();
    _compose();
  }

  /// Cleans any surfaced composition error.
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  /// Applies a local filter to the already-composed worklist.
  ///
  /// This never triggers a repository reload: the source [items] list is left
  /// intact, so clear/change filters are cheap and counts stay in sync.
  void setFilter(NurseWorklistFilter filter) {
    if (state.filter == filter) return;
    state = state.copyWith(filter: filter);
  }
}

/// Number of actionable worklist items for a specific patient.
///
/// Derived from the same [nurseWorklistProvider] state so it can never diverge
/// from the visible queue. Used by the assigned-patient summary.
final nursePatientWorkCountProvider =
    Provider.family<int, String>((ref, patientId) {
  final state = ref.watch(nurseWorklistProvider);
  return state.items
      .where((item) => item.patientId == patientId && item.isActionable)
      .length;
});
