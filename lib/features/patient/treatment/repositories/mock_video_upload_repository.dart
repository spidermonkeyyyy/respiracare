import '../models/inhaler_video.dart';
import 'video_upload_repository.dart';

/// Mock implementation of [VideoUploadRepository].
/// Simulates a realistic upload delay and always succeeds unless
/// [filePath] contains 'error' (for testing error state).
class MockVideoUploadRepository implements VideoUploadRepository {
  InhalerVideo? _latestSubmission;

  @override
  Future<InhalerVideo> uploadVideo({
    required String filePath,
    required String patientId,
    required Duration recordingDuration,
  }) async {
    // Simulate upload time proportional to recording duration
    final simulatedUploadMs =
        (recordingDuration.inSeconds * 80).clamp(1000, 3000);
    await Future.delayed(Duration(milliseconds: simulatedUploadMs));

    if (filePath.contains('error')) {
      throw Exception('Simulated upload failure');
    }

    final video = InhalerVideo(
      id: 'video-${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      fileUri: filePath,
      uploadedAt: DateTime.now(),
      reviewStatus: VideoReviewStatus.pendingReview,
    );

    _latestSubmission = video;
    return video;
  }

  @override
  Future<InhalerVideo?> getLatestSubmission(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _latestSubmission;
  }
}
