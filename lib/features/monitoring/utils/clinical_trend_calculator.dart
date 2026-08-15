import 'package:equatable/equatable.dart';
import '../models/clinical_measurement.dart';
import '../models/measurement_type.dart';

/// Direction of a measurement trend, expressed in strictly numerical terms.
///
/// This is **never** a clinical diagnosis.  "upward" simply means the latest
/// reading is numerically higher than the earliest reading in the range.
enum TrendDirection {
  /// Fewer than the minimum readings required for classification.
  insufficientData,

  /// Readings did not meaningfully change across the period.
  stable,

  /// Latest reading is numerically higher than the earliest reading.
  upward,

  /// Latest reading is numerically lower than the earliest reading.
  downward,
}

/// Deterministic, non-clinical description of a trend.
class TrendSummary extends Equatable {
  final MeasurementType type;
  final TrendDirection direction;
  final String description;
  final int readingCount;

  /// Signed difference between latest and earliest value (nullable when
  /// there is insufficient data).
  final double? change;

  const TrendSummary({
    required this.type,
    required this.direction,
    required this.description,
    required this.readingCount,
    this.change,
  });

  @override
  List<Object?> get props => [type, direction, description, readingCount, change];
}

/// Isolated, pure-Dart trend calculator.
///
/// Rules (deterministic, testable):
///  - Fewer than [minReadingsForTrend] valid readings → insufficientData
///  - Otherwise compare earliest vs latest value
///  - A change within ±[stableThreshold] is treated as stable
///  - Language is descriptive, never diagnostic
class ClinicalTrendCalculator {
  /// Minimum readings needed before a trend is classified.
  static const int minReadingsForTrend = 2;

  /// Maximum absolute difference (in the measurement's unit) that still
  /// counts as "the same" reading.  For SpO₂ this is 2%, for heart rate
  /// this is 5 bpm.
  static double stableThreshold(MeasurementType type) {
    switch (type) {
      case MeasurementType.spo2:
        return 2.0;
      case MeasurementType.heartRate:
        return 5.0;
    }
  }

  /// Returns a [TrendSummary] for the given sorted (oldest→newest) list.
  ///
  /// Measurements are filtered to valid values and sorted here so callers
  /// can pass unsorted data safely.
  static TrendSummary calculate(
    List<ClinicalMeasurement> measurements,
    MeasurementType type,
  ) {
    // Filter to the requested type and valid values only.
    final valid = measurements
        .where((m) => m.type == type && m.value.isFinite && m.unit.isNotEmpty)
        .toList()
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

    final count = valid.length;
    final info = MeasurementTypeInfo.of(type);

    if (count < minReadingsForTrend) {
      return TrendSummary(
        type: type,
        direction: TrendDirection.insufficientData,
        description: 'Not enough readings to identify a trend.',
        readingCount: count,
        change: null,
      );
    }

    final earliest = valid.first.value;
    final latest = valid.last.value;
    final change = latest - earliest;
    final threshold = stableThreshold(type);

    final TrendDirection direction;
    final String description;

    if (change.abs() < threshold) {
      direction = TrendDirection.stable;
      description = 'Your ${info.accessibilityLabel} readings were similar across the selected period.';
    } else if (change > 0) {
      direction = TrendDirection.upward;
      description = 'Your latest ${info.accessibilityLabel} reading is higher than the earliest reading shown.';
    } else {
      direction = TrendDirection.downward;
      description = 'Your latest ${info.accessibilityLabel} reading is lower than the earliest reading shown.';
    }

    return TrendSummary(
      type: type,
      direction: direction,
      description: description,
      readingCount: count,
      change: change,
    );
  }
}