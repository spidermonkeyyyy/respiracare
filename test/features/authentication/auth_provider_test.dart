import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:respiracare/features/authentication/models/app_user.dart';
import 'package:respiracare/features/authentication/providers/auth_provider.dart';
import 'package:respiracare/features/authentication/repositories/mock_auth_repository.dart';

void main() {
  group('AuthNotifier & MockAuthRepository Tests', () {
    late ProviderContainer container;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Patient login succeeds with valid credentials', () async {
      final notifier = container.read(authProvider.notifier);

      final success = await notifier.login(
        email: 'patient@respiracare.org',
        password: 'password123',
      );

      expect(success, isTrue);
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.authenticated));
      expect(state.currentUser?.role, equals(UserRole.patient));
      expect(state.currentUser?.email, equals('patient@respiracare.org'));
    });

    test('Nurse login succeeds with valid credentials', () async {
      final notifier = container.read(authProvider.notifier);

      final success = await notifier.login(
        email: 'nurse@respiracare.org',
        password: 'password123',
      );

      expect(success, isTrue);
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.authenticated));
      expect(state.currentUser?.role, equals(UserRole.nurse));
    });

    test('Login fails with invalid password and sets non-alarming error', () async {
      final notifier = container.read(authProvider.notifier);

      final success = await notifier.login(
        email: 'patient@respiracare.org',
        password: 'wrongpassword',
      );

      expect(success, isFalse);
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.error));
      expect(state.errorMessage, contains('couldn\'t sign you in'));
    });

    test('Logout clears session and updates state to unauthenticated', () async {
      final notifier = container.read(authProvider.notifier);

      await notifier.login(
        email: 'patient@respiracare.org',
        password: 'password123',
      );
      expect(container.read(authProvider).status, equals(AuthStatus.authenticated));

      await notifier.logout();
      expect(container.read(authProvider).status, equals(AuthStatus.unauthenticated));
      expect(container.read(authProvider).currentUser, isNull);
    });
  });
}
