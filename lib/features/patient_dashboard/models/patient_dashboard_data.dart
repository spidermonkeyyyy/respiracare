import 'package:equatable/equatable.dart';

enum MonitoringStatus {
  normal,
  attentionNeeded,
  incomplete,
}

enum DailyQuestionnaireState {
  notStarted,
  inProgress,
  completed,
}

class PatientDashboardData extends Equatable {
  final int spo2Value; // e.g. 94
  final String spo2Timestamp; // e.g. "Aujourd'hui · 08:30"
  final MonitoringStatus status;
  final String statusText; // Neutral wording, e.g. "Suivi normal"
  final DailyQuestionnaireState questionnaireState;
  final double questionnaireProgress; // e.g. 0.70 (70%)
  final String? questionnaireCompletedTime;
  final String nextMedicationTime; // e.g. "20:00"
  final bool isMedicationConfirmed;
  final String rehabExerciseName; // e.g. "Respiration contrôlée"
  final int rehabDurationMinutes; // e.g. 10
  final int rehabWeeklySessions; // e.g. 3
  final int rehabTargetSessions; // e.g. 5
  final String lastCareTeamReview; // e.g. "Aujourd'hui à 10:30"
  final String nurseName; // e.g. "Sarah Bennani"

  const PatientDashboardData({
    required this.spo2Value,
    required this.spo2Timestamp,
    required this.status,
    required this.statusText,
    required this.questionnaireState,
    required this.questionnaireProgress,
    this.questionnaireCompletedTime,
    required this.nextMedicationTime,
    required this.isMedicationConfirmed,
    required this.rehabExerciseName,
    required this.rehabDurationMinutes,
    required this.rehabWeeklySessions,
    required this.rehabTargetSessions,
    required this.lastCareTeamReview,
    required this.nurseName,
  });

  @override
  List<Object?> get props => [
        spo2Value,
        spo2Timestamp,
        status,
        statusText,
        questionnaireState,
        questionnaireProgress,
        questionnaireCompletedTime,
        nextMedicationTime,
        isMedicationConfirmed,
        rehabExerciseName,
        rehabDurationMinutes,
        rehabWeeklySessions,
        rehabTargetSessions,
        lastCareTeamReview,
        nurseName,
      ];
}
