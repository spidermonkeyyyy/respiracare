import '../models/care_request.dart';
import '../models/communication_task.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/message_type.dart';

/// Data access contract for patient–nurse communication.
///
/// Screens and providers depend only on this abstraction. The mock backs it
/// with in-memory data today, and later it will be backed by Supabase Realtime
/// (step 4.10U / 4.10V) without any UI change.
///
/// Security boundary: this repository is the place where "what the patient is
/// allowed to see" is enforced. Patient-facing methods never return
/// [InternalNote]s; the backend will enforce real authorization later.
abstract class ConversationRepository {
  /// Full conversations for the nurse (includes internal notes).
  Future<List<Conversation>> getConversations();

  /// Synchronous snapshot of the current conversations.
  ///
  /// Providers use this to seed their initial state so the UI (and unit
  /// tests) can render data immediately, without waiting for the async
  /// [getConversations] round-trip. A backend-backed implementation can
  /// return an empty list here and rely on [getConversations] for the real
  /// data.
  List<Conversation> get initialConversations;

  /// Conversations for one patient with internal notes stripped out.
  Future<List<Conversation>> getConversationsForPatient(String patientId);

  Future<Conversation?> getConversationById(String id);

  /// Patient sends a plain text message.
  Future<Conversation> sendPatientMessage(String conversationId, String text);

  /// Care team (nurse) sends a message, optionally with a patient action.
  Future<Conversation> sendCareTeamMessage(
    String conversationId, {
    required String text,
    MessageType type = MessageType.text,
    String? actionLabel,
    String? actionRoute,
  });

  /// Nurse-only note. Never returned to the patient.
  Future<InternalNote> addInternalNote(
    String conversationId, {
    required String text,
    required String authorId,
  });

  /// Marks messages not authored by [viewer] as read.
  Future<Conversation> markRead(String conversationId,
      {required MessageSender viewer});

  /// Raises a care request and creates the matching patient task + message.
  Future<Conversation> createCareRequest({
    required String conversationId,
    required String patientId,
    required CareRequestType type,
    required String reason,
    List<String> requestedData = const [],
    DateTime? dueDate,
    required String nurseId,
  });

  Future<CommunicationTask> completeTask(String taskId);

  Future<CareRequest> completeCareRequest(String requestId);

  /// Tasks for a patient across all conversations (their "À faire" list).
  Future<List<CommunicationTask>> getPatientTasks(String patientId);
}
