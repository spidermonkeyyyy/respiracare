import '../models/treatment_adherence.dart';
import 'nurse_treatment_repository.dart';

class MockNurseTreatmentRepository implements NurseTreatmentRepository {
  @override
  Future<TreatmentAdherence> getAdherence(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return TreatmentAdherence(
      patientId: patientId,
      confirmedCount: patientId == 'p1' ? 8 : 7,
      missedCount: patientId == 'p1' ? 2 : 1,
      weeklyCompliance: patientId == 'p1' ? 0.8 : 0.85,
      history: [
        const TreatmentDay(date: null, confirmed: true),
        const TreatmentDay(date: null, confirmed: false),
        const TreatmentDay(date: null, confirmed: true),
      ],
    );
  }
}
