import 'package:equatable/equatable.dart';

/// Represents a single respiratory rehabilitation exercise
/// as prescribed by the healthcare team.
class Exercise extends Equatable {
  final String id;
  final String name;
  final String description;
  final Duration duration;
  final String? videoUrl; // Placeholder for educational video
  final String instructions; // Validated by healthcare team
  final int order; // Display order in program

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    this.videoUrl,
    required this.instructions,
    required this.order,
  });

  /// Formatted duration string for display (e.g., "10 min")
  String get formattedDuration {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMinutes}min';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        duration,
        videoUrl,
        instructions,
        order,
      ];
}
