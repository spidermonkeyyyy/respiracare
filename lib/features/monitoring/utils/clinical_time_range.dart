import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;

// Re-export DateTimeRange from Flutter so callers don't need a separate import.
export 'package:flutter/material.dart' show DateTimeRange;

/// Predefined historical ranges selectable by the patient.
///
/// Labels are intentionally simple (not "168 hours").
enum ClinicalTimeRange {
  days7,
  days30,
  days90,
}

/// Extension that adds convenience methods to [ClinicalTimeRange].
extension ClinicalTimeRangeExtensions on ClinicalTimeRange {
  String get label {
    switch (this) {
      case ClinicalTimeRange.days7:
        return '7 days';
      case ClinicalTimeRange.days30:
        return '30 days';
      case ClinicalTimeRange.days90:
        return '90 days';
    }
  }

  int get days {
    switch (this) {
      case ClinicalTimeRange.days7:
        return 7;
      case ClinicalTimeRange.days30:
        return 30;
      case ClinicalTimeRange.days90:
        return 90;
    }
  }

  /// Computes the inclusive [start, end] window for this range relative to
  /// [now].  Tests can inject [now] for deterministic behaviour.
  DateTimeRange toDateTimeRange({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final end =
        DateTime(reference.year, reference.month, reference.day, 23, 59, 59);
    final start = end.subtract(Duration(days: days - 1));
    // Start at 00:00:00 of the start day.
    final startDay = DateTime(start.year, start.month, start.day);
    return DateTimeRange(start: startDay, end: end);
  }
}

class TimeRangeOption extends Equatable {
  final ClinicalTimeRange range;
  final String label;
  final int days;

  const TimeRangeOption({
    required this.range,
    required this.label,
    required this.days,
  });

  static const List<TimeRangeOption> all = [
    TimeRangeOption(range: ClinicalTimeRange.days7, label: '7 days', days: 7),
    TimeRangeOption(
        range: ClinicalTimeRange.days30, label: '30 days', days: 30),
    TimeRangeOption(
        range: ClinicalTimeRange.days90, label: '90 days', days: 90),
  ];

  /// Computes the inclusive [start, end] window for this range relative to
  /// [now].  Tests can inject [now] for deterministic behaviour.
  DateTimeRange toDateTimeRange({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final end =
        DateTime(reference.year, reference.month, reference.day, 23, 59, 59);
    final start = end.subtract(Duration(days: days - 1));
    // Start at 00:00:00 of the start day.
    final startDay = DateTime(start.year, start.month, start.day);
    return DateTimeRange(start: startDay, end: end);
  }

  @override
  List<Object?> get props => [range, label, days];
}
