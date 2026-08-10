import '../models/nurse_patient.dart';

abstract class NursePatientRepository {
  Future<List<NursePatient>> getPatients();
  Future<List<NursePatient>> searchPatients(String query);
  Future<NursePatient?> getPatient(String patientId);
}
