import 'package:equatable/equatable.dart';

/// What a care request is asking the patient to do.
enum CareRequestType {
  newMonitoring,
  inhalerVideo,
  other;

  String get label {
    switch (this) {
      case CareRequestType.newMonitoring:
        return 'Nouveau suivi respiratoire';
      case CareRequestType.inhalerVideo:
        return 'Vérification de la technique d\'inhalation';
      case CareRequestType.other:
        return 'Autre suivi';
    }
  }

  /// Route the patient uses to fulfil the request (reuses an existing flow).
  String get patientRoute {
    switch (this) {
      case CareRequestType.newMonitoring:
        return '/patient/monitoring';
      case CareRequestType.inhalerVideo:
        return '/patient/education/inhaler';
      case CareRequestType.other:
        return '/patient/home';
    }
  }
}

enum CareRequestStatus {
  pending,
  completed;

  String get label {
    switch (this) {
      case CareRequestStatus.pending:
        return 'En attente';
      case CareRequestStatus.completed:
        return 'Complétée';
    }
  }

  bool get isPending => this == CareRequestStatus.pending;
}

/// A request raised by the nurse that becomes an actionable patient task.
///
/// The request and its resulting [CommunicationTask] are created together so
/// the patient never has to dig through the conversation to find what to do
/// (step 4.10K / 4.10M). The nurse's wording is captured verbatim and never
/// interpreted as a clinical recommendation.
class CareRequest extends Equatable {
  final String id;
  final String conversationId;
  final String patientId;

  final CareRequestType type;
  final String reason;

  /// Optional measurement keys the nurse wants updated, e.g. `spo2`, `dyspnea`.
  final List<String> requestedData;

  final CareRequestStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String createdByNurseId;

  const CareRequest({
    required this.id,
    required this.conversationId,
    required this.patientId,
    required this.type,
    required this.reason,
    this.requestedData = const [],
    required this.status,
    required this.createdAt,
    this.dueDate,
    required this.createdByNurseId,
  });

  CareRequest copyWith({
    String? id,
    String? conversationId,
    String? patientId,
    CareRequestType? type,
    String? reason,
    List<String>? requestedData,
    CareRequestStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
    String? createdByNurseId,
  }) {
    return CareRequest(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      patientId: patientId ?? this.patientId,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      requestedData: requestedData ?? this.requestedData,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      createdByNurseId: createdByNurseId ?? this.createdByNurseId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        patientId,
        type,
        reason,
        requestedData,
        status,
        createdAt,
        dueDate,
        createdByNurseId,
      ];
}
