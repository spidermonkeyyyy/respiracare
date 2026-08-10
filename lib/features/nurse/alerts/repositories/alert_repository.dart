import '../models/alert.dart';
import '../models/alert_priority.dart';
import '../models/alert_status.dart';

/// Data access contract for clinical alerts.
///
/// Screens and widgets never touch alert data directly — they always go
/// through a provider that depends on this abstraction. That keeps the mock
/// implementation swappable for a real backend without any UI change.
abstract class AlertRepository {
  Future<List<Alert>> getAlerts();

  Future<List<Alert>> getPatientAlerts(String patientId);

  Future<Alert?> getAlertById(String alertId);

  Future<List<Alert>> getAlertsByStatus(AlertStatus status);

  Future<List<Alert>> getAlertsByPriority(AlertPriority priority);

  /// Moves an alert from `unread` to `acknowledged` and assigns it.
  Future<Alert> acknowledgeAlert(String alertId, String nurseId);

  /// Records the chosen follow-up and moves the alert to `inProgress`.
  ///
  /// Implementations must reject an override without a justification, and an
  /// `other` action without a note, so the traceability rule cannot be
  /// bypassed by a caller.
  Future<Alert> recordAction(
    String alertId, {
    required NurseAction action,
    required NurseDecision decision,
    String? actionNote,
    String? justification,
  });

  /// Closes the alert. Only permitted once it has been acknowledged.
  Future<Alert> resolveAlert(String alertId, {String? resolutionNote});
}
