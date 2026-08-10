/// Lightweight French date/time formatting helpers.
///
/// The project intentionally avoids the `intl` package, so formats are
/// hand-rolled. Every helper accepts an optional `now` so unit tests can pin
/// the clock instead of depending on wall-clock time.
abstract class AppDateFormat {
  static const List<String> _months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  /// `08 août 2026`
  static String date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = _months[value.month - 1];
    return '$day $month ${value.year}';
  }

  /// `14:32`
  static String time(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// `08 août 2026 · 14:32`
  static String dateTime(DateTime value) => '${date(value)} · ${time(value)}';

  /// Verbose relative time, e.g. `Il y a 12 min`.
  static String relative(DateTime value, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(value);

    if (diff.isNegative || diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return 'Le ${date(value)}';
  }

  /// Compact relative time for dense list rows, e.g. `12 min`, `3 h`, `2 j`.
  static String shortRelative(DateTime value, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(value);

    if (diff.isNegative || diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    if (diff.inDays < 7) return '${diff.inDays} j';
    return date(value);
  }

  /// Day-aware timestamp for message rows: `Aujourd'hui · 14:32`,
  /// `Hier · 18:04`, `07 août · 09:20`.
  static String friendlyTimestamp(DateTime value, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    final today = DateTime(reference.year, reference.month, reference.day);
    final day = DateTime(value.year, value.month, value.day);
    final diff = today.difference(day).inDays;

    if (diff == 0) return "Aujourd'hui · $time";
    if (diff == 1) return 'Hier · $time';
    return '${date(value)} · $time';
  }
}
