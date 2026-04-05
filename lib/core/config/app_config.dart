import 'package:flutter/foundation.dart';

/// Centralized application configuration.
/// Controls environment-specific behavior (dev/staging/prod).
class AppConfig {
  AppConfig._();

  /// Whether the app is running in development mode.
  static bool get isDev => kDebugMode;

  /// Whether to use mock data instead of real Firebase calls.
  static bool get useMockData => kDebugMode;

  /// Mock OTP code for development mode.
  static const String mockOtpCode = '123456';

  /// Mock verification ID for development mode.
  static const String mockVerificationId = 'MOCK_VERIFICATION_ID';

  /// Application name.
  static const String appName = 'ICare';

  /// Application version.
  static const String appVersion = '1.0.0';

  /// Maximum retry attempts for network requests.
  static const int maxRetryAttempts = 3;

  /// Default timeout for network requests (seconds).
  static const int requestTimeoutSeconds = 30;

  /// Firebase Firestore collection names.
  static const String usersCollection = 'users';
  static const String doctorsCollection = 'doctors';
  static const String appointmentsCollection = 'appointments';
  static const String medicalRecordsCollection = 'medical_records';
  static const String medicationsCollection = 'medications';
  static const String notificationsCollection = 'notifications';
  static const String reviewsCollection = 'reviews';
  static const String supportTicketsCollection = 'support_tickets';
  static const String healthSummaryCollection = 'health_summary';
  static const String newsCollection = 'health_news';

  /// User roles for RBAC.
  static const String rolePatient = 'patient';
  static const String roleDoctor = 'doctor';
  static const String roleAdmin = 'admin';

  /// Pagination defaults.
  static const int defaultPageSize = 20;

  /// Health metric thresholds.
  static const double normalBmiMin = 18.5;
  static const double normalBmiMax = 24.9;
  static const int normalHeartRateMin = 60;
  static const int normalHeartRateMax = 100;
  static const double normalBloodSugarMax = 100.0;
}
