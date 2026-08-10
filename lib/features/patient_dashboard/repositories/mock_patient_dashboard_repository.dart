import '../models/patient_dashboard_data.dart';
import 'patient_dashboard_repository.dart';

class MockPatientDashboardRepository implements PatientDashboardRepository {
  PatientDashboardData _currentData = const PatientDashboardData(
    spo2Value: 94,
    spo2Timestamp: 'Aujourd\'hui · 08:30',
    status: MonitoringStatus.normal,
    statusText: 'Suivi normal',
    questionnaireState: DailyQuestionnaireState.inProgress,
    questionnaireProgress: 0.70,
    questionnaireCompletedTime: null,
    nextMedicationTime: '20:00',
    isMedicationConfirmed: false,
    rehabExerciseName: 'Respiration contrôlée',
    rehabDurationMinutes: 10,
    rehabWeeklySessions: 3,
    rehabTargetSessions: 5,
    lastCareTeamReview: 'Aujourd\'hui à 10:30',
    nurseName: 'Sarah Bennani',
  );

  @override
  Future<PatientDashboardData> getDashboardData() async {
    // Simulate short network latency
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentData;
  }

  @override
  Future<void> completeDailyQuestionnaire() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentData = PatientDashboardData(
      spo2Value: _currentData.spo2Value,
      spo2Timestamp: _currentData.spo2Timestamp,
      status: _currentData.status,
      statusText: _currentData.statusText,
      questionnaireState: DailyQuestionnaireState.completed,
      questionnaireProgress: 1.0,
      questionnaireCompletedTime: 'Aujourd\'hui · 09:15',
      nextMedicationTime: _currentData.nextMedicationTime,
      isMedicationConfirmed: _currentData.isMedicationConfirmed,
      rehabExerciseName: _currentData.rehabExerciseName,
      rehabDurationMinutes: _currentData.rehabDurationMinutes,
      rehabWeeklySessions: _currentData.rehabWeeklySessions,
      rehabTargetSessions: _currentData.rehabTargetSessions,
      lastCareTeamReview: _currentData.lastCareTeamReview,
      nurseName: _currentData.nurseName,
    );
  }

  @override
  Future<void> confirmMedication() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentData = PatientDashboardData(
      spo2Value: _currentData.spo2Value,
      spo2Timestamp: _currentData.spo2Timestamp,
      status: _currentData.status,
      statusText: _currentData.statusText,
      questionnaireState: _currentData.questionnaireState,
      questionnaireProgress: _currentData.questionnaireProgress,
      questionnaireCompletedTime: _currentData.questionnaireCompletedTime,
      nextMedicationTime: _currentData.nextMedicationTime,
      isMedicationConfirmed: true,
      rehabExerciseName: _currentData.rehabExerciseName,
      rehabDurationMinutes: _currentData.rehabDurationMinutes,
      rehabWeeklySessions: _currentData.rehabWeeklySessions,
      rehabTargetSessions: _currentData.rehabTargetSessions,
      lastCareTeamReview: _currentData.lastCareTeamReview,
      nurseName: _currentData.nurseName,
    );
  }
}
