import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../core/navigation/route_names.dart";
import "../../core/navigation/patient_shell.dart";
import "../../core/navigation/nurse_shell.dart";
import "../../core/navigation/route_observer.dart";
import "../../features/authentication/models/app_user.dart";
import "../../features/authentication/providers/auth_provider.dart";
import "../../features/authentication/screens/auth_gate_page.dart";
import "../../features/authentication/screens/forgot_password_page.dart";
import "../../features/authentication/screens/login_screen.dart";
import "../../features/authentication/screens/register_screen.dart";
import "../../features/authentication/screens/splash_screen.dart";
import "../../features/communication/screens/patient_conversation_screen.dart";
import "../../features/communication/screens/patient_messages_screen.dart";
import "../../features/design_preview/design_system_preview_screen.dart";
import "../../features/monitoring/screens/monitoring_history_screen.dart";
import "../../features/monitoring/screens/monitoring_intro_screen.dart";
import "../../features/nurse/alerts/screens/alert_detail_screen.dart";
import "../../features/nurse/alerts/screens/alerts_screen.dart";
import "../../features/nurse/dashboard/screens/nurse_shell_screen.dart";
import "../../features/nurse/patients/screens/nurse_patient_list_screen.dart";
import "../../features/nurse/patients/screens/nurse_patient_profile_screen.dart";
import "../../features/patient_dashboard/screens/patient_dashboard_screen.dart";
import "../../features/patient_dashboard/screens/placeholders/patient_profile_screen.dart";
import "../../features/patient/treatment/screens/treatment_screen.dart";
import "../../features/patient/education/screens/education_home_screen.dart";

/// Whether the signed-in user may configure surveillance rules.
bool canConfigureMonitoringRules(UserRole? role) {
  return role == UserRole.nurse ||
      role == UserRole.pneumologist ||
      role == UserRole.admin;
}

// Provider for SharedPreferences to use in redirect
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final routerProvider = Provider<GoRouter>((ref) {
  final routeObserver = ref.watch(routeObserverProvider);
  final sharedPrefsAsync = ref.watch(sharedPreferencesProvider);

  // Listen to auth state changes and trigger router refresh.
  ref.listen<AuthState>(authProvider, (_, __) {});

  return GoRouter(
    initialLocation: RouteNames.signIn,
    debugLogDiagnostics: true,
    observers: [routeObserver],
    redirect: (context, state) => _handleRedirect(
      ref,
      state,
      sharedPrefsAsync.valueOrNull,
    ),
    routes: [
      // ─── Auth Routes (no shell) ────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.authGate,
        builder: (_, __) => const AuthGatePage(),
      ),
      // Onboarding route disabled - bypassed via initialLocation
      // GoRoute(
      //   path: RouteNames.onboarding,
      //   builder: (_, __) => const OnboardingScreen(),
      // ),
      GoRoute(
        path: RouteNames.signIn,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.signUp,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (_, __) => const ForgotPasswordPage(),
      ),

      // ─── Patient Shell (StatefulShellRoute) ────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PatientShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.patientHome,
                builder: (context, state) => const PatientDashboardScreen(),
              ),
            ],
          ),
          // Branch 1: Monitor
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.patientMonitor,
                builder: (context, state) => const MonitoringIntroScreen(),
                routes: [
                  GoRoute(
                    path: "history",
                    builder: (context, state) =>
                        const MonitoringHistoryScreen(),
                  ),
                  GoRoute(
                    path: "question",
                    builder: (context, state) =>
                        const PlaceholderPage(title: "Questionnaire"),
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Messages
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.patientMessages,
                builder: (context, state) => const PatientMessagesScreen(),
                routes: [
                  GoRoute(
                    path: ":conversationId",
                    builder: (context, state) => PatientConversationScreen(
                      conversationId:
                          state.pathParameters["conversationId"] ?? "",
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 3: Treatment
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.patientTreatment,
                builder: (context, state) => const TreatmentScreen(),
              ),
            ],
          ),
          // Branch 4: Education
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.patientEducation,
                builder: (context, state) => const EducationHomeScreen(),
              ),
            ],
          ),
          // Branch 5: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.patientProfile,
                builder: (context, state) => const PatientProfileScreen(),
                routes: [
                  GoRoute(
                    path: "settings",
                    builder: (context, state) =>
                        const PlaceholderPage(title: "Paramètres"),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ─── Nurse Shell (StatefulShellRoute) ──────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NurseShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.nurseDashboard,
                builder: (context, state) => const NurseShellScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.nursePatients,
                builder: (context, state) => const NursePatientListScreen(),
                routes: [
                  GoRoute(
                    path: ":patientId",
                    builder: (context, state) => NursePatientProfileScreen(
                      patientId: state.pathParameters["patientId"] ?? "",
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.nurseTasks,
                builder: (context, state) =>
                    const PlaceholderPage(title: "Tâches"),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.nurseAlerts,
                builder: (context, state) => const AlertsScreen(),
                routes: [
                  GoRoute(
                    path: ":alertId",
                    builder: (context, state) => AlertDetailScreen(
                      alertId: state.pathParameters["alertId"] ?? "",
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.nurseProfile,
                builder: (context, state) =>
                    const PlaceholderPage(title: "Profil infirmier"),
              ),
            ],
          ),
        ],
      ),

      // ─── Shared / Dev Routes ───────────────────────────────────
      GoRoute(
        path: RouteNames.designSystem,
        builder: (_, __) => const DesignSystemPreviewScreen(),
      ),
    ],
    // ─── Error / 404 Handler ──────────────────────────────────
    errorBuilder: (context, state) => _NotFoundScreen(
      onHomePressed: () => context.go(RouteNames.patientHome),
    ),
  );
});

