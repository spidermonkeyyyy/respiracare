import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  static const String _sessionKey = 'respiracare_active_user_session';
  static const String _onboardingKey = 'respiracare_onboarding_completed';

  // Preset Mock Users Database
  final Map<String, _MockUserEntry> _users = {
    'patient@respiracare.org': const _MockUserEntry(
      user: AppUser(
        id: 'patient-001',
        name: 'Ahmed Mansour',
        email: 'patient@respiracare.org',
        role: UserRole.patient,
        phone: '+212 6 12 34 56 78',
        dateOfBirth: '1965-04-12',
      ),
      password: 'password123',
    ),
    'nurse@respiracare.org': const _MockUserEntry(
      user: AppUser(
        id: 'nurse-001',
        name: 'Sarah Bennani',
        email: 'nurse@respiracare.org',
        role: UserRole.nurse,
        phone: '+212 6 98 76 54 32',
      ),
      password: 'password123',
    ),
  };

  @override
  Future<AppUser?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonStr = prefs.getString(_sessionKey);
      if (userJsonStr != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(userJsonStr);
        return AppUser.fromJson(jsonMap);
      }
    } catch (_) {
      // Fallback if shared_preferences fails in test environment
    }
    return null;
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = email.trim().toLowerCase();
    final entry = _users[normalizedEmail];

    if (entry == null || entry.password != password) {
      throw Exception('We couldn\'t sign you in. Please verify your email and password.');
    }

    await _saveUserSession(entry.user);
    return entry.user;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? dateOfBirth,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final normalizedEmail = email.trim().toLowerCase();
    if (_users.containsKey(normalizedEmail)) {
      throw Exception('An account with this email address already exists.');
    }

    final newUser = AppUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      role: role,
      phone: phone,
      dateOfBirth: dateOfBirth,
    );

    _users[normalizedEmail] = _MockUserEntry(user: newUser, password: password);
    await _saveUserSession(newUser);

    return newUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (_) {}
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (_) {}
  }

  Future<void> _saveUserSession(AppUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
    } catch (_) {}
  }
}

class _MockUserEntry {
  final AppUser user;
  final String password;

  const _MockUserEntry({required this.user, required this.password});
}
