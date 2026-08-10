import 'package:equatable/equatable.dart';

enum EscalationPriority { normal, high }

enum EscalationReason { symptomChange, treatmentConcern, inhalerTechnique, other }

extension EscalationReasonLabel on EscalationReason {
  String get label {
    switch (this) {
      case EscalationReason.symptomChange:
        return 'Évolution symptomatique';
      case EscalationReason.treatmentConcern:
        return 'Préoccupation thérapeutique';
      case EscalationReason.inhalerTechnique:
        return 'Technique d’inhalation';
      case EscalationReason.other:
        return 'Autre';
    }
  }
}

class EscalationRequest extends Equatable {
  final String id;
  final String patientId;
  final EscalationReason reason;
  final EscalationPriority priority;
  final String nurseSummary;
  final String? supportingInformation;
  final DateTime createdAt;

  const EscalationRequest({
    required this.id,
    required this.patientId,
    required this.reason,
    required this.priority,
    required this.nurseSummary,
    this.supportingInformation,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, patientId, reason, priority, nurseSummary, supportingInformation, createdAt];
}
