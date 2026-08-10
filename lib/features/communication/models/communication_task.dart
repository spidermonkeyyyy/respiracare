import 'package:equatable/equatable.dart';

/// Patient-facing task, generated when the nurse requests something.
///
/// Tasks keep the patient out of the message stream: a request shows up under
/// "À faire" and links straight to the relevant existing workflow instead of
/// being buried in chat (step 4.10M / 4.10L).
enum TaskType {
  monitoring,
  inhalerVideo,
  followUp;

  String get label {
    switch (this) {
      case TaskType.monitoring:
        return 'Nouveau suivi respiratoire';
      case TaskType.inhalerVideo:
        return 'Nouvelle vidéo d\'inhalation';
      case TaskType.followUp:
        return 'Suivi demandé';
    }
  }
}

enum TaskStatus {
  open,
  done;

  String get label {
    switch (this) {
      case TaskStatus.open:
        return 'À faire';
      case TaskStatus.done:
        return 'Terminée';
    }
  }

  bool get isOpen => this == TaskStatus.open;
}

class CommunicationTask extends Equatable {
  final String id;
  final String patientId;
  final String? conversationId;

  final TaskType type;
  final String title;
  final String description;

  /// Existing in-app route the task opens, e.g. `/patient/monitoring`.
  final String actionRoute;

  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;

  /// Links back to the care request that created this task.
  final String? linkedCareRequestId;

  const CommunicationTask({
    required this.id,
    required this.patientId,
    this.conversationId,
    required this.type,
    required this.title,
    required this.description,
    required this.actionRoute,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.linkedCareRequestId,
  });

  CommunicationTask copyWith({
    String? id,
    String? patientId,
    String? conversationId,
    TaskType? type,
    String? title,
    String? description,
    String? actionRoute,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
    String? linkedCareRequestId,
  }) {
    return CommunicationTask(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      conversationId: conversationId ?? this.conversationId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      actionRoute: actionRoute ?? this.actionRoute,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      linkedCareRequestId: linkedCareRequestId ?? this.linkedCareRequestId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        conversationId,
        type,
        title,
        description,
        actionRoute,
        status,
        createdAt,
        dueDate,
        linkedCareRequestId,
      ];
}
