import 'package:equatable/equatable.dart';

import 'message_status.dart';
import 'message_type.dart';

/// A single patient-visible message in a conversation.
///
/// Every field here is safe to show to the patient. Internal nurse notes are a
/// distinct type ([InternalNote]) and must never be mixed into this list.
class Message extends Equatable {
  final String id;
  final String conversationId;
  final MessageSender sender;
  final MessageType type;
  final String text;

  final DateTime createdAt;

  /// Delivery state from the sender's perspective. For a [MessageSender.careTeam]
  /// message, `read` means the patient has opened it; for a patient message it
  /// means the nurse has reviewed it.
  final MessageStatus status;

  /// Optional patient call-to-action (care updates / follow-ups only).
  final String? actionLabel;
  final String? actionRoute;

  /// Links back to the care request / task this message was generated from.
  final String? linkedCareRequestId;
  final String? linkedTaskId;

  const Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.type,
    required this.text,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.actionLabel,
    this.actionRoute,
    this.linkedCareRequestId,
    this.linkedTaskId,
  });

  bool get isFromPatient => sender.isPatient;

  bool get hasAction => actionLabel != null && actionRoute != null;

  Message copyWith({
    String? id,
    String? conversationId,
    MessageSender? sender,
    MessageType? type,
    String? text,
    DateTime? createdAt,
    MessageStatus? status,
    String? actionLabel,
    String? actionRoute,
    String? linkedCareRequestId,
    String? linkedTaskId,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      actionLabel: actionLabel ?? this.actionLabel,
      actionRoute: actionRoute ?? this.actionRoute,
      linkedCareRequestId: linkedCareRequestId ?? this.linkedCareRequestId,
      linkedTaskId: linkedTaskId ?? this.linkedTaskId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        sender,
        type,
        text,
        createdAt,
        status,
        actionLabel,
        actionRoute,
        linkedCareRequestId,
        linkedTaskId,
      ];
}

/// A nurse-only clinical note.
///
/// Architecturally separated from [Message] so it is impossible to render it
/// inside the patient conversation by accident (step 4.10R / 4.10Q).
class InternalNote extends Equatable {
  final String id;
  final String conversationId;
  final String patientId;
  final String text;
  final DateTime createdAt;
  final String authorId;

  const InternalNote({
    required this.id,
    required this.conversationId,
    required this.patientId,
    required this.text,
    required this.createdAt,
    required this.authorId,
  });

  @override
  List<Object?> get props => [id, conversationId, patientId, text, createdAt, authorId];
}

/// Who authored a patient-visible message.
enum MessageSender {
  patient,
  careTeam,
  system;

  bool get isPatient => this == MessageSender.patient;

  bool get isCareTeam => this == MessageSender.careTeam;
}
