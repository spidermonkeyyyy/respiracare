import 'package:equatable/equatable.dart';
import 'exercise.dart';

/// Represents a complete respiratory rehabilitation program
/// as prescribed by the healthcare team.
class RehabilitationProgram extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<Exercise> exercises;
  final int targetWeeklySessions;
  final DateTime startDate;
  final DateTime? endDate;

  const RehabilitationProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.exercises,
    required this.targetWeeklySessions,
    required this.startDate,
    this.endDate,
  });

  /// Returns today's recommended exercise based on the program schedule
  Exercise? getTodaysExercise() {
    if (exercises.isEmpty) return null;
    // Simple round-robin based on days since program start
    final daysSinceStart = DateTime.now().difference(startDate).inDays;
    final exerciseIndex = daysSinceStart % exercises.length;
    return exercises[exerciseIndex];
  }

  /// Returns the exercise scheduled for a specific day offset from start
  Exercise? getExerciseForDay(int dayOffset) {
    if (exercises.isEmpty) return null;
    final exerciseIndex = dayOffset % exercises.length;
    return exercises[exerciseIndex];
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        exercises,
        targetWeeklySessions,
        startDate,
        endDate,
      ];
}