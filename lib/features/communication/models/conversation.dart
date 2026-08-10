import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'care_request.dart';
import 'communication_task.dart';
import 'message.dart';

/// A patient–care-team conversation.
///
/// The conversation bundles everything the nurse needs in one place:
/// patient-visible [messages], nurse-only [internalNotes] (never shown to the
/// patient), [careRequests] the nurse raised, and the resulting patient
/// [tasks]. The conversation belongs to the care team, not to an individual
/// nurse's personal account (step 4.10B / 4.10Q).
class Conversation extends Equatable {
  final String id;
  final String patientId;
  final String patientName;

  /// Short clinical context, e.g. `BPCO · GOLD III`.
  final String patientSummary;

  final List<Message> messages;
  final List<InternalNote> internalNotes;
  final List<CareRequest> careRequests;
  final List<CommunicationTask> tasks;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Unread count for the current viewer. Computed by the provider when it
  /// assembles the conversation (a patient only sees care-team unread, a nurse
  /// only sees patient unread).
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.patientSummary = '',
    this.messages = const [],
    this.internalNotes = const [],
    this.careRequests = const [],
    this.tasks = const [],
    required this.createdAt,
    required this.updatedAt,
    this.unreadCount = 0,
  });

  /// Most recent patient-visible message, or `null` if none.
  Message? get lastMessage => messages.isEmpty ? null : messages.last;

  String get lastMessagePreview {
    final last = lastMessage;
    if (last == null) return 'Aucun message pour le moment.';
    final prefix = last.isFromPatient ? 'Vous : ' : '${patientName.split(' ').first} : ';
    return '$prefix${last.text}';
  }

  Conversation copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? patientSummary,
    List<Message>? messages,
    List<InternalNote>? internalNotes,
    List<CareRequest>? careRequests,
    List<CommunicationTask>? tasks,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientSummary: patientSummary ?? this.patientSummary,
      messages: messages ?? this.messages,
      internalNotes: internalNotes ?? this.internalNotes,
      careRequests: careRequests ?? this.careRequests,
      tasks: tasks ?? this.tasks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        patientSummary,
        messages,
        internalNotes,
        careRequests,
        tasks,
        createdAt,
        updatedAt,
        unreadCount,
      ];
}

/// A point on the nurse's longitudinal care timeline (step 4.10S).
enum CareEventType {
  message,
  monitoringRequested,
  monitoringSubmitted,
  monitoringReviewed,
  internalNote,
  followUp;

  String get label {
    switch (this) {
      case CareEventType.message:
        return 'Message';
      case CareEventType.monitoringRequested:
        return 'Suivi demandé';
      case CareEventType.monitoringSubmitted:
        return 'Suivi transmis';
      case CareEventType.monitoringReviewed:
        return 'Suivi examiné';
      case CareEventType.internalNote:
        return 'Note interne';
      case CareEventType.followUp:
        return 'Suivi';
    }
  }

  IconData get icon {
    switch (this) {
      case CareEventType.message:
        return Icons.chat_bubble_outline_rounded;
      case CareEventType.monitoringRequested:
        return Icons.monitor_heart_outlined;
      case CareEventType.monitoringSubmitted:
        return Icons.upload_outlined;
      case CareEventType.monitoringReviewed:
        return Icons.visibility_outlined;
      case CareEventType.internalNote:
        return Icons.note_outlined;
      case CareEventType.followUp:
        return Icons.event_repeat_outlined;
    }
  }
}

class CareTimelineEvent extends Equatable {
  final String id;
  final CareEventType type;
  final String title;
  final DateTime timestamp;
  final String? detail;

  const CareTimelineEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.timestamp,
    this.detail,
  });

  @override
  List<Object?> get props => [id, type, title, timestamp, detail];
}
