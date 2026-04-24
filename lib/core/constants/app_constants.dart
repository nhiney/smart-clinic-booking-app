import '../../shared/di/injection.dart';
import '../services/app_config_service.dart';

class AppConstants {
  static const String appName = "ICare";

  // Legal & Privacy (Dynamic & Versioned)
  static String get privacyPolicyUrl => 
      getIt<AppConfigService>().privacyPolicy.pdfUrl ?? 
      getIt<AppConfigService>().config.privacyPolicyUrl;

  static String get privacyPolicyContent => 
      getIt<AppConfigService>().privacyPolicy.content;

  // Routes
  static const String splashRoute = "/";
  static const String onboardingRoute = "/onboarding";
  static const String loginRoute = "/login";
  static const String registerRoute = "/register";
  static const String homeRoute = "/home";
  static const String doctorListRoute = "/doctors";
  static const String doctorDetailRoute = "/doctors/detail";
  static const String bookingRoute = "/booking";
  static const String appointmentHistoryRoute = "/appointments";
  static const String medicalRecordsRoute = "/medical-records";
  static const String medicalRecordDetailRoute = "/medical-records/detail";
  static const String medicationRoute = "/medication";
  static const String profileRoute = "/profile";
  static const String editProfileRoute = "/profile/edit";
  static const String mapRoute = "/map";

  // Firestore Collections
  static const String usersCollection = "users";
  static const String doctorsCollection = "doctors";
  static const String appointmentsCollection = "appointments";
  static const String medicalRecordsCollection = "medical_records";
  static const String medicationsCollection = "medications";

  // User Roles
  static const String rolePatient = "patient";
  static const String roleDoctor = "doctor";
  static const String roleAdmin = "admin";

  // Appointment Status
  static const String statusPending = "pending";
  static const String statusConfirmed = "confirmed";
  static const String statusCompleted = "completed";
  static const String statusCancelled = "cancelled";
}
