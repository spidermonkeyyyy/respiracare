/// Riverpod providers for Supabase-backed authentication.
///
/// Keeps the existing [authRepositoryProvider] defaulting to the mock
/// implementation so all existing tests and demo flows continue working
/// without changes. When the environment variable USE_SUPABASE_AUTH=true,
/// the live Supabase repository is selected and the onAuthStateChange stream
/// drives the [AuthNotifier].
library respiracare.features.authentication.providers.supabase_auth_providers;

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "../data/supabase_auth_repository.dart";
import "../repositories/auth_repository.dart";
import "../repositories/mock_auth_repository.dart";
import "../../../core/config/env.dart";

/// Flag read from Env to switch between mock and live Supabase auth.
/// Defaults to false so existing behavior is unchanged.
final useSupabaseAuthProvider = Provider<bool>((ref) {
  return Env.isLoaded && Env.useSupabaseAuth;
});

/// Supabase GoTrueClient — initialized once in main().
final goTrueClientProvider = Provider<GoTrueClient>((ref) {
  return Supabase.instance.client.auth;
});

/// Live Supabase-backed auth repository.
final supabaseAuthRepositoryProvider = Provider<AuthRepository>((ref) {
  final auth = ref.watch(goTrueClientProvider);
  return SupabaseAuthRepository(auth: auth);
});

/// Auth repository selector: mock (default) or Supabase.
///
/// Overrides the main [authRepositoryProvider] at app startup when
/// USE_SUPABASE_AUTH=true. Tests and demos without the env flag continue
/// to use the mock automatically.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final useSupabase = ref.watch(useSupabaseAuthProvider);
  if (useSupabase) {
    return ref.watch(supabaseAuthRepositoryProvider);
  }
  return ref.watch(mockAuthRepositoryProvider);
});

/// Mock auth repository provider (existing behavior preserved).
final mockAuthRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

/// Stream of Supabase auth state changes.
///
/// When using Supabase auth, the notifier subscribes to this to keep
/// [AuthState] in sync with session changes (signedIn, signedOut, tokenRefreshed, etc.).
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final repo = ref.watch(supabaseAuthRepositoryProvider);
  if (repo is SupabaseAuthRepository) {
    return repo.authStateChanges;
  }
  // Mock repo does not emit stream events; return a never-completing stream
  // so the notifier does not need to handle null.
  return const Stream<AuthState>.empty();
});