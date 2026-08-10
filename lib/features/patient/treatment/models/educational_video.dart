class EducationalVideo {
  final String id;
  final String title;
  final String description;
  final Duration duration;
  final bool completed;

  const EducationalVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    this.completed = false,
  });

  EducationalVideo copyWith({
    bool? completed,
  }) {
    return EducationalVideo(
      id: id,
      title: title,
      description: description,
      duration: duration,
      completed: completed ?? this.completed,
    );
  }
}
