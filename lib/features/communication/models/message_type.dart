import 'package:flutter/material.dart';

/// Kind of a patient-visible message.
///
/// Internal nurse notes are NOT messages (see [InternalNote]) — they live in a
/// separate collection and are never shown to the patient. These four types
/// let the messaging system participate in the monitoring workflow instead of
/// being plain chat: a care update or follow-up can carry an action that opens
/// an existing feature.
enum MessageType {
  text,
  careUpdate,
  followUp,
  systemNotification;

  String get label {
    switch (this) {
      case MessageType.text:
        return 'Message';
      case MessageType.careUpdate:
        return 'Mise à jour de suivi';
      case MessageType.followUp:
        return 'Suivi demandé';
      case MessageType.systemNotification:
        return 'Notification';
    }
  }

  IconData get icon {
    switch (this) {
      case MessageType.text:
        return Icons.chat_bubble_outline_rounded;
      case MessageType.careUpdate:
        return Icons.monitor_heart_outlined;
      case MessageType.followUp:
        return Icons.event_note_outlined;
      case MessageType.systemNotification:
        return Icons.notifications_outlined;
    }
  }

  /// Types that may carry a patient-facing call to action.
  bool get isActionable =>
      this == MessageType.careUpdate || this == MessageType.followUp;
}
