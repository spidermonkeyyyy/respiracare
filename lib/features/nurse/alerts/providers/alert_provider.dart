import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/alert.dart';
import '../models/alert_group.dart';
import '../models/alert_priority.dart';
import '../models/alert_status.dart';
import '../repositories/alert_repository.dart';
import '../repositories/mock_alert_repository.dart';

/// Filters offered by the alert centre.
///
/// Kept intentionally small (step 4.9C): a long filter bar slows triage down
/// more than it speeds it up.
enum AlertFilter {
  all,
  unhandled,
  highPriority,
  toReview,
  resolved;

  String get label {
    switch (this) {
      case AlertFilter.all:
        return 'Toutes';
      case AlertFilter.unhandled:
        return 'Non traitées';
      case AlertFilter.highPriority:
        return 'Priorité élevée';
      case AlertFilter.toReview:
        return 'À revoir';
      case AlertFilter.resolved:
        return 'Résolues';
    }
  }

  bool matches(Alert alert) {
    switch (this) {
      case AlertFilter.all:
        return true;
      case AlertFilter.unhandled:
        return alert.status == AlertStatus.unread;
      case AlertFilter.highPriority:
        return alert.priority == AlertPriority.high && alert.isOpen;
      case AlertFilter.toReview:
        return alert.priority == AlertPriority.medium && alert.isOpen;
      case AlertFilter.resolved:
        return alert.status == AlertStatus.resolved;
    }
  }
}

class AlertListState {
  final List<Alert> alerts;
  final bool isLoading;
  final String? errorMessage;
  final AlertFilter filter;

  /// Set while a lifecycle mutation is in flight, so a single card can show a
  /// pending state without blocking the whole list.
  final String? pendingAlertId;

  const AlertListState({
    this.alerts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filter = AlertFilter.all,
    this.pendingAlertId,
  });

  AlertListState copyWith({
    List<Alert>? alerts,
    bool? isLoading,
    AlertFilter? filter,
    String? errorMessage,
    bool clearError = false,
    String? pendingAlertId,
    bool clearPending = false,
  }) {
    return AlertListState(
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingAlertId: clearPending ? null : (pendingAlertId ?? this.pendingAlertId),
    );
  }

  List<Alert> get filteredAlerts {
    final result = alerts.where(filter.matches).toList()
      ..sort((a, b) {
        final byPriority = a.priority.sortWeight.compareTo(b.priority.sortWeight);
        if (byPriority != 0) return byPriority;
        return b.createdAt.compareTo(a.createdAt);
      });
    return result;
  }

  /// Filtered alerts collapsed into one entry per patient.
  List<AlertGroup> get filteredGroups => AlertGroup.groupByPatient(filteredAlerts);

  int get unreadCount => alerts.where((alert) => alert.status == AlertStatus.unread).length;

  int get openCount => alerts.where((alert) => alert.isOpen).length;

  int get highPriorityOpenCount => alerts
      .where((alert) => alert.isOpen && alert.priority == AlertPriority.high)
      .length;

  bool get isEmpty => !isLoading && errorMessage == null && filteredAlerts.isEmpty;
}

class AlertListNotifier extends StateNotifier<AlertListState> {
  AlertListNotifier(this._repository) : super(const AlertListState());

  final AlertRepository _repository;

  /// Identifier of the signed-in nurse, injected by the screen so the
  /// repository can record who took ownership.
  String _nurseId = 'nurse_001';

  set nurseId(String value) => _nurseId = value;

  Future<void> loadAlerts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final alerts = await _repository.getAlerts();
      state = state.copyWith(alerts: alerts, isLoading: false, clearError: true);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger les alertes.',
      );
    }
  }

  void setFilter(AlertFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Alert? alertById(String alertId) {
    for (final alert in state.alerts) {
      if (alert.id == alertId) return alert;
    }
    return null;
  }

  /// Alerts belonging to one patient, respecting the active filter.
  List<Alert> alertsForPatient(String patientId) =>
      state.filteredAlerts.where((alert) => alert.patientId == patientId).toList();

  Future<bool> acknowledge(String alertId) {
    return _mutate(alertId, () => _repository.acknowledgeAlert(alertId, _nurseId));
  }

  Future<bool> recordAction(
    String alertId, {
    required NurseAction action,
    required NurseDecision decision,
    String? actionNote,
    String? justification,
  }) {
    return _mutate(
      alertId,
      () => _repository.recordAction(
        alertId,
        action: action,
        decision: decision,
        actionNote: actionNote,
        justification: justification,
      ),
    );
  }

  Future<bool> resolve(String alertId, {String? resolutionNote}) {
    return _mutate(
      alertId,
      () => _repository.resolveAlert(alertId, resolutionNote: resolutionNote),
    );
  }

  /// Runs a lifecycle mutation and swaps the updated alert into the list.
  ///
  /// Repository errors carry actionable French messages (missing
  /// justification, illegal transition), so they are surfaced verbatim rather
  /// than replaced with a generic failure string.
  Future<bool> _mutate(String alertId, Future<Alert> Function() operation) async {
    state = state.copyWith(pendingAlertId: alertId, clearError: true);
    try {
      final updated = await operation();
      state = state.copyWith(
        alerts: [
          for (final alert in state.alerts) alert.id == updated.id ? updated : alert,
        ],
        clearPending: true,
        clearError: true,
      );
      return true;
    } on StateError catch (error) {
      state = state.copyWith(clearPending: true, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        clearPending: true,
        errorMessage: 'Impossible de mettre à jour l\'alerte.',
      );
      return false;
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return MockAlertRepository();
});

final alertListProvider =
    StateNotifierProvider<AlertListNotifier, AlertListState>((ref) {
  return AlertListNotifier(ref.watch(alertRepositoryProvider));
});

/// Single alert, kept in sync with the list so detail screens rebuild after a
/// lifecycle change instead of holding a stale snapshot.
final alertByIdProvider = Provider.family<Alert?, String>((ref, alertId) {
  final state = ref.watch(alertListProvider);
  for (final alert in state.alerts) {
    if (alert.id == alertId) return alert;
  }
  return null;
});

final openAlertCountProvider = Provider<int>((ref) {
  return ref.watch(alertListProvider).openCount;
});

final unreadAlertCountProvider = Provider<int>((ref) {
  return ref.watch(alertListProvider).unreadCount;
});
