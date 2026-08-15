import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/app_constants.dart';
import 'router/app_router.dart';
import '../core/navigation/back_button_handler.dart';
import '../theme/app_theme.dart';
import '../core/accessibility/accessibility_providers_root.dart';
import '../core/accessibility/text_scale_provider.dart';
import '../features/authentication/widgets/session_expiry_handler.dart';

class RespiraCareApp extends ConsumerWidget {
  const RespiraCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return AccessibilityProvidersRoot(
      child: BackButtonHandler(
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: router,
          builder: (context, child) {
            return SessionExpiryHandler(
              child: ConstrainedTextScale(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}
