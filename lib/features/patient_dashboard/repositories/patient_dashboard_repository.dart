import '../models/patient_dashboard_data.dart';

abstract class PatientDashboardRepository {
  Future<PatientDashboardData> getDashboardData();
  Future<void> completeDailyQuestionnaire();
  Future<void> confirmMedication();
}
