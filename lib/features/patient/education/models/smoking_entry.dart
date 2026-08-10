import 'package:equatable/equatable.dart';

/// Represents the intensity of a smoking craving
enum CravingIntensity {
  low('Faible', 'Faible envie de fumer, gérable'),
  moderate('Modérée', 'Envie présente, nécessite de l\'attention'),
  high('Forte', 'Envie intense, difficile à ignorer');

  const CravingIntensity(this.label, this.description);
  final String label;
  final String description;
}

/// Represents the trigger for a smoking craving
enum SmokingTrigger {
  stress('Stress', 'Situation stressante, anxiété'),
  habit('Habitude', 'Moment habituel (café, pause, etc.)'),
  social('Social', 'Entourage qui fume, sortie'),
  emotion('Émotion', 'Colère, tristesse, ennui'),
  other('Autre', 'Autre déclencheur');

  const SmokingTrigger(this.label, this.description);
  final String label;
  final String description;
}

/// Represents a daily smoking cessation tracking entry
class SmokingEntry extends Equatable {
  final String id;
  final DateTime date;
  final int cigarettesConsumed;
  final CravingIntensity cravingIntensity;
  final SmokingTrigger trigger;
  final String? personalNote;
  final DateTime createdAt;

  const SmokingEntry({
    required this.id,
    required this.date,
    required this.cigarettesConsumed,
    required this.cravingIntensity,
    required this.trigger,
    this.personalNote,
    required this.createdAt,
  });

  /// Formatted date for display
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate == today) {
      return 'Aujourd\'hui';
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (entryDate == yesterday) {
      return 'Hier';
    }

    final daysDiff = today.difference(entryDate).inDays;
    if (daysDiff < 7) {
      const weekdays = [
        'Lundi',
        'Mardi',
        'Mercredi',
        'Jeudi',
        'Vendredi',
        'Samedi',
        'Dimanche',
      ];
      return weekdays[date.weekday - 1];
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  /// Formatted time for display
  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  List<Object?> get props => [
        id,
        date,
        cigarettesConsumed,
        cravingIntensity,
        trigger,
        personalNote,
        createdAt,
      ];
}