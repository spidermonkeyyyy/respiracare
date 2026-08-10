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

  Future<bool> isOnboardingCompleted();

  Future<void> setOnboardingCompleted();
}
