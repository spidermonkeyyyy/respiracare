import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/models/app_user.dart';
import '../../features/authentication/providers/auth_provider.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/onboarding_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/splash_screen.dart';
import '../../features/nurse/alerts/screens/alerts_screen.dart';
import '../../features/nurse/alerts/screens/alert_detail_screen.dart';
import '../../features/nurse/alerts/screens/rules_screen.dart';
import '../../features/nurse/alerts/screens/rule_detail_screen.dart';
import '../../features/nurse/alerts/screens/rule_builder_screen.dart';
import '../../features/communication/screens/patient_messages_screen.dart';
import '../../features/communication/screens/patient_conversation_screen.dart';
import '../../features/communication/screens/nurse_conversation_screen.dart';
import '../../features/communication/screens/create_care_request_screen.dart';
import '../../features/nurse/dashboard/screens/nurse_shell_screen.dart';
import '../../features/nurse/patients/screens/nurse_patient_list_screen.dart';
import '../../features/nurse/patients/screens/nurse_patient_profile_screen.dart';
import '../../features/design_preview/design_system_preview_screen.dart';
import '../../features/monitoring/screens/monitoring_intro_screen.dart';
import '../../features/monitoring/screens/monitoring_question_screen.dart';
import '../../features/monitoring/screens/monitoring_result_screen.dart';
import '../../features/monitoring/screens/monitoring_review_screen.dart';
import '../../features/patient/education/screens/educational_content_detail_screen.dart';
import '../../features/patient/education/screens/educational_resources_screen.dart';
import '../../features/patient/education/screens/education_home_screen.dart';
import '../../features/patient/education/screens/exercise_detail_screen.dart';
import '../../features/patient/education/screens/exercise_session_screen.dart';
import '../../features/patient/education/screens/rehabilitation_screen.dart';
import '../../features/patient/education/screens/smoking_cessation_screen.dart';
import '../../features/patient/education/screens/smoking_entry_screen.dart';
import '../../features/patient/education/screens/smoking_progress_screen.dart';
import '../../features/patient_dashboard/screens/patient_dashboard_screen.dart';
import '../../features/patient_dashboard/screens/placeholders/patient_rehabilitation_screen.dart' show PatientCareTeamScreen;
import '../../features/patient/treatment/screens/inhaler_education_screen.dart';
import '../../features/patient_dashboard/screens/placeholders/patient_profile_screen.dart';
import '../../features/patient/treatment/screens/treatment_screen.dart';

