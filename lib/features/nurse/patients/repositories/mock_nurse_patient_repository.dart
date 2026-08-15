import 'package:respiracare/features/nurse/dashboard/models/monitoring_rule.dart';
import '../../../../mock/mock_patients.dart';
import 'package:respiracare/features/nurse/monitoring/models/monitoring_submission.dart';
import 'package:respiracare/features/nurse/treatment/models/treatment_adherence.dart';
import '../models/nurse_patient.dart';
import 'nurse_patient_repository.dart';

class MockNursePatientRepository implements NursePatientRepository {
  final List<NursePatient> _patients = [
    NursePatient(
      id: 'p1',
      fullName: kPatientP1FullName,
      condition: 'BPCO',
      classification: 'GOLD III',
      lastSubmissionAt: DateTime.now().subtract(const Duration(minutes: 12)),
      priority: PriorityLevel.high,
      hasNewSubmission: true,
      latestSubmission: MonitoringSubmission(
        id: 'ms-1',
        patientId: 'p1',
        submittedAt: DateTime.now().subtract(const Duration(minutes: 12)),
        spo2: 89,
        dyspneaScore: 3,
        coughStatus: 'Plus importante',
        sputumStatus: 'Modification signalée',
        overallStatus: 'À surveiller',
        notes: 'Signalement de dyspnée plus marquée aujourd’hui',
      ),
      submissions: [
        MonitoringSubmission(
          id: 'ms-1',
          patientId: 'p1',
          submittedAt: DateTime.now().subtract(const Duration(minutes: 12)),
          spo2: 89,
          dyspneaScore: 3,
          coughStatus: 'Plus importante',
          sputumStatus: 'Modification signalée',
          overallStatus: 'À surveiller',
          notes: 'Signalement de dyspnée plus marquée aujourd’hui',
        ),
        MonitoringSubmission(
          id: 'ms-0',
          patientId: 'p1',
          submittedAt: DateTime.now().subtract(const Duration(days: 1)),
          spo2: 93,
          dyspneaScore: 2,
          coughStatus: 'Stable',
          sputumStatus: 'Stable',
          overallStatus: 'Normal',
          notes: 'Suivi stable',
        ),
      ],
      timeline: [
        PatientTimelineEvent(
          createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
          title: 'Suivi respiratoire reçu',
          description: 'Le patient a soumis un nouveau suivi ce matin.',
        ),
        PatientTimelineEvent(
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          title: 'Revue infirmière',
          description: 'Une revue a été ouverte pour les dernières données.',
        ),
      ],
      adherence: const TreatmentAdherence(
        patientId: 'p1',
        confirmedCount: 8,
        missedCount: 2,
        weeklyCompliance: 0.8,
        history: [
          TreatmentDay(date: null, confirmed: true),
        ],
      ),
      latestObservation: 'SpO₂ à 89 %, dyspnée augmentée',
    ),
    NursePatient(
      id: 'p2',
      fullName: 'Mariem K.',
      condition: 'BPCO',
      classification: 'GOLD II',
      lastSubmissionAt: DateTime.now().subtract(const Duration(hours: 2)),
      priority: PriorityLevel.reviewRequired,
      hasNewSubmission: true,
      latestSubmission: MonitoringSubmission(
        id: 'ms-2',
        patientId: 'p2',
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        spo2: 93,
        dyspneaScore: 2,
        coughStatus: 'Stable',
        sputumStatus: 'Stable',
        overallStatus: 'Normal',
        notes: 'Nouvelles données respiratoires',
      ),
      submissions: [
        MonitoringSubmission(
          id: 'ms-2',
          patientId: 'p2',
          submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
          spo2: 93,
          dyspneaScore: 2,
          coughStatus: 'Stable',
          sputumStatus: 'Stable',
          overallStatus: 'Normal',
          notes: 'Nouvelles données respiratoires',
        ),
      ],
      timeline: [
        PatientTimelineEvent(
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          title: 'Données reçues',
          description: 'Le patient a envoyé un nouveau suivi.',
        ),
      ],
      adherence: const TreatmentAdherence(
        patientId: 'p2',
        confirmedCount: 6,
        missedCount: 1,
        weeklyCompliance: 0.85,
        history: [
          TreatmentDay(date: null, confirmed: true),
        ],
      ),
      latestObservation: 'Nouvelles données respiratoires',
    ),
    NursePatient(
      id: 'p3',
      fullName: 'Sami R.',
      condition: 'IRC',
      classification: 'Suivi stable',
      lastSubmissionAt: DateTime.now().subtract(const Duration(days: 1)),
      priority: PriorityLevel.informational,
      hasNewSubmission: false,
      latestSubmission: MonitoringSubmission(
        id: 'ms-3',
        patientId: 'p3',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        spo2: 95,
        dyspneaScore: 1,
        coughStatus: 'Stable',
        sputumStatus: 'Stable',
        overallStatus: 'Normal',
        notes: 'Suivi quotidien bien complété',
      ),
      submissions: [
        MonitoringSubmission(
          id: 'ms-3',
          patientId: 'p3',
          submittedAt: DateTime.now().subtract(const Duration(days: 1)),
          spo2: 95,
          dyspneaScore: 1,
          coughStatus: 'Stable',
          sputumStatus: 'Stable',
          overallStatus: 'Normal',
          notes: 'Suivi quotidien bien complété',
        ),
      ],
      timeline: [
        PatientTimelineEvent(
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          title: 'Traitement confirmé',
          description: 'Le traitement a été confirmé hier.',
        ),
      ],
      adherence: const TreatmentAdherence(
        patientId: 'p3',
        confirmedCount: 7,
        missedCount: 0,
        weeklyCompliance: 1.0,
        history: [
          TreatmentDay(date: null, confirmed: true),
        ],
      ),
      latestObservation: 'Suivi stable',
    ),
  ];

  @override
  Future<List<NursePatient>> getPatients() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.from(_patients);
  }

    @override
  Future<List<NursePatient>> searchPatients(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final normalizedQuery = query.toLowerCase();
    return _patients.where((patient) {
      final content = '${patient.fullName} ${patient.condition} ${patient.classification}'.toLowerCase();
      return content.contains(normalizedQuery);
    }).toList();
  }

  @override
  Future<NursePatient?> getPatient(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _patients.firstWhere((patient) => patient.id == patientId, orElse: () => const NursePatient(
      id: '',
      fullName: 'Patient introuvable',
      condition: 'N/A',
      classification: 'N/A',
      priority: PriorityLevel.informational,
      hasNewSubmission: false,
      adherence: null,
    ));
  }

  @override
  Future<List<NursePatient>> getAssignedPatients(String nurseId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    // In the mock, every patient is assigned to the demo nurse. A real
    // backend would filter by the nurse's assignment roster.
    return List.from(_patients);
  }
}
