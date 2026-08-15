/// Supabase-backed implementation of the [AuthRepository] abstraction.
///
/// Maps Supabase Auth APIs to the domain [AppUser] and typed [AuthFailure].
/// No database queries, no RLS involvement — pure Auth layer per Step 5 scope.
/// Keeps the existing [AuthRepository] surface so mocks and tests are unaffected.
library respiracare.features.authentication.data.supabase_auth_repository;

import "package:supabase_flutter/supabase_flutter.dart";

import "../domain/auth_failure.dart";
import "../models/app_user.dart";
import "../repositories/auth_repository.dart";

/// Concrete auth repository backed by Supabase Auth.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({required GoTrueClient auth}) : _auth = auth;

  final GoTrueClient _auth;

  // ─── Session / Current User ────────────────────────────────

  @override
  Future<AppUser?> getCurrentUser() async {
    final session = _auth.currentSession;
    final user = session?.user;
    if (user == null) return null;
    return _mapToAppUser(user);
  }

  bool get isAuthenticated => _auth.currentSession != null;

  /// Current authenticated user, or null if no session.
  /// Public getter for the notifier to read on auth state events.
  AppUser? get currentUser {
    final session = _auth.currentSession;
    final user = session?.user;
    if (user == null) return null;
    return _mapToAppUser(user);
  }

  // ─── Auth State Stream ─────────────────────────────────────

  /// Raw Supabase auth state changes. The notifier subscribes to this.
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // ─── Sign In ───────────────────────────────────────────────

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthFailure.invalidCredentials();
      }

      return _mapToAppUser(user);
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ─── Sign Up ───────────────────────────────────────────────

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? dateOfBirth,
  }) async {
    try {
      // Supabase signUp does not accept role/name/phone/dob directly.
      // Those are stored in user_metadata and the database trigger handles profiles.
      // We pass name/role in metadata so the onAuthUserCreated trigger can use them.
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          "full_name": name.trim(),
          "role": role.name,
          if (phone != null) "phone": phone,
          if (dateOfBirth != null) "date_of_birth": dateOfBirth,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthFailure.unknown(
            "Sign-up succeeded but no user returned.");
      }

      return _mapToAppUser(user);
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ─── Password Reset ────────────────────────────────────────

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ─── Sign Out ──────────────────────────────────────────────

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ─── Onboarding (no-op for Supabase; app-local flag) ──────

  @override
  Future<bool> isOnboardingCompleted() async => false;

  @override
  Future<void> setOnboardingCompleted() async {}

  // ─── Mappers ───────────────────────────────────────────────

  /// Maps Supabase [User] to domain [AppUser].
  ///
  /// Role is derived from user_metadata (set by register) or defaults to patient.
  /// Name comes from user_metadata (full_name/name) or email local-part.
  AppUser _mapToAppUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final appMetadata = user.appMetadata;

    // Role precedence: metadata (from register) > app_metadata (from claims) > patient
    UserRole role;
    final metaRole = metadata['role'] as String?;
    final appRole = appMetadata['role'] as String?;
    final roleStr = metaRole ?? appRole;
    role = UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.patient,
    );

    final displayName = metadata["full_name"] as String? ??
        metadata["name"] as String? ??
        user.email?.split("@").first;

    return AppUser(
      id: user.id,
      email: user.email ?? "",
      name: displayName ?? "",
      role: role,
      phone: metadata["phone"] as String?,
      dateOfBirth: metadata["date_of_birth"] as String?,
    );
  }

  /// Maps Supabase [AuthException] to domain [AuthFailure].
  AuthFailure _mapAuthException(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains("invalid login credentials")) {
      return const AuthFailure.invalidCredentials();
    }
    if (message.contains("user already registered") ||
        message.contains("email already")) {
      return const AuthFailure.emailAlreadyRegistered();
    }
    if (message.contains("password")) {
      return const AuthFailure.weakPassword();
    }
    if (message.contains("email")) {
      return const AuthFailure.invalidEmailFormat();
    }
    if (message.contains("network") || message.contains("socket")) {
      return const AuthFailure.networkFailure();
    }
    if (message.contains("jwt") || message.contains("token")) {
      return const AuthFailure.sessionExpired();
    }

    return AuthFailure.unknown(e.message);
  }
}
