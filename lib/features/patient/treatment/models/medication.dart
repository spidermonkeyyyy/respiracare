/// Device type for the prescribed inhaler or medication
enum MedicationDeviceType {
  pressurizedInhaler,  // pMDI — ex: Ventoline
  dryPowderInhaler,    // DPI  — ex: Turbuhaler
  nebulizer,
  oral,
  other,
}

/// Generic medication model.
/// Labels are deliberately generic — real names come from the prescribing backend.
class Medication {
  final String id;
  final String label;
  final String prescribedFrequency;
  final MedicationDeviceType deviceType;

  const Medication({
    required this.id,
    required this.label,
    required this.prescribedFrequency,
    this.deviceType = MedicationDeviceType.pressurizedInhaler,
  });

  bool get isInhaler =>
      deviceType == MedicationDeviceType.pressurizedInhaler ||
      deviceType == MedicationDeviceType.dryPowderInhaler ||
      deviceType == MedicationDeviceType.nebulizer;

  @override
  String toString() => 'Medication(id: $id, label: $label)';
}
