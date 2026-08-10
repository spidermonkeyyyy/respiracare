import '../models/nurse_assessment.dart';

abstract class NurseAssessmentRepository {
  Future<NurseAssessment> saveAssessment(NurseAssessment assessment);
  Future<List<NurseAssessment>> getAssessments(String patientId);
}
