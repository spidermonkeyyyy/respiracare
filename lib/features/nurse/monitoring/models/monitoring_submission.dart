import 'package:equatable/equatable.dart';
import '../../dashboard/models/monitoring_rule.dart';

class MonitoringSubmission extends Equatable {
  final String id;
  final String patientId;
  final DateTime submittedAt;
  final int spo2;
  final int dyspneaScore;
  final String coughStatus;
  final String sputumStatus;
  final String? overallStatus;
  final String? notes;
  final List<RuleEvaluationResult> ruleResults;

  const MonitoringSubmission({
    required this.id,
    required this.patientId,
    required this.submittedAt,
    required this.spo2,
    required this.dyspneaScore,
    required this.coughStatus,
    required this.sputumStatus,
    this.overallStatus,
    this.notes,
    this.ruleResults = const [],
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        submittedAt,
        spo2,
        dyspneaScore,
        coughStatus,
        sputumStatus,
        overallStatus,
        notes,
        ruleResults,
      ];
}
