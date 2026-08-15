import 'package:equatable/equatable.dart';
import 'measurement_type.dart';

/// A single validated physiological measurement for trend visualization.
///
/// This is the domain/presentation model consumed by the clinical history
/// layer.  It is intentionally lightweight compared to
/// [MonitoringSubmission] so it can represent measurements that arrive from
/// any source (mock repository, future Supabase query, device sync).
///
/// Validation rules (enforced at construction via [ClinicalMeasurement.isValid]):
///  - [value] must be finite (not NaN / Infinity)
///  - [measuredAt] must be non-null and a valid instant
///  - [type] must be a recognized [MeasurementType]
///  - [unit] must not be empty
///
/// Invalid measurements are excluded from charts rather than coerced.
class ClinicalMeasurement extends Equatable {
  /// Stable identifier (may collide across sources — see project rules on
  /// duplicate timestamps).
  final String id;

  /// What was measured.
  final MeasurementType type;

  /// Raw numeric value (e.g. 97.0 for SpO₂, 72.0 for heart rate).
  final double value;

  /// Display unit (e.g. '%', 'bpm').
  final String unit;

  /// Wall-clock moment the measurement was taken (local time).
  final DateTime measuredAt;

  const ClinicalMeasurement({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.measuredAt,
  });

  /// Returns `true` only when every field passes clinical sanity checks.
  bool get isValid => value.isFinite && unit.isNotEmpty && value >= 0;

  /// Human-readable value string, omitting decimals for whole numbers.
  String get displayValue {
    final v = value;
    if (v == v.truncateToDouble()) {
      return '${v.toInt()}${unit.isNotEmpty ? ' $unit' : ''}';
    }
    return '$v$unit';
  }

  @override
  List<Object?> get props => [id, type, value, unit, measuredAt];
}
