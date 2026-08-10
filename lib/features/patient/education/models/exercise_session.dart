import 'package:equatable/equatable.dart';

/// Represents a completed exercise session by the patient
class ExerciseSession extends Equatable {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final DateTime completedAt;
  final Duration actualDuration;
  final int? perceivedEffort; // 1-10 scale, optional
  final String? notes;

  const ExerciseSession({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.completedAt,
    required this.actualDuration,
    this.perceivedEffort,
    this.notes,
  });

  /// Formatted duration string for display
  String get formattedDuration {
    final minutes = actualDuration.inMinutes;
    if (minutes < 60) {
      return '${minutes} min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}min';
  }

  /// Formatted date/time for display
  String get formattedDateTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate =
        DateTime(completedAt.year, completedAt.month, completedAt.day);

    if (sessionDate == today) {
      return 'Aujourd\'hui · ${_formatTime(completedAt)}';
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (sessionDate == yesterday) {
      return 'Hier · ${_formatTime(completedAt)}';
    }

    return '${_formatDate(completedAt)} · ${_formatTime(completedAt)}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  @override
  List<Object?> get props => [
        id,
        exerciseId,
        exerciseName,
        completedAt,
        actualDuration,
        perceivedEffort,
        notes,
      ];
}
