/// Central route name constants for RespiraCare.
library;

/// Never use string literals for routes anywhere else in the app.
/// All routes are defined here to ensure type safety and easy refactoring.
class RouteNames {
  RouteNames._();

  // ─── Auth Routes ─────────────────────────────────────────────────
  static const String authGate = "/";
  static const String signIn = "/sign-in";
  static const String signUp = "/sign-up";
  static const String forgotPassword = "/forgot-password";
  static const String onboarding = "/onboarding";
  static const String splash = "/splash";

  // ─── Patient Routes ──────────────────────────────────────────────
  static const String patientHome = "/patient/home";
  static const String patientMonitor = "/patient/monitor";
  static const String patientMonitorHistory = "/patient/monitor/history";
  static const String patientMonitorSession =
      "/patient/monitor/session/:sessionId";
  static const String patientMonitorQuestion = "/patient/monitor/question";
  static const String patientTreatment = "/patient/treatment";
  static const String patientEducation = "/patient/education";
  static const String patientMessages = "/patient/messages";
  static const String patientConversation = "/patient/messages/:conversationId";
  static const String patientCareRequest = "/patient/care-request";
  static const String patientTasks = "/patient/tasks";
  static const String patientTaskDetail = "/patient/tasks/:taskId";
  static const String patientTreatments = "/patient/treatments";
  static const String patientInhaler = "/patient/inhaler";
  static const String patientProfile = "/patient/profile";
  static const String patientSettings = "/patient/settings";
  static const String patientRehabilitation =
      "/patient/education/rehabilitation";
  static const String patientExerciseDetail =
      "/patient/education/rehabilitation/exercise/:exerciseId";
  static const String patientExerciseSession =
      "/patient/education/rehabilitation/session/:exerciseId";
  static const String patientSmoking = "/patient/education/smoking";
  static const String patientSmokingEntry = "/patient/education/smoking/entry";
  static const String patientSmokingProgress =
      "/patient/education/smoking/progress";
  static const String patientResources = "/patient/education/resources";
  static const String patientResourceDetail =
      "/patient/education/resources/:contentId";

  // ─── Nurse Routes ────────────────────────────────────────────────
  static const String nurseDashboard = "/nurse/dashboard";
  static const String nursePatients = "/nurse/patients";
  static const String nursePatientDetail = "/nurse/patients/:patientId";
  static const String nursePatientMonitor =
      "/nurse/patients/:patientId/monitor";
  static const String nurseTasks = "/nurse/tasks";
  static const String nurseAlerts = "/nurse/alerts";
  static const String nurseAlertDetail = "/nurse/alerts/:alertId";
  static const String nurseMessages = "/nurse/messages";
  static const String nurseConversation = "/nurse/messages/:conversationId";
  static const String nurseAssessments = "/nurse/assessments";
  static const String nurseProfile = "/nurse/profile";
  static const String nurseSettings = "/nurse/settings";
  static const String nurseRules = "/nurse/rules";
  static const String nurseRuleNew = "/nurse/rules/new";
  static const String nurseRuleEdit = "/nurse/rules/:ruleId/edit";
  static const String nurseRuleDetail = "/nurse/rules/:ruleId";

  // ─── Shared / Dev ────────────────────────────────────────────────
  static const String designSystem = "/design-system";
}
