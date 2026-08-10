import 'package:flutter_test/flutter_test.dart';

import 'package:respiracare/features/communication/models/care_request.dart';
import 'package:respiracare/features/communication/models/message.dart';
import 'package:respiracare/features/communication/models/message_status.dart';
import 'package:respiracare/features/communication/repositories/mock_conversation_repository.dart';

void main() {
  group('MockConversationRepository', () {
    late MockConversationRepository repository;

    setUp(() => repository = MockConversationRepository());

    test('seeds three conversations, patient view strips internal notes',
        () async {
      final all = await repository.getConversations();
      expect(all.length, equals(3));

      final patientView = await repository.getConversationsForPatient('p1');
      expect(patientView.length, equals(1));
      expect(patientView.first.internalNotes, isEmpty);
    });

    test('sendPatientMessage appends a patient message', () async {
      final before =
          (await repository.getConversationById('conv_p1'))!.messages.length;
      final updated = await repository.sendPatientMessage('conv_p1', 'Bonjour');
      expect(updated.messages.length, equals(before + 1));
      expect(updated.messages.last.sender, equals(MessageSender.patient));
      expect(updated.messages.last.status, equals(MessageStatus.sent));
    });

    test('sendCareTeamMessage appends a care-team message', () async {
      final before =
          (await repository.getConversationById('conv_p2'))!.messages.length;
      final updated = await repository.sendCareTeamMessage(
        'conv_p2',
        text: 'Réponse équipe',
      );
      expect(updated.messages.length, equals(before + 1));
      expect(updated.messages.last.sender, equals(MessageSender.careTeam));
    });

    test('addInternalNote is nurse-only and never in patient view', () async {
      final note = await repository.addInternalNote(
        'conv_p2',
        text: 'Contact consigné.',
        authorId: 'nurse_001',
      );
      expect(note.text, equals('Contact consigné.'));

      final patientView = await repository.getConversationsForPatient('p2');
      expect(patientView.first.internalNotes, isEmpty);
    });

    test('markRead clears patient unread for the nurse viewer', () async {
      // p2 has an unread patient message from the seed.
      final before = await repository.getConversationById('conv_p2');
      final unreadBefore = before!.messages
          .where((m) =>
              m.sender == MessageSender.patient &&
              m.status != MessageStatus.read)
          .length;
      expect(unreadBefore, greaterThan(0));

      final after =
          await repository.markRead('conv_p2', viewer: MessageSender.careTeam);
      final unreadAfter = after.messages
          .where((m) =>
              m.sender == MessageSender.patient &&
              m.status != MessageStatus.read)
          .length;
      expect(unreadAfter, equals(0));
    });

    test(
        'createCareRequest creates a request, a patient task and an announcement',
        () async {
      final before = await repository.getConversationById('conv_p3');
      final reqBefore = before!.careRequests.length;
      final taskBefore = before.tasks.length;

      final updated = await repository.createCareRequest(
        conversationId: 'conv_p3',
        patientId: 'p3',
        type: CareRequestType.newMonitoring,
        reason: 'Vérification saturation',
        requestedData: const ['spo2'],
        nurseId: 'nurse_001',
      );

      expect(updated.careRequests.length, equals(reqBefore + 1));
      expect(updated.tasks.length, equals(taskBefore + 1));
      final hasAnnouncement = updated.messages.any(
          (m) => m.linkedTaskId != null && m.sender == MessageSender.careTeam);
      expect(hasAnnouncement, isTrue);
    });

    test('completeTask marks the task done and the linked request completed',
        () async {
      final task = await repository.completeTask('t_p1_1');
      expect(task.status.name, equals('done'));

      final conversation = await repository.getConversationById('conv_p1');
      final request =
          conversation!.careRequests.firstWhere((r) => r.id == 'cr_p1_1');
      expect(request.status, equals(CareRequestStatus.completed));
    });

    test('getPatientTasks returns the patient tasks across conversations',
        () async {
      final tasks = await repository.getPatientTasks('p1');
      expect(tasks.any((t) => t.id == 't_p1_1'), isTrue);
    });
  });
}