/// Handles auth redirects based on current state and destination.
/// Also checks onboarding completion via SharedPreferences for unauthenticated users.
String? _handleRedirect(
    Ref ref, GoRouterState state, SharedPreferences? prefs) {
  final authState = ref.read(authProvider);
  final location = state.matchedLocation;

  final isAuthRoute = location == RouteNames.onboarding ||
      location == RouteNames.signIn ||
      location == RouteNames.signUp ||
      location == RouteNames.splash ||
      location == RouteNames.authGate ||
      location == RouteNames.forgotPassword;

  // Check onboarding from SharedPreferences for unauthenticated users
  final onboardingDone = prefs?.getBool("onboarding_completed") ?? false;

  // If user hasn\'t completed onboarding and is not on onboarding/splash/auth routes
  if (!onboardingDone &&
      !location.startsWith("/onboarding") &&
      location != RouteNames.splash &&
      authState.status == AuthStatus.unauthenticated) {
    return RouteNames.onboarding;
  }

  // If onboarding is done but user is unauthenticated and trying to access protected routes
  if (onboardingDone &&
      authState.status == AuthStatus.unauthenticated &&
      !isAuthRoute &&
      location != RouteNames.splash) {
    return RouteNames.authGate;
  }

  return switch (authState.status) {
    AuthStatus.initializing => null,
    AuthStatus.authenticating || AuthStatus.error => null,
    AuthStatus.authenticated => switch (authState.currentUser?.role) {
        UserRole.nurse => isAuthRoute ? RouteNames.nurseDashboard : null,
        _ => isAuthRoute ? RouteNames.patientHome : null,
      },
    AuthStatus.unauthenticated => isAuthRoute ? null : RouteNames.authGate,
  };
}

/// Fallback screen for unmatched routes (404)
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({required this.onHomePressed});

  final VoidCallback onHomePressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 80,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                "Page introuvable",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "La page demandée n'existe pas ou a été déplacée.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onHomePressed,
                icon: const Icon(Icons.home_rounded),
                label: const Text("Retour à l'accueil"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder page for routes not yet implemented.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          tooltip: "Retour",
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text("À venir dans une prochaine étape",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
