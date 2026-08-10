/// Review status of a patient-submitted inhaler technique video.
/// The nurse reviews asynchronously — the patient sees only these states.
enum VideoReviewStatus {
  /// Video uploaded, waiting for nurse to open it.
  pendingReview,

  /// Nurse has reviewed and validated the technique.
  reviewed,

  /// Nurse viewed the video and is requesting a new submission.
  retryRequested,
}

extension VideoReviewStatusLabel on VideoReviewStatus {
  String get patientLabel {
    switch (this) {
      case VideoReviewStatus.pendingReview:
        return 'En attente de vérification';
      case VideoReviewStatus.reviewed:
        return 'Vérifiée par votre infirmier';
      case VideoReviewStatus.retryRequested:
        return 'Nouvelle vérification demandée';
    }
  }
}

/// Metadata for a patient-submitted inhaler technique video.
/// The actual file is managed by the VideoUploadRepository.
class InhalerVideo {
  final String id;
  final String patientId;

  /// Local or remote URI of the video file.
  final String fileUri;

  final DateTime uploadedAt;
  final VideoReviewStatus reviewStatus;
  final DateTime? reviewedAt;

  /// Optional note from the reviewing nurse.
  final String? reviewerNote;

  const InhalerVideo({
    required this.id,
    required this.patientId,
    required this.fileUri,
    required this.uploadedAt,
    this.reviewStatus = VideoReviewStatus.pendingReview,
    this.reviewedAt,
    this.reviewerNote,
  });

  InhalerVideo copyWith({
    VideoReviewStatus? reviewStatus,
    DateTime? reviewedAt,
    String? reviewerNote,
  }) {
    return InhalerVideo(
      id: id,
      patientId: patientId,
      fileUri: fileUri,
      uploadedAt: uploadedAt,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerNote: reviewerNote ?? this.reviewerNote,
    );
  }

  @override
  String toString() =>
      'InhalerVideo(id: $id, status: $reviewStatus, uploadedAt: $uploadedAt)';
}
