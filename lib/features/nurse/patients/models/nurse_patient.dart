import 'package:equatable/equatable.dart';
import '../../dashboard/models/monitoring_rule.dart';
import '../../monitoring/models/monitoring_submission.dart';
import '../../treatment/models/treatment_adherence.dart';
import '../../inhaler_review/models/inhaler_video_review.dart';

class NursePatient extends Equatable {
  final String id;
  final String fullName;
  final String condition;
  final String classification;
  final DateTime? lastSubmissionAt;
  final PriorityLevel priority;
  final bool hasNewSubmission;
  final MonitoringSubmission? latestSubmission;
  final List<MonitoringSubmission> submissions;
  final List<PatientTimelineEvent> timeline;
  final TreatmentAdherence? adherence;
  final InhalerVideoReview? inhalerVideo;
  final String? latestObservation;

  const NursePatient({
    required this.id,
    required this.fullName,
    required this.condition,
    required this.classification,
    this.lastSubmissionAt,
    required this.priority,
    required this.hasNewSubmission,
    this.latestSubmission,
    this.submissions = const [],
    this.timeline = const [],
    this.adherence,
    this.inhalerVideo,
    this.latestObservation,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        condition,
        classification,
        lastSubmissionAt,
        priority,
        hasNewSubmission,
        latestSubmission,
        submissions,
        timeline,
        adherence,
        inhalerVideo,
        latestObservation,
      ];
}

class PatientTimelineEvent extends Equatable {
  final DateTime createdAt;
  final String title;
  final String description;

  const PatientTimelineEvent({
    required this.createdAt,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [createdAt, title, description];
}
