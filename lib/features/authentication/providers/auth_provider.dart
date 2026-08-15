import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "../models/app_user.dart";
import "../repositories/auth_repository.dart";
import "../data/supabase_auth_repository.dart";
import "../domain/auth_failure.dart";
import "supabase_auth_providers.dart";
import "../../../core/config/env.dart";

// Re-export the authRepositoryProvider so existing imports from auth_provider.dart still work.
export "supabase_auth_providers.dart" show authRepositoryProvider;

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

// Central Auth Notifier Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository: repository, ref: ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  StreamSubscription? _authSubscription;

  AuthNotifier({
    required AuthRepository repository,
    required Ref ref,
  })  : _repository = repository,
        super(const AuthState(status: AuthStatus.initializing)) {
    _init();
  }

  /// Initialize: restore session + listen to auth changes (if using Supabase).
  void _init() {
    // Check if using Supabase auth to set up state listener.
    final useSupabase = Env.isLoaded && Env.useSupabaseAuth;

    if (useSupabase && _repository is SupabaseAuthRepository) {
      final supabaseRepo = _repository;
      _authSubscription = supabaseRepo.authStateChanges.listen((event) {
        // Supabase AuthState event has .event (AuthChangeEvent) and .session
        switch (event.event) {
          case AuthChangeEvent.signedIn:
          case AuthChangeEvent.tokenRefreshed:
          case AuthChangeEvent.userUpdated:
            final user = supabaseRepo.currentUser;
            if (user != null) {
              state = AuthState(
                status: AuthStatus.authenticated,
                currentUser: user,
              );
            }
            break;
          case AuthChangeEvent.signedOut:
          // ignore: deprecated_member_use
          case AuthChangeEvent.userDeleted:
            state = const AuthState(
              status: AuthStatus.unauthenticated,
            );
            break;
          case AuthChangeEvent.passwordRecovery:
          case AuthChangeEvent.initialSession:
          case AuthChangeEvent.mfaChallengeVerified:
            // No action needed for these events in this implementation
            break;
        }
      }, onError: (error) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: error.toString(),
        );
      });
    }

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
    } on AuthFailure catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.userMessage,
      );
      return false;
    } catch (e) {
      // Mock repository throws generic Exception; preserve its message.
      final cleanMessage = e.toString().replaceAll("Exception: ", "");
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
    } on AuthFailure catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.userMessage,
      );
      return false;
    } catch (e) {
      final cleanMessage = e.toString().replaceAll("Exception: ", "");
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

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}