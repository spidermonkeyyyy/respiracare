import 'package:equatable/equatable.dart';

/// Supported physiological measurement types for trend visualization.
///
/// SpO₂ readings are derived from [MonitoringSubmission.spo2Value].
/// Heart-rate readings are not yet part of the [MonitoringSubmission] domain
/// model (Step 11 documents this as a backend limitation); the measurement
/// type exists so the visualization layer and repository contract are
/// ready for future heart-rate support without rework.
enum MeasurementType {
  /// Peripheral oxygen saturation, expressed as a percentage (0–100).
  spo2,

  /// Heart rate in beats per minute.
  heartRate,
}

/// Presentation metadata for a [MeasurementType].
///
/// This is a lightweight, immutable value object — not a domain entity —
/// so the visualization layer can describe itself without duplicating the
/// underlying clinical data model.
class MeasurementTypeInfo extends Equatable {
  final MeasurementType type;
  final String label;
  final String unit;
  final String accessibilityLabel;

  const MeasurementTypeInfo({
    required this.type,
    required this.label,
    required this.unit,
    required this.accessibilityLabel,
  });

  static const Map<MeasurementType, MeasurementTypeInfo> all = {
    MeasurementType.spo2: MeasurementTypeInfo(
      type: MeasurementType.spo2,
      label: 'SpO₂',
      unit: '%',
      accessibilityLabel: 'saturation',
    ),
    MeasurementType.heartRate: MeasurementTypeInfo(
      type: MeasurementType.heartRate,
      label: 'Heart rate',
      unit: 'bpm',
      accessibilityLabel: 'heart rate',
    ),
  };

  static MeasurementTypeInfo of(MeasurementType type) => all[type]!;

  @override
  List<Object?> get props => [type, label, unit, accessibilityLabel];
}