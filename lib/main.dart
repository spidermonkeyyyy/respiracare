import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'app/app.dart';

/// RespiraCare Main Entry Point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load and validate environment (throws on missing/malformed config)
  await Env.load();

  // 2. Initialize Supabase exactly once.
  // Guarded so missing config (e.g., in tests without .env) does not crash.
  if (Env.supabaseUrl.isNotEmpty && Env.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
      debug: true, // or use kDebugMode from foundation
    );
  }

  runApp(
    const ProviderScope(
      child: RespiraCareApp(),
    ),
  );
}