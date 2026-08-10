import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:respiracare/features/communication/models/care_request.dart';
import 'package:respiracare/features/communication/providers/nurse_messages_provider.dart';
import 'package:respiracare/features/communication/providers/patient_messages_provider.dart';
import 'package:respiracare/features/communication/repositories/mock_conversation_repository.dart';

void main() {
  group('NurseMessagesNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          conversationRepositoryProvider
              .overrideWithValue(MockConversationRepository()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('load populates conversations and computes unread', () async {
      // allow the constructor microtask to run
      await Future<void>.delayed(Duration.zero);
      final state = container.read(nurseMessagesProvider);
      expect(state.isLoading, isFalse);
      expect(state.conversations.length, equals(3));
      expect(state.totalUnread, greaterThan(0));
    });

    test('unread filter keeps only conversations with patient unread',
        () async {
      await Future<void>.delayed(Duration.zero);
      final notifier = container.read(nurseMessagesProvider.notifier);
      notifier.setFilter(NurseConversationFilter.unread);
      final filtered =
          container.read(nurseMessagesProvider).filteredConversations;
      expect(
          filtered.every(
              (c) => container.read(nurseMessagesProvider).unreadFor(c) > 0),
          isTrue);
    });

    test('search matches on patient name', () async {
      await Future<void>.delayed(Duration.zero);
      final notifier = container.read(nurseMessagesProvider.notifier);
      notifier.search('Mariem');
      final filtered =
          container.read(nurseMessagesProvider).filteredConversations;
      expect(filtered.length, equals(1));
      expect(filtered.first.patientName, contains('Mariem'));
    });

    test('sending a care-team message appends to the conversation', () async {
      await Future<void>.delayed(Duration.zero);
      final notifier = container.read(nurseMessagesProvider.notifier);
      final before =
          (await notifier.getConversation('conv_p3'))!.messages.length;
      final ok =
          await notifier.sendMessage('conv_p3', 'Merci de votre retour.');
      expect(ok, isTrue);
      final after =
          (await notifier.getConversation('conv_p3'))!.messages.length;
      expect(after, equals(before + 1));
    });

    test('createCareRequest updates the conversation state', () async {
      await Future<void>.delayed(Duration.zero);
      final notifier = container.read(nurseMessagesProvider.notifier);
      final ok = await notifier.createCareRequest(
        conversationId: 'conv_p3',
        patientId: 'p3',
        type: CareRequestType.newMonitoring,
        reason: 'Contrôle saturation',
      );
      expect(ok, isTrue);
      final conversation = (await notifier.getConversation('conv_p3'))!;
      expect(conversation.careRequests.length, equals(1));
      expect(conversation.tasks.length, equals(1));
    });

    test('addInternalNote never appears in the patient view', () async {
      await Future<void>.delayed(Duration.zero);
      final notifier = container.read(nurseMessagesProvider.notifier);
      final ok = await notifier.addInternalNote('conv_p3', 'Escalade notée.');
      expect(ok, isTrue);

      final repo = container.read(conversationRepositoryProvider);
      final patientView = await repo.getConversationsForPatient('p3');
      expect(patientView.first.internalNotes, isEmpty);
    });
  });
}
