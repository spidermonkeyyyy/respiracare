import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

/// RespiraCare Main Entry Point
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Root Application wrapped with Riverpod ProviderScope
  runApp(
    const ProviderScope(
      child: RespiraCareApp(),
    ),
  );
}
