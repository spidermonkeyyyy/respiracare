import '../models/treatment_adherence.dart';

abstract class NurseTreatmentRepository {
  Future<TreatmentAdherence> getAdherence(String patientId);
}
