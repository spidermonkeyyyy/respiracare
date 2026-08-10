import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mock_auth_repository.dart';

enum AuthStatus {
  initializing,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final AppUser? currentUser;
  final String? errorMessage;
  final bool isOnboardingCompleted;

  const AuthState({
    required this.status,
    this.currentUser,
    this.errorMessage,
    this.isOnboardingCompleted = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? currentUser,
    String? errorMessage,
    bool? isOnboardingCompleted,
  }) {
    return AuthState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
    );
  }
}

// Auth Repository Provider (Decoupled abstraction)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

// Central Auth Notifier Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository)
      : super(const AuthState(status: AuthStatus.initializing)) {
    checkInitialState();
  }

  Future<void> checkInitialState() async {
    try {
      final onboardingDone = await _repository.isOnboardingCompleted();
      final user = await _repository.getCurrentUser();

      if (user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          currentUser: user,
          isOnboardingCompleted: onboardingDone,
        );
      } else {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          isOnboardingCompleted: onboardingDone,
        );
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);

    try {
      final user = await _repository.login(email: email, password: password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        currentUser: user,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: cleanMessage,
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? dateOfBirth,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);

    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        currentUser: user,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: cleanMessage,
      );
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    await _repository.setOnboardingCompleted();
    state = state.copyWith(isOnboardingCompleted: true);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState(
      status: AuthStatus.unauthenticated,
      isOnboardingCompleted: state.isOnboardingCompleted,
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}
