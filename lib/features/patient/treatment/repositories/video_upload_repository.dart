import '../models/inhaler_video.dart';

/// Abstract repository interface for inhaler technique video uploads.
/// Decouples the UI entirely from Supabase Storage or any real file system.
abstract class VideoUploadRepository {
  /// Uploads a video from [filePath] for [patientId].
  /// Returns the created [InhalerVideo] metadata record.
  Future<InhalerVideo> uploadVideo({
    required String filePath,
    required String patientId,
    required Duration recordingDuration,
  });

  /// Returns the most recent video submission for [patientId], or null.
  Future<InhalerVideo?> getLatestSubmission(String patientId);
}
