/// Aggregated adherence data for a single calendar day.
class AdherenceRecord {
  final DateTime date;
  final int scheduledCount;
  final int confirmedCount;

  const AdherenceRecord({
    required this.date,
    required this.scheduledCount,
    required this.confirmedCount,
  });

  int get notConfirmedCount => scheduledCount - confirmedCount;

  /// Adherence rate between 0.0 and 1.0.
  double get adherenceRate =>
      scheduledCount == 0 ? 1.0 : confirmedCount / scheduledCount;

  /// Whether any dose that day was not confirmed.
  bool get hasMissed => notConfirmedCount > 0;

  /// Whether the day has no scheduled doses (e.g. rest day or no data).
  bool get isEmpty => scheduledCount == 0;

  @override
  String toString() =>
      'AdherenceRecord(date: $date, confirmed: $confirmedCount/$scheduledCount)';
}
