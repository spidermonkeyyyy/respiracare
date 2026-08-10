/// Lifecycle state of an alert.
///
/// The lifecycle is deliberately explicit so that an alert can never silently
/// disappear just because a nurse opened it:
///
/// ```
/// unread -> acknowledged -> inProgress -> resolved
/// ```
///
/// Opening an alert does not change its status. Only an explicit nurse action
/// advances the lifecycle, which is what makes the trail auditable.
enum AlertStatus {
  unread,
  acknowledged,
  inProgress,
  resolved;

  String get label {
    switch (this) {
      case AlertStatus.unread:
        return 'Non traitée';
      case AlertStatus.acknowledged:
        return 'Prise en charge';
      case AlertStatus.inProgress:
        return 'En cours';
      case AlertStatus.resolved:
        return 'Résolue';
    }
  }

  /// True while the alert still needs nurse attention.
  bool get isOpen => this != AlertStatus.resolved;

  /// The status that follows this one, or `null` when already resolved.
  AlertStatus? get next {
    switch (this) {
      case AlertStatus.unread:
        return AlertStatus.acknowledged;
      case AlertStatus.acknowledged:
        return AlertStatus.inProgress;
      case AlertStatus.inProgress:
        return AlertStatus.resolved;
      case AlertStatus.resolved:
        return null;
    }
  }

  /// Guards illegal transitions such as resolving an untouched alert or
  /// re-opening a resolved one.
  bool canTransitionTo(AlertStatus target) {
    if (this == target) return false;
    if (this == AlertStatus.resolved) return false;
    return target.index > index;
  }

  String get storageKey => name;

  static AlertStatus fromStorageKey(String value) {
    return AlertStatus.values.firstWhere(
      (status) => status.storageKey == value,
      orElse: () => AlertStatus.unread,
    );
  }
}
