import 'package:equatable/equatable.dart';

/// Represents an educational content item (article, video, guide)
class EducationalContent extends Equatable {
  final String id;
  final String title;
  final String summary;
  final String content; // Full content (placeholder for now)
  final String category; // e.g., 'sevrage', 'rehabilitation', 'inhalation'
  final String? imageUrl;
  final bool isPlaceholder; // True if content is not yet validated by clinical team

  const EducationalContent({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    this.imageUrl,
    this.isPlaceholder = true,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        summary,
        content,
        category,
        imageUrl,
        isPlaceholder,
      ];
}

/// Categories for educational content
class EducationalCategory {
  static const String sevrage = 'sevrage';
  static const String rehabilitation = 'rehabilitation';
  static const String inhalation = 'inhalation';
  static const String general = 'general';

  static const List<String> all = [sevrage, rehabilitation, inhalation, general];

  static String getLabel(String category) {
    switch (category) {
      case sevrage:
        return 'Sevrage tabagique';
      case rehabilitation:
        return 'Rééducation respiratoire';
      case inhalation:
        return 'Technique d\'inhalation';
      case general:
        return 'Santé respiratoire';
      default:
        return category;
    }
  }
}