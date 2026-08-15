import '../models/nurse_patient.dart';

abstract class NursePatientRepository {
  Future<List<NursePatient>> getPatients();

  /// Returns the patients assigned to the nurse identified by [nurseId].
  ///
  /// In a real backend this is scoped by the authenticated nurse's identity.
  /// The mock implementation returns all seeded patients regardless of
  /// [nurseId], since every patient is considered assigned to the demo nurse.
  Future<List<NursePatient>> getAssignedPatients(String nurseId);

  Future<List<NursePatient>> searchPatients(String query);
  Future<NursePatient?> getPatient(String patientId);
}