/// Whether the signed-in user may configure surveillance rules.
///
/// TODO: replace with the real permission system once auth exposes per-feature
/// capabilities. Today the decision is derived from the role as a pragmatic
/// stand-in so the route can be gated end-to-end.
bool canConfigureMonitoringRules(UserRole? role) {
  return role == UserRole.nurse ||
      role == UserRole.pneumologist ||
      role == UserRole.admin;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Patient routes
      GoRoute(path: '/patient/home', builder: (_, __) => const PatientDashboardScreen()),
      GoRoute(path: '/patient/monitoring', builder: (_, __) => const MonitoringIntroScreen()),
      GoRoute(path: '/patient/monitoring/question', builder: (_, __) => const MonitoringQuestionScreen()),
      GoRoute(path: '/patient/monitoring/review', builder: (_, __) => const MonitoringReviewScreen()),
      GoRoute(path: '/patient/monitoring/result', builder: (_, __) => const MonitoringResultScreen()),
      GoRoute(path: '/patient/treatment', builder: (_, __) => const TreatmentScreen()),
      GoRoute(path: '/patient/education', builder: (_, __) => const EducationHomeScreen()),
      GoRoute(path: '/patient/education/rehabilitation', builder: (_, __) => const RehabilitationScreen()),
      GoRoute(
        path: '/patient/education/rehabilitation/exercise/:exerciseId',
        builder: (context, state) => ExerciseDetailScreen(
          exerciseId: state.pathParameters['exerciseId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/patient/education/rehabilitation/session/:exerciseId',
        builder: (context, state) => ExerciseSessionScreen(
          exerciseId: state.pathParameters['exerciseId'] ?? '',
        ),
      ),
      GoRoute(path: '/patient/education/smoking', builder: (_, __) => const SmokingCessationScreen()),
      GoRoute(path: '/patient/education/smoking/entry', builder: (_, __) => const SmokingEntryScreen()),
      GoRoute(path: '/patient/education/smoking/progress', builder: (_, __) => const SmokingProgressScreen()),
      GoRoute(path: '/patient/education/resources', builder: (_, __) => const EducationalResourcesScreen()),
      GoRoute(
        path: '/patient/education/resources/:contentId',
        builder: (context, state) => EducationalContentDetailScreen(
          contentId: state.pathParameters['contentId'] ?? '',
        ),
      ),
      GoRoute(path: '/patient/education/inhaler', builder: (_, __) => const InhalerEducationScreen()),
      GoRoute(path: '/patient/profile', builder: (_, __) => const PatientProfileScreen()),
      GoRoute(path: '/patient/rehabilitation', builder: (_, __) => const RehabilitationScreen()),
      GoRoute(path: '/patient/care-team', builder: (_, __) => const PatientCareTeamScreen()),
      GoRoute(path: '/patient/messages', builder: (_, __) => const PatientMessagesScreen()),
      GoRoute(
        path: '/patient/messages/:conversationId',
        builder: (context, state) => PatientConversationScreen(
          conversationId: state.pathParameters['conversationId'] ?? '',
        ),
      ),

      // Nurse routes
      GoRoute(path: '/nurse/home', builder: (_, __) => const NurseShellScreen()),
      GoRoute(path: '/nurse/patients', builder: (_, __) => const NursePatientListScreen()),
      GoRoute(
        path: '/nurse/patients/:patientId',
        builder: (context, state) => NursePatientProfileScreen(
          patientId: state.pathParameters['patientId'] ?? '',
        ),
      ),

      // Alerts & configurable surveillance rules
      GoRoute(path: '/nurse/alerts', builder: (_, __) => const AlertsScreen()),
      GoRoute(
        path: '/nurse/alerts/:alertId',
        builder: (context, state) => AlertDetailScreen(
          alertId: state.pathParameters['alertId'] ?? '',
        ),
      ),
      GoRoute(path: '/nurse/rules', builder: (_, __) => const RulesScreen()),
      GoRoute(
        path: '/nurse/rules/new',
        builder: (_, __) => const RuleBuilderScreen(ruleId: 'new'),
      ),
      GoRoute(
        path: '/nurse/rules/:ruleId/edit',
        builder: (context, state) => RuleBuilderScreen(
          ruleId: state.pathParameters['ruleId'] ?? 'new',
        ),
      ),
      GoRoute(
        path: '/nurse/rules/:ruleId',
        builder: (context, state) => RuleDetailScreen(
          ruleId: state.pathParameters['ruleId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/nurse/messages/:conversationId',
        builder: (context, state) => NurseConversationScreen(
          conversationId: state.pathParameters['conversationId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/nurse/messages/:conversationId/request',
        builder: (context, state) => CreateCareRequestScreen(
          conversationId: state.pathParameters['conversationId'] ?? '',
        ),
      ),

      // Dev tools
      GoRoute(path: '/design-system', builder: (_, __) => const DesignSystemPreviewScreen()),
    ],
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final userRole = authState.currentUser?.role;

      if (loc == '/splash' || authState.status == AuthStatus.initializing) {
        return null;
      }

      if (!isAuthenticated) {
        final isPublic = loc == '/login' ||
            loc == '/register' ||
            loc == '/onboarding' ||
            loc == '/design-system';
        if (!isPublic) {
          return authState.isOnboardingCompleted ? '/login' : '/onboarding';
        }
        return null;
      }

      final isAuthRoute = loc == '/login' || loc == '/register' || loc == '/onboarding';
      if (isAuthRoute) {
        return userRole == UserRole.nurse ? '/nurse/home' : '/patient/home';
      }

      if (loc.startsWith('/nurse') && userRole != UserRole.nurse) {
        return '/patient/home';
      }
      if (loc.startsWith('/patient') && userRole != UserRole.patient) {
        return '/nurse/home';
      }

      // Configuring surveillance rules is a governed action.
      if (loc.startsWith('/nurse/rules') && !canConfigureMonitoringRules(userRole)) {
        return '/nurse/home';
      }

      return null;
    },
  );
});
