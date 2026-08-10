import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inhaler_video.dart';
import '../repositories/mock_video_upload_repository.dart';
import '../repositories/video_upload_repository.dart';

// ─── Repository Provider ────────────────────────────────────────────────────

final videoUploadRepositoryProvider = Provider<VideoUploadRepository>((ref) {
  return MockVideoUploadRepository();
});

// ─── State ──────────────────────────────────────────────────────────────────

enum SubmissionStatus {
  idle,
  requestingPermission,
  permissionDenied,
  recording,
  previewing,
  uploading,
  success,
  error,
}

class VideoSubmissionState {
  final SubmissionStatus status;
  final Duration recordingDuration;
  final String? recordingPath; // Mock path used in submission
  final InhalerVideo? latestSubmission;
  final String? errorMessage;

  const VideoSubmissionState({
    this.status = SubmissionStatus.idle,
    this.recordingDuration = Duration.zero,
    this.recordingPath,
    this.latestSubmission,
    this.errorMessage,
  });

  bool get isRecording => status == SubmissionStatus.recording;
  bool get isPreviewing => status == SubmissionStatus.previewing;
  bool get isUploading => status == SubmissionStatus.uploading;
  bool get hasSubmitted => status == SubmissionStatus.success;

  VideoSubmissionState copyWith({
    SubmissionStatus? status,
    Duration? recordingDuration,
    String? recordingPath,
    InhalerVideo? latestSubmission,
    String? errorMessage,
    bool clearError = false,
    bool clearPath = false,
  }) {
    return VideoSubmissionState(
      status: status ?? this.status,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      recordingPath: clearPath ? null : (recordingPath ?? this.recordingPath),
      latestSubmission: latestSubmission ?? this.latestSubmission,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ─── Notifier ───────────────────────────────────────────────────────────────

class VideoSubmissionNotifier extends StateNotifier<VideoSubmissionState> {
  final VideoUploadRepository _repository;
  final String patientId;

  VideoSubmissionNotifier(this._repository, {required this.patientId})
      : super(const VideoSubmissionState()) {
    _loadLatestSubmission();
  }

  Future<void> _loadLatestSubmission() async {
    try {
      final latest = await _repository.getLatestSubmission(patientId);
      state = state.copyWith(latestSubmission: latest);
    } catch (_) {}
  }

  void requestPermission() {
    state = state.copyWith(status: SubmissionStatus.requestingPermission);
  }

  /// Called after the OS permission check result
  void onPermissionResult({required bool granted}) {
    if (granted) {
      state = state.copyWith(status: SubmissionStatus.recording, recordingDuration: Duration.zero);
    } else {
      state = state.copyWith(status: SubmissionStatus.permissionDenied);
    }
  }

  void updateRecordingDuration(Duration elapsed) {
    state = state.copyWith(recordingDuration: elapsed);
  }

  /// Simulates stopping recording and entering preview mode
  void stopRecording() {
    // In mock mode, the "recorded file" is a timestamped mock path
    final mockPath = 'mock://recording-${DateTime.now().millisecondsSinceEpoch}.mp4';
    state = state.copyWith(
      status: SubmissionStatus.previewing,
      recordingPath: mockPath,
    );
  }

  void retake() {
    state = state.copyWith(
      status: SubmissionStatus.recording,
      recordingDuration: Duration.zero,
      clearPath: true,
      clearError: true,
    );
  }

  Future<void> submitVideo() async {
    if (state.recordingPath == null) return;

    state = state.copyWith(status: SubmissionStatus.uploading, clearError: true);
    try {
      final video = await _repository.uploadVideo(
        filePath: state.recordingPath!,
        patientId: patientId,
        recordingDuration: state.recordingDuration,
      );
      state = state.copyWith(
        status: SubmissionStatus.success,
        latestSubmission: video,
      );
    } catch (e) {
      state = state.copyWith(
        status: SubmissionStatus.error,
        errorMessage: 'La vidéo n\'a pas pu être envoyée. Veuillez réessayer.',
      );
    }
  }

  void reset() {
    state = const VideoSubmissionState();
    _loadLatestSubmission();
  }
}

// ─── Provider ───────────────────────────────────────────────────────────────

final videoSubmissionProvider = StateNotifierProvider.family<
    VideoSubmissionNotifier, VideoSubmissionState, String>(
  (ref, patientId) {
    final repository = ref.watch(videoUploadRepositoryProvider);
    return VideoSubmissionNotifier(repository, patientId: patientId);
  },
);
