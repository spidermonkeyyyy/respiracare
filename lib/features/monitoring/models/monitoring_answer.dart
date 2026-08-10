import 'package:equatable/equatable.dart';

class MonitoringAnswer extends Equatable {
  final String questionId;
  final dynamic value; // Option ID string or double/int number
  final String displayLabel;

  const MonitoringAnswer({
    required this.questionId,
    required this.value,
    required this.displayLabel,
  });

  @override
  List<Object?> get props => [questionId, value, displayLabel];
}
