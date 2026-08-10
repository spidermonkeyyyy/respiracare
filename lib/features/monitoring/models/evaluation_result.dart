import 'package:equatable/equatable.dart';

enum EvaluationStatus {
  normal,
  reviewRequired,
}

class EvaluationResult extends Equatable {
  final EvaluationStatus status;
  final List<String> triggeredRuleIds;
  final String patientMessage;

  const EvaluationResult({
    required this.status,
    this.triggeredRuleIds = const [],
    required this.patientMessage,
  });

  @override
  List<Object?> get props => [status, triggeredRuleIds, patientMessage];
}
