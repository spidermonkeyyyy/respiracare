import '../models/inhaler_video_review.dart';
import '../../../../mock/mock_patients.dart';
import 'nurse_inhaler_review_repository.dart';

class MockNurseInhalerReviewRepository implements NurseInhalerReviewRepository {
  @override
  Future<InhalerVideoReview?> getReview(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (patientId == 'p1') {
      return const InhalerVideoReview(
        id: 'video-1',
        patientId: 'p1',
        patientName: kPatientP1FullName,
        submittedAt: null,
        videoUrl: 'https://example.com/inhaler-demo.mp4',
        status: InhalerTechniqueStatus.needsImprovement,
        comment: 'Technique à revoir',
      );
    }
    return null;
  }

  @override
  Future<InhalerVideoReview> saveReview(InhalerVideoReview review) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return review;
  }

  @override
  Future<InhalerVideoReview> requestNewVideo(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return InhalerVideoReview(
      id: 'video-request-$patientId',
      patientId: patientId,
      patientName: 'Patient',
      submittedAt: DateTime.now(),
      videoUrl: 'pending',
      status: InhalerTechniqueStatus.newVideoRequested,
      comment: 'Nouvelle vérification demandée par l’équipe soignante.',
    );
  }
}
