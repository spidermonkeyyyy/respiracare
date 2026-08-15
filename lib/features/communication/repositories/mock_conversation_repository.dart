import '../models/care_request.dart';
import '../../../mock/mock_patients.dart';
import '../models/communication_task.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/message_status.dart';
import '../models/message_type.dart';
import 'conversation_repository.dart';

/// In-memory [ConversationRepository] used until the backend exists.
///
/// IMPORTANT — the content below is FICTITIOUS MOCK DATA for demonstration. It
/// is not real patient correspondence and must not be read as clinically
/// validated. The authoritative conversation store will live in Supabase.
class MockConversationRepository implements ConversationRepository {
  MockConversationRepository() {
    _conversations = _seed();
  }

  late List<Conversation> _conversations;

  static const Duration _latency = Duration.zero;

  @override
  List<Conversation> get initialConversations =>
      List<Conversation>.unmodifiable(_conversations);

  String _newId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

  List<Conversation> _seed() {
    final now = DateTime.now();

    return [
      Conversation(
        id: 'conv_p1',
        patientId: 'p1',
        patientName: kPatientP1ShortName,
        patientSummary: 'BPCO · GOLD III',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(minutes: 12)),
        messages: [
          Message(
            id: 'm_p1_1',
            conversationId: 'conv_p1',
            sender: MessageSender.careTeam,
            type: MessageType.careUpdate,
            text: 'Votre suivi a été examiné. Vos dernières données sont '
                'stables par rapport à votre référence.',
            createdAt: now.subtract(const Duration(hours: 3)),
            status: MessageStatus.read,
            actionLabel: 'Voir mon suivi',
            actionRoute: '/patient/monitoring',
          ),
          Message(
            id: 'm_p1_2',
            conversationId: 'conv_p1',
            sender: MessageSender.patient,
            type: MessageType.text,
            text: 'Merci pour votre retour.',
            createdAt: now.subtract(const Duration(hours: 2, minutes: 50)),
            status: MessageStatus.read,
          ),
          Message(
            id: 'm_p1_3',
            conversationId: 'conv_p1',
            sender: MessageSender.careTeam,
            type: MessageType.followUp,
            text: 'Nous vous recontacterons si une nouvelle vérification est '
                'nécessaire. Continuez votre suivi habituel.',
            createdAt: now.subtract(const Duration(minutes: 12)),
            status: MessageStatus.sent,
            actionLabel: 'Ouvrir',
            actionRoute: '/patient/monitoring',
          ),
        ],
        internalNotes: [
          InternalNote(
            id: 'n_p1_1',
            conversationId: 'conv_p1',
            patientId: 'p1',
            text: 'Patient contacté. Suivi planifié cette semaine.',
            createdAt: now.subtract(const Duration(hours: 1)),
            authorId: 'nurse_001',
          ),
        ],
        careRequests: [
          CareRequest(
            id: 'cr_p1_1',
            conversationId: 'conv_p1',
            patientId: 'p1',
            type: CareRequestType.newMonitoring,
            reason: 'Contrôle de la saturation après l\'épisode de la semaine '
                'dernière.',
            requestedData: const ['spo2', 'dyspnea'],
            status: CareRequestStatus.pending,
            createdAt: now.subtract(const Duration(hours: 5)),
            dueDate: now.add(const Duration(days: 1)),
            createdByNurseId: 'nurse_001',
          ),
        ],
        tasks: [
          CommunicationTask(
            id: 't_p1_1',
            patientId: 'p1',
            conversationId: 'conv_p1',
            type: TaskType.monitoring,
            title: 'Nouveau suivi respiratoire',
            description: 'Demandé par votre équipe soignante.',
            actionRoute: '/patient/monitoring',
            status: TaskStatus.open,
            createdAt: now.subtract(const Duration(hours: 5)),
            dueDate: now.add(const Duration(days: 1)),
            linkedCareRequestId: 'cr_p1_1',
          ),
        ],
      ),
      Conversation(
        id: 'conv_p2',
        patientId: 'p2',
        patientName: 'Mariem K.',
        patientSummary: 'BPCO · GOLD II',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        messages: [
          Message(
            id: 'm_p2_1',
            conversationId: 'conv_p2',
            sender: MessageSender.patient,
            type: MessageType.text,
            text: 'J\'ai une question concernant mon traitement.',
            createdAt: now.subtract(const Duration(hours: 1)),
            status: MessageStatus.sent,
          ),
        ],
        internalNotes: const [],
        careRequests: [
          CareRequest(
            id: 'cr_p2_1',
            conversationId: 'conv_p2',
            patientId: 'p2',
            type: CareRequestType.inhalerVideo,
            reason: 'Vérification de la technique d\'inhalation.',
            requestedData: const [],
            status: CareRequestStatus.pending,
            createdAt: now.subtract(const Duration(hours: 26)),
            dueDate: now.add(const Duration(days: 2)),
            createdByNurseId: 'nurse_001',
          ),
        ],
        tasks: [
          CommunicationTask(
            id: 't_p2_1',
            patientId: 'p2',
            conversationId: 'conv_p2',
            type: TaskType.inhalerVideo,
            title: 'Nouvelle vidéo d\'inhalation',
            description: 'Demandée hier par votre équipe.',
            actionRoute: '/patient/education/inhaler',
            status: TaskStatus.open,
            createdAt: now.subtract(const Duration(hours: 26)),
            dueDate: now.add(const Duration(days: 2)),
            linkedCareRequestId: 'cr_p2_1',
          ),
        ],
      ),
      Conversation(
        id: 'conv_p3',
        patientId: 'p3',
        patientName: 'Sami R.',
        patientSummary: 'IRC · Suivi stable',
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(hours: 26)),
        messages: [
          Message(
            id: 'm_p3_1',
            conversationId: 'conv_p3',
            sender: MessageSender.careTeam,
            type: MessageType.systemNotification,
            text: 'Rappel : votre prochain suivi est attendu demain.',
            createdAt: now.subtract(const Duration(hours: 26)),
            status: MessageStatus.read,
          ),
          Message(
            id: 'm_p3_2',
            conversationId: 'conv_p3',
            sender: MessageSender.patient,
            type: MessageType.text,
            text: 'Merci, je ferai mon suivi demain matin.',
            createdAt: now.subtract(const Duration(hours: 25)),
            status: MessageStatus.read,
          ),
        ],
        internalNotes: const [],
        careRequests: const [],
        tasks: const [],
      ),
    ];
  }

  int _indexOf(String conversationId) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) throw StateError('Conversation introuvable: $conversationId');
    return index;
  }

  @override
  Future<List<Conversation>> getConversations() async {
    await Future<void>.delayed(_latency);
    return List<Conversation>.unmodifiable(_conversations);
  }

  @override
  Future<List<Conversation>> getConversationsForPatient(String patientId) async {
    await Future<void>.delayed(_latency);
    return _conversations
        .where((c) => c.patientId == patientId)
        .map((c) => c.copyWith(internalNotes: const []))
        .toList();
  }

  @override
  Future<Conversation?> getConversationById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    for (final c in _conversations) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<Conversation> sendPatientMessage(String conversationId, String text) async {
    await Future<void>.delayed(_latency);
    final index = _indexOf(conversationId);
    final conversation = _conversations[index];
    final message = Message(
      id: _newId('m'),
      conversationId: conversationId,
      sender: MessageSender.patient,
      type: MessageType.text,
      text: text.trim(),
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
    );
    final updated = conversation.copyWith(
      messages: [...conversation.messages, message],
      updatedAt: DateTime.now(),
    );
    _conversations[index] = updated;
    return updated;
  }

  @override
  Future<Conversation> sendCareTeamMessage(
    String conversationId, {
    required String text,
    MessageType type = MessageType.text,
    String? actionLabel,
    String? actionRoute,
  }) async {
    await Future<void>.delayed(_latency);
    final index = _indexOf(conversationId);
    final conversation = _conversations[index];
    final message = Message(
      id: _newId('m'),
      conversationId: conversationId,
      sender: MessageSender.careTeam,
      type: type,
      text: text.trim(),
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
      actionLabel: actionLabel,
      actionRoute: actionRoute,
    );
    final updated = conversation.copyWith(
      messages: [...conversation.messages, message],
      updatedAt: DateTime.now(),
    );
    _conversations[index] = updated;
    return updated;
  }

  @override
  Future<InternalNote> addInternalNote(
    String conversationId, {
    required String text,
    required String authorId,
  }) async {
    await Future<void>.delayed(_latency);
    final index = _indexOf(conversationId);
    final conversation = _conversations[index];
    final note = InternalNote(
      id: _newId('n'),
      conversationId: conversationId,
      patientId: conversation.patientId,
      text: text.trim(),
      createdAt: DateTime.now(),
      authorId: authorId,
    );
    final updated = conversation.copyWith(
      internalNotes: [...conversation.internalNotes, note],
    );
    _conversations[index] = updated;
    return note;
  }

  @override
  Future<Conversation> markRead(
    String conversationId, {
    required MessageSender viewer,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final index = _indexOf(conversationId);
    final conversation = _conversations[index];
    final updatedMessages = conversation.messages.map((message) {
      if (message.sender != viewer && message.status != MessageStatus.read) {
        return message.copyWith(status: MessageStatus.read);
      }
      return message;
    }).toList();
    final updated = conversation.copyWith(messages: updatedMessages);
    _conversations[index] = updated;
    return updated;
  }

  @override
  Future<Conversation> createCareRequest({
    required String conversationId,
    required String patientId,
    required CareRequestType type,
    required String reason,
    List<String> requestedData = const [],
    DateTime? dueDate,
    required String nurseId,
  }) async {
    await Future<void>.delayed(_latency);
    final index = _indexOf(conversationId);
    final conversation = _conversations[index];
    final requestId = _newId('cr');

    final request = CareRequest(
      id: requestId,
      conversationId: conversationId,
      patientId: patientId,
      type: type,
      reason: reason.trim(),
      requestedData: requestedData,
      status: CareRequestStatus.pending,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      createdByNurseId: nurseId,
    );

    final task = CommunicationTask(
      id: _newId('t'),
      patientId: patientId,
      conversationId: conversationId,
      type: type == CareRequestType.inhalerVideo
          ? TaskType.inhalerVideo
          : type == CareRequestType.other
              ? TaskType.followUp
              : TaskType.monitoring,
      title: type.label,
      description: reason.trim(),
      actionRoute: type.patientRoute,
      status: TaskStatus.open,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      linkedCareRequestId: requestId,
    );

    final announcement = Message(
      id: _newId('m'),
      conversationId: conversationId,
      sender: MessageSender.careTeam,
      type: MessageType.followUp,
      text: type == CareRequestType.inhalerVideo
          ? 'Votre équipe soignante vous demande une nouvelle vidéo de votre '
              'technique d\'inhalation.'
          : 'Votre équipe soignante vous demande de compléter votre suivi '
              'respiratoire.',
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
      actionLabel: type == CareRequestType.inhalerVideo ? 'Ouvrir' : 'Commencer',
      actionRoute: type.patientRoute,
      linkedCareRequestId: requestId,
      linkedTaskId: task.id,
    );

    final updated = conversation.copyWith(
      messages: [...conversation.messages, announcement],
      careRequests: [...conversation.careRequests, request],
      tasks: [...conversation.tasks, task],
      updatedAt: DateTime.now(),
    );
    _conversations[index] = updated;
    return updated;
  }

  @override
  Future<CommunicationTask> completeTask(String taskId) async {
    await Future<void>.delayed(_latency);
    for (var i = 0; i < _conversations.length; i++) {
      final conversation = _conversations[i];
      final taskIndex =
          conversation.tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final task = conversation.tasks[taskIndex];
        final updatedTask = task.copyWith(status: TaskStatus.done);
        final updatedTasks = [...conversation.tasks]
          ..[taskIndex] = updatedTask;
        Conversation updatedConversation = conversation.copyWith(tasks: updatedTasks);

        if (updatedTask.linkedCareRequestId != null) {
          final requestIndex = updatedConversation.careRequests
              .indexWhere((r) => r.id == updatedTask.linkedCareRequestId);
          if (requestIndex != -1) {
            final updatedRequest = updatedConversation
                .careRequests[requestIndex]
                .copyWith(status: CareRequestStatus.completed);
            final updatedRequests = [...updatedConversation.careRequests]
              ..[requestIndex] = updatedRequest;
            updatedConversation = updatedConversation.copyWith(
              careRequests: updatedRequests,
            );
          }
        }

        _conversations[i] = updatedConversation;
        return updatedTask;
      }
    }
    throw StateError('Tâche introuvable: $taskId');
  }

  @override
  Future<CareRequest> completeCareRequest(String requestId) async {
    await Future<void>.delayed(_latency);
    for (var i = 0; i < _conversations.length; i++) {
      final conversation = _conversations[i];
      final requestIndex =
          conversation.careRequests.indexWhere((r) => r.id == requestId);
      if (requestIndex != -1) {
        final updatedRequest = conversation.careRequests[requestIndex]
            .copyWith(status: CareRequestStatus.completed);
        final updatedRequests = [...conversation.careRequests]
          ..[requestIndex] = updatedRequest;
        _conversations[i] = conversation.copyWith(careRequests: updatedRequests);
        return updatedRequest;
      }
    }
    throw StateError('Demande introuvable: $requestId');
  }

  @override
  Future<List<CommunicationTask>> getPatientTasks(String patientId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final tasks = <CommunicationTask>[];
    for (final conversation in _conversations) {
      for (final task in conversation.tasks) {
        if (task.patientId == patientId) tasks.add(task);
      }
    }
    tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return tasks;
  }
}
