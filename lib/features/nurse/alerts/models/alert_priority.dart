/// Clinical severity assigned to an alert by the configured rule set.
///
/// Priority is produced by the surveillance configuration (and, later, by the
/// backend rule engine). The frontend only renders it — it never derives or
/// upgrades a priority from raw patient data.
///
/// Accessibility: priority must never be communicated by colour alone. Every
/// presentation combines [label] with an icon and a text description. See
/// `widgets/alert_visuals.dart`.
enum AlertPriority {
  high,
  medium,
  low,
  informational;

  /// Short French label shown on badges.
  String get label {
    switch (this) {
      case AlertPriority.high:
        return 'Priorité élevée';
      case AlertPriority.medium:
        return 'À revoir';
      case AlertPriority.low:
        return 'Priorité faible';
      case AlertPriority.informational:
        return 'Information';
    }
  }

  /// Explains the expected handling delay, never the clinical meaning.
  String get handlingGuidance {
    switch (this) {
      case AlertPriority.high:
        return 'À examiner en priorité';
      case AlertPriority.medium:
        return 'À examiner lors de la revue de suivi';
      case AlertPriority.low:
        return 'À examiner quand disponible';
      case AlertPriority.informational:
        return 'Information, aucune action attendue';
    }
  }

  /// Sort weight: lower sorts first in the nurse queue.
  int get sortWeight {
    switch (this) {
      case AlertPriority.high:
        return 0;
      case AlertPriority.medium:
        return 1;
      case AlertPriority.low:
        return 2;
      case AlertPriority.informational:
        return 3;
    }
  }

  /// Stable key for persistence and for round-tripping through a future API.
  String get storageKey => name;

  static AlertPriority fromStorageKey(String value) {
    return AlertPriority.values.firstWhere(
      (priority) => priority.storageKey == value,
      orElse: () => AlertPriority.informational,
    );
  }
}
