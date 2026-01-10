/// Application-wide constants
class AppConstants {
  // API endpoints
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = 'v1';
  static const int connectTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000; // milliseconds

  // Storage keys
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String themeModeKey = 'theme_mode';
  static const String languageKey = 'language';

  // App info
  static const String appName = 'Plant Companion';
  static const String appVersion = '1.0.0';
  static const String appPackageName = 'com.example.plant_companion';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'hh:mm a';
}
