import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Multi-step onboarding state.
class OnboardingState {
  final int currentPage;
  final bool acceptedTerms;
  final bool acceptedPrivacy;
  String? selectedRole;

  OnboardingState({
    this.currentPage = 0,
    this.acceptedTerms = false,
    this.acceptedPrivacy = false,
    this.selectedRole,
  });

  bool get canProceed => acceptedTerms && acceptedPrivacy;

  OnboardingState copyWith({
    int? currentPage,
    bool? acceptedTerms,
    bool? acceptedPrivacy,
    String? selectedRole,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      acceptedPrivacy: acceptedPrivacy ?? this.acceptedPrivacy,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }
}

/// Notifier driving the onboarding flow.
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(OnboardingState());

  void nextPage() => state = state.copyWith(currentPage: state.currentPage + 1);
  void previousPage() =>
      state = state.copyWith(currentPage: state.currentPage - 1);

  void selectRole(String role) => state = state.copyWith(selectedRole: role);

  void toggleTerms(bool value) => state = state.copyWith(acceptedTerms: value);

  void togglePrivacy(bool value) =>
      state = state.copyWith(acceptedPrivacy: value);

  void completeOnboarding() {
    // Preserve selections but mark flow complete for this session.
  }

  void reset() => state = OnboardingState();
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);
