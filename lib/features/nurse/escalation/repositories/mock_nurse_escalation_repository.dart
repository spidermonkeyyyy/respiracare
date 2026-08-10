import '../models/escalation_request.dart';
import 'nurse_escalation_repository.dart';

class MockNurseEscalationRepository implements NurseEscalationRepository {
  @override
  Future<EscalationRequest> submitEscalation(EscalationRequest request) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return request;
  }
}
