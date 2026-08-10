import '../models/escalation_request.dart';

abstract class NurseEscalationRepository {
  Future<EscalationRequest> submitEscalation(EscalationRequest request);
}
