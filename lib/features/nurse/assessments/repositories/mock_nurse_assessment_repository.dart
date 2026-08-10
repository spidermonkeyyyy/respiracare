import '../models/nurse_assessment.dart';
import 'nurse_assessment_repository.dart';

class MockNurseAssessmentRepository implements NurseAssessmentRepository {
  final List<NurseAssessment> _assessments = [];

  @override
  Future<NurseAssessment> saveAssessment(NurseAssessment assessment) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _assessments.add(assessment);
    return assessment;
  }

  @override
  Future<List<NurseAssessment>> getAssessments(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _assessments.where((entry) => entry.patientId == patientId).toList();
  }
}
