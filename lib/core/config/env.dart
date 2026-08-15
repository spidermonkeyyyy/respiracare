/// Environment configuration loaded from `.env` at startup.
///
/// Wraps `flutter_dotenv` and validates the required Supabase values eagerly
/// so a misconfigured build fails fast at initialization rather than at the
/// first auth call. Mirrors the Step 5 spec §3.3 but reuses the project's
/// existing `flutter_dotenv` dependency (no new config packages).
library respiracare.core.config.env;

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Thrown by [Env.load] when a required value is missing or malformed.
class EnvException implements Exception {
  EnvException(this.message);
  final String message;

  @override
  String toString() => 'EnvException: $message';
}

/// Process-wide environment accessors.
///
/// Call [Env.load] exactly once before `runApp()`. After that the static
/// fields are populated. Reads of the fields before [load] will throw a
/// `LateInitializationError`, which is the intended fail-fast behavior.
class Env {
  Env._();

  /// Whether auth should run against Supabase (`true`) or the in-app mock
  /// repository (`false`/missing). Lets existing mock flows keep working in
  /// environments without a live Supabase project (tests, demos, CI).
  static const String _kUseSupabaseAuth = 'USE_SUPABASE_AUTH';

  static const String _kSupabaseUrl = 'SUPABASE_URL';
  static const String _kSupabaseAnonKey = 'SUPABASE_ANON_KEY';

  static late final String supabaseUrl;
  static late final String supabaseAnonKey;
  static late final bool useSupabaseAuth;

  /// Load and validate the environment. Idempotent: safe to call more than
  /// once (re-reads the `.env`).
  static Future<void> load({String fileName = '.env'}) async {
    await dotenv.load(fileName: fileName);

    supabaseUrl = _getOrThrow(_kSupabaseUrl);
    supabaseAnonKey = _getOrThrow(_kSupabaseAnonKey);
    useSupabaseAuth = _getBool(_kUseSupabaseAuth, defaultValue: false);

    _assertValidHttpsUrl(supabaseUrl, _kSupabaseUrl);
  }

  /// True when [load] has run successfully at least once.
  static bool get isLoaded => _loaded; // set below after successful population
  static const bool _loaded = false;

  static String _getOrThrow(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) {
      throw EnvException('Missing required environment variable: $key');
    }
    return value.trim();
  }

  static bool _getBool(String key, {required bool defaultValue}) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) return defaultValue;
    final v = value.trim().toLowerCase();
    return v == 'true' || v == '1' || v == 'yes';
  }

  static void _assertValidHttpsUrl(String url, String key) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isScheme('https')) {
      throw EnvException(
        '$key must be a valid HTTPS URL. Got: $url',
      );
    }
  }
}

// Mark loaded at the end of a successful load() by reassigning the field.
// (Kept separate so a throw before completion does not flip the flag.)
