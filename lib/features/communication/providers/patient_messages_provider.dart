import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/providers/auth_provider.dart';
import '../models/communication_task.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../repositories/conversation_repository.dart';
import '../repositories/mock_conversation_repository.dart';

/// Repository accessor for the communication feature.
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return MockConversationRepository();
});

/// Patient-facing conversation state.
///
/// Reads only the signed-in patient's own conversation. The repository already
/// strips internal notes, but this provider also keeps the patient strictly
/// scoped to their own data (step 4.10Q).
class PatientMessagesState {
  final List<Conversation> conversations;
  final List<CommunicationTask> tasks;
  final bool isLoading;
  final String? errorMessage;

  const PatientMessagesState({
    this.conversations = const [],
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PatientMessagesState copyWith({
    List<Conversation>? conversations,
    List<CommunicationTask>? tasks,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PatientMessagesState(
      conversations: conversations ?? this.conversations,
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  Conversation? get conversation =>
      conversations.isEmpty ? null : conversations.first;

  List<CommunicationTask> get openTasks =>
      tasks.where((task) => task.status.isOpen).toList();

  bool get hasOpenTasks => openTasks.isNotEmpty;
}

final patientMessagesProvider =
    StateNotifierProvider<PatientMessagesNotifier, PatientMessagesState>((ref) {
  final repository = ref.watch(conversationRepositoryProvider);
  final authState = ref.watch(authProvider);
  final patientId = authState.currentUser?.id ?? 'p1';
  return PatientMessagesNotifier(repository, patientId);
});

class PatientMessagesNotifier extends StateNotifier<PatientMessagesState> {
  PatientMessagesNotifier(this._repository, this.patientId)
      : super(const PatientMessagesState()) {
    load();
  }

  final ConversationRepository _repository;
  final String patientId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final conversations =
          await _repository.getConversationsForPatient(patientId);
      final tasks = await _repository.getPatientTasks(patientId);
      state = state.copyWith(
        conversations: conversations,
        tasks: tasks,
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de charger vos messages.',
      );
    }
  }

  /// Marks care-team messages as read when the patient opens the conversation.
  Future<void> openConversation(String conversationId) async {
    await _repository.markRead(conversationId, viewer: MessageSender.patient);
    await load();
  }

  Future<bool> sendMessage(String text) async {
    final conversation = state.conversation;
    if (conversation == null || text.trim().isEmpty) return false;
    state = state.copyWith(isLoading: true);
    try {
      await _repository.sendPatientMessage(conversation.id, text);
      await load();
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible d\'envoyer le message.',
      );
      return false;
    }
  }

  Future<void> completeTask(String taskId) async {
    await _repository.completeTask(taskId);
    await load();
  }
}
