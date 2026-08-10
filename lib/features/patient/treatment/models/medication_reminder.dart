/// Status of a single scheduled medication dose.
/// Uses neutral, non-guilt-inducing language internally.
enum MedicationStatus {
  /// Scheduled but the confirmation window hasn't opened yet.
  upcoming,

  /// Within the confirmation window and not yet confirmed.
  pending,

  /// Patient confirmed they took the dose.
  confirmed,

  /// Confirmation window passed without a confirmation.
  notConfirmed,
}

/// A single scheduled dose instance for a medication.
class MedicationReminder {
  final String id;
  final String medicationId;
  final String medicationLabel;
  final DateTime scheduledAt;
  final MedicationStatus status;
  final String frequency;
  final DateTime? confirmedAt;

  const MedicationReminder({
    required this.id,
    required this.medicationId,
    required this.medicationLabel,
    required this.scheduledAt,
    this.status = MedicationStatus.pending,
    this.frequency = 'Selon prescription',
    this.confirmedAt,
  });

  bool get isConfirmed => status == MedicationStatus.confirmed;
  bool get isActionable =>
      status == MedicationStatus.pending || status == MedicationStatus.notConfirmed;

  MedicationReminder copyWith({
    MedicationStatus? status,
    String? frequency,
    DateTime? confirmedAt,
  }) {
    return MedicationReminder(
      id: id,
      medicationId: medicationId,
      medicationLabel: medicationLabel,
      scheduledAt: scheduledAt,
      status: status ?? this.status,
      frequency: frequency ?? this.frequency,
      confirmedAt: confirmedAt ?? this.confirmedAt,
    );
  }

  @override
  String toString() =>
      'MedicationReminder(id: $id, scheduledAt: $scheduledAt, status: $status)';
}
