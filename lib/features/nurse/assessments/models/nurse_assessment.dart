import 'package:equatable/equatable.dart';

enum AssessmentStatus { noConcern, enhancedMonitoring, patientContact, pneumologistReview }

extension AssessmentStatusLabel on AssessmentStatus {
  String get label {
    switch (this) {
      case AssessmentStatus.noConcern:
        return 'Pas de changement préoccupant';
      case AssessmentStatus.enhancedMonitoring:
        return 'Surveillance renforcée';
      case AssessmentStatus.patientContact:
        return 'Contact patient nécessaire';
      case AssessmentStatus.pneumologistReview:
        return 'Avis pneumologue nécessaire';
    }
  }
}

class NurseAssessment extends Equatable {
  final String id;
  final String patientId;
  final AssessmentStatus status;
  final String observation;
  final String action;
  final String? note;
  final DateTime createdAt;

  const NurseAssessment({
    required this.id,
    required this.patientId,
    required this.status,
    required this.observation,
    required this.action,
    this.note,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, patientId, status, observation, action, note, createdAt];
}
