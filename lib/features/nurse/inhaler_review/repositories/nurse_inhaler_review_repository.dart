import '../models/inhaler_video_review.dart';

abstract class NurseInhalerReviewRepository {
  Future<InhalerVideoReview?> getReview(String patientId);
  Future<InhalerVideoReview> saveReview(InhalerVideoReview review);
  Future<InhalerVideoReview> requestNewVideo(String patientId);
}
