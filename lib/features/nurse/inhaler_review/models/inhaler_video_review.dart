import 'package:equatable/equatable.dart';

enum InhalerTechniqueStatus { correct, needsImprovement, newVideoRequested }

class InhalerVideoReview extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final DateTime? submittedAt;
  final String videoUrl;
  final InhalerTechniqueStatus status;
  final String? comment;

  const InhalerVideoReview({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.submittedAt,
    required this.videoUrl,
    required this.status,
    this.comment,
  });

  @override
  List<Object?> get props => [id, patientId, patientName, submittedAt, videoUrl, status, comment];
}
