import 'package:equatable/equatable.dart';

enum QuestionType {
  singleChoice,
  numericInput,
}

class QuestionOption extends Equatable {
  final String id;
  final String label;
  final String? description;

  const QuestionOption({
    required this.id,
    required this.label,
    this.description,
  });

  @override
  List<Object?> get props => [id, label, description];
}

class MonitoringQuestion extends Equatable {
  final String id;
  final QuestionType type;
  final String title;
  final String? description;
  final List<QuestionOption> options;
  final bool required;
  final int order;
  final String? unit; // e.g. "%" for SpO2
  final double? minValue; // e.g. 70
  final double? maxValue; // e.g. 100

  const MonitoringQuestion({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.options = const [],
    this.required = true,
    required this.order,
    this.unit,
    this.minValue,
    this.maxValue,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        options,
        required,
        order,
        unit,
        minValue,
        maxValue,
      ];
}
