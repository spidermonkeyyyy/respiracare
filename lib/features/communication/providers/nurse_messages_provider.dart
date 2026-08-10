import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/care_request.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/message_status.dart';
import '../models/message_type.dart';
import '../repositories/conversation_repository.dart';
import 'patient_messages_provider.dart';

/// Filter set for the nurse conversation list (step 4.10G). Kept short.
enum NurseConversationFilter {
  all,
  unread,
  followed;

  String get label {
    switch (this) {
      case NurseConversationFilter.all:
        return 'Tous';
      case NurseConversationFilter.unread:
        return 'Non lus';
      case NurseConversationFilter.followed:
        return 'Patients suivis';
    }
  }

  bool matches(Conversation conversation, int unreadCount) {
    switch (this) {
      case NurseConversationFilter.all:
        return true;
      case NurseConversationFilter.unread:
        return unreadCount > 0;
      case NurseConversationFilter.followed:
        // In the mock every listed patient is followed; this keeps the filter
        // meaningful without inventing a separate follow flag.
        return true;
    }
  }
}

class NurseMessagesState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final NurseConversationFilter filter;

  const NurseMessagesState({
    this.conversations = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.filter = NurseConversationFilter.all,
  });

  NurseMessagesState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    NurseConversationFilter? filter,
    bool clearError = false,
  }) {
    return NurseMessagesState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
    );
  }

  int unreadFor(Conversation conversation) => conversation.messages
      .where((m) => m.sender == MessageSender.patient && m.status != MessageStatus.read)
      .length;

  List<Conversation> get filteredConversations {
    final query = searchQuery.toLowerCase().trim();
    return conversations.where((conversation) {
      if (!filter.matches(conversation, unreadFor(conversation))) return false;
      if (query.isEmpty) return true;
      return conversation.patientName.toLowerCase().contains(query) ||
          conversation.lastMessagePreview.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + unreadFor(c));
}

final nurseMessagesProvider =
    StateNotifierProvider<NurseMessagesNotifier, NurseMessagesState>((ref) {
  final repository = ref.watch(conversationRepositoryProvider);
  return NurseMessagesNotifier(repository);
});

class NurseMessagesNotifier extends StateNotifier<NurseMessagesState> {
  NurseMessagesNotifier(this._repository)
      : super(NurseMessagesState(conversations: _repository.initialConversations)) {
    load();
  }

  final ConversationRepository _repository;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async {
    if (_disposed) return;
    // Only show the spinner when we have nothing to show yet. Seeded data is
    // already available synchronously, so the first read never blocks.
    final hadData = state.conversations.isNotEmpty;
    if (!hadData) state = state.copyWith(isLoading: true, clearError: true);
    try {
      final conversations = await _repository.getConversations();
      if (_disposed) return;
      state = state.copyWith(
          conversations: conversations, isLoading: false, clearError: true);
    } catch (_) {
      if (_disposed) return;
      if (!hadData) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Impossible de charger les conversations.',
        );
      }
    }
  }

  void search(String query) => state = state.copyWith(searchQuery: query);

  void setFilter(NurseConversationFilter filter) =>
      state = state.copyWith(filter: filter);

  Future<Conversation?> getConversation(String conversationId) async {
    return _repository.getConversationById(conversationId);
  }

  /// Marks patient messages as read when the nurse opens the conversation.
  Future<void> openConversation(String conversationId) async {
    await _repository.markRead(conversationId, viewer: MessageSender.careTeam);
    await load();
  }

  Future<bool> sendMessage(
    String conversationId,
    String text, {
    MessageType type = MessageType.text,
    String? actionLabel,
    String? actionRoute,
  }) async {
    if (text.trim().isEmpty) return false;
    try {
      await _repository.sendCareTeamMessage(
        conversationId,
        text: text,
        type: type,
        actionLabel: actionLabel,
        actionRoute: actionRoute,
      );
      await load();
      return true;
    } catch (_) {
      if (_disposed) return false;
      state = state.copyWith(errorMessage: 'Impossible d\'envoyer le message.');
      return false;
    }
  }

  Future<bool> addInternalNote(String conversationId, String text) async {
    if (text.trim().isEmpty) return false;
    try {
      await _repository.addInternalNote(
        conversationId,
        text: text,
        authorId: 'nurse_001',
      );
      await load();
      return true;
    } catch (_) {
      if (_disposed) return false;
      state = state.copyWith(errorMessage: 'Impossible d\'enregistrer la note.');
      return false;
    }
  }

  Future<bool> createCareRequest({
    required String conversationId,
    required String patientId,
    required CareRequestType type,
    required String reason,
    List<String> requestedData = const [],
    DateTime? dueDate,
  }) async {
    if (reason.trim().isEmpty) return false;
    try {
      await _repository.createCareRequest(
        conversationId: conversationId,
        patientId: patientId,
        type: type,
        reason: reason,
        requestedData: requestedData,
        dueDate: dueDate,
        nurseId: 'nurse_001',
      );
      await load();
      return true;
    } catch (_) {
      if (_disposed) return false;
      state = state.copyWith(errorMessage: 'Impossible de créer la demande.');
      return false;
    }
  }

  Future<void> completeTask(String taskId) async {
    await _repository.completeTask(taskId);
    await load();
  }

  Future<void> completeCareRequest(String requestId) async {
    await _repository.completeCareRequest(requestId);
    await load();
  }
}