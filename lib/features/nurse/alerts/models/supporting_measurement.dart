import 'package:equatable/equatable.dart';

/// Direction of a measurement relative to the patient's own recent reference.
///
/// This is a *descriptive* label supplied by the evaluation layer. It carries
/// no clinical judgement: `down` does not mean "dangerous", it only means the
/// value is lower than the stored reference.
enum MeasurementTrend {
  up,
  down,
  stable,
  unknown;

  String get label {
    switch (this) {
      case MeasurementTrend.up:
        return 'En hausse';
      case MeasurementTrend.down:
        return 'En baisse';
      case MeasurementTrend.stable:
        return 'Stable';
      case MeasurementTrend.unknown:
        return 'Non comparable';
    }
  }
}

/// A single data point that supports an alert, optionally compared to the
/// patient's own recent reference value.
///
/// Baseline comparison (step 4.9V) is presented as raw facts — current value,
/// reference value, variation — and never as an interpretation. The backend
/// rules layer decides whether a variation matters; this model only carries it.
class SupportingMeasurement extends Equatable {
  /// Display name of the metric, e.g. `SpO₂` or `Dyspnée`.
  final String label;

  /// Current value already formatted for display, e.g. `92 %` or `mMRC 3`.
  final String value;

  /// Most recent comparable value, when the evaluation layer supplied one.
  final String? referenceValue;

  /// Human-readable variation, e.g. `-3 points` or `+1`.
  final String? variation;

  final MeasurementTrend trend;

  /// Free-text qualifier such as `Modification signalée`, used for
  /// non-numeric metrics where a variation cannot be computed.
  final String? note;

  const SupportingMeasurement({
    required this.label,
    required this.value,
    this.referenceValue,
    this.variation,
    this.trend = MeasurementTrend.unknown,
    this.note,
  });

  /// True when there is enough information to render a baseline comparison.
  bool get hasComparison => referenceValue != null && referenceValue!.isNotEmpty;

  /// Compact one-line form used inside dense cards.
  String get summary {
    if (!hasComparison) return '$label: $value';
    final delta = variation != null && variation!.isNotEmpty ? ' ($variation)' : '';
    return '$label: $value — réf. $referenceValue$delta';
  }

  SupportingMeasurement copyWith({
    String? label,
    String? value,
    String? referenceValue,
    String? variation,
    MeasurementTrend? trend,
    String? note,
  }) {
    return SupportingMeasurement(
      label: label ?? this.label,
      value: value ?? this.value,
      referenceValue: referenceValue ?? this.referenceValue,
      variation: variation ?? this.variation,
      trend: trend ?? this.trend,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [label, value, referenceValue, variation, trend, note];
}
