import '../models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> getCurrentUser();

  Future<AppUser> login({
    required String email,
    required String password,
  });

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? dateOfBirth,
  });

  Future<void> logout();

  /// Sends a password reset link to the given email address.
  Future<void> resetPassword({required String email});

  Future<bool> isOnboardingCompleted();

  Future<void> setOnboardingCompleted();
}
