import 'package:flutter/material.dart';

/// Delivery state of a message, from the sender's point of view.
///
/// Kept deliberately simple for the MVP: a message is either still sending,
/// delivered, or read by the recipient. We never claim more than we can show.
enum MessageStatus {
  sending,
  sent,
  read;

  String get label {
    switch (this) {
      case MessageStatus.sending:
        return 'Envoi…';
      case MessageStatus.sent:
        return 'Envoyé';
      case MessageStatus.read:
        return 'Lu';
    }
  }

  IconData get icon {
    switch (this) {
      case MessageStatus.sending:
        return Icons.schedule_rounded;
      case MessageStatus.sent:
        return Icons.check_rounded;
      case MessageStatus.read:
        return Icons.done_all_rounded;
    }
  }
}
