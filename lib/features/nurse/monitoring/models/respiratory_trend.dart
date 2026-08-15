import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;

/// Historical windows selectable on the respiratory evolution charts
/// (SCR-NUR-06). Labels are in French to match the nurse app UI.
enum TrendTimeframe {
  days7('7 jours', 7),
  days14('14 jours', 14),
  days30('30 jours', 30),
  days90('90 jours', 90);

  const TrendTimeframe(this.label, this.days);

  final String label;
  final int days;

  /// Inclusive [start, end] window relative to [now] (default: today).
  ///
  /// The window runs from 00:00:00 of the start day through 23:59:59 of the
  /// end day so that the plotted dates align cleanly on a day basis.
  DateTimeRange window({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final end =
        DateTime(reference.year, reference.month, reference.day, 23, 59, 59);
    final start = end.subtract(Duration(days: days - 1));
    final startDay = DateTime(start.year, start.month, start.day);
    return DateTimeRange(start: startDay, end: end);
  }
}

/// Patient-reported sputum severity, used for the sputum marker strip.
enum SputumSeverity {
  none('Aucun'),
  low('Peu'),
  moderate('Modéré'),
  high('Important');

  const SputumSeverity(this.label);

  final String label;
}

/// One day in a patient's respiratory trend series.
///
/// Values are nullable because not every metric is captured every day
/// (e.g. the CAT score may only be self-reported weekly, while SpO₂ is
/// daily). Charts skip null points for their own metric instead of
/// interpolating a fabricated value.
class RespiratoryTrendPoint extends Equatable {
  final DateTime date;

  /// Peripheral oxygen saturation in % (0–100).
  final int? spo2;

  /// COPD Assessment Test total score (0–40, higher = worse).
  final int? catScore;

  /// mMRC dyspnoea grade (0–4, higher = worse).
  final int? mmrcGrade;

  /// Patient-reported sputum severity.
  final SputumSeverity? sputum;

  /// `true` when an alert or medication change was flagged on this date.
  final bool hasAlert;

  const RespiratoryTrendPoint({
    required this.date,
    this.spo2,
    this.catScore,
    this.mmrcGrade,
    this.sputum,
    this.hasAlert = false,
  });

  @override
  List<Object?> get props => [
        date,
        spo2,
        catScore,
        mmrcGrade,
        sputum,
        hasAlert,
      ];
}
