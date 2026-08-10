import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inhaler_video_review.dart';
import '../repositories/mock_nurse_inhaler_review_repository.dart';
import '../repositories/nurse_inhaler_review_repository.dart';

class NurseInhalerReviewState {
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final InhalerVideoReview? review;

  const NurseInhalerReviewState({
    this.isLoading = true,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.review,
  });

  NurseInhalerReviewState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    InhalerVideoReview? review,
  }) {
    return NurseInhalerReviewState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
      review: review,
    );
  }
}

final nurseInhalerReviewRepositoryProvider = Provider<NurseInhalerReviewRepository>((ref) {
  return MockNurseInhalerReviewRepository();
});

final nurseInhalerReviewProvider = StateNotifierProvider<NurseInhalerReviewNotifier, NurseInhalerReviewState>((ref) {
  final repository = ref.watch(nurseInhalerReviewRepositoryProvider);
  return NurseInhalerReviewNotifier(repository);
});

class NurseInhalerReviewNotifier extends StateNotifier<NurseInhalerReviewState> {
  final NurseInhalerReviewRepository _repository;

  NurseInhalerReviewNotifier(this._repository) : super(const NurseInhalerReviewState());

  Future<void> loadReview(String patientId) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final review = await _repository.getReview(patientId);
      state = state.copyWith(isLoading: false, review: review);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Impossible de charger la vidéo d’inhalation.');
    }
  }

  Future<void> saveReview(InhalerVideoReview review) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null);
    try {
      await _repository.saveReview(review);
      state = state.copyWith(isSubmitting: false, review: review, successMessage: 'Évaluation enregistrée.');
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Impossible d’enregistrer l’évaluation.');
    }
  }

  Future<void> requestNewVideo(String patientId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null);
    try {
      final review = await _repository.requestNewVideo(patientId);
      state = state.copyWith(isSubmitting: false, review: review, successMessage: 'Nouvelle vérification demandée.');
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Impossible de demander une nouvelle vidéo.');
    }
  }
}
