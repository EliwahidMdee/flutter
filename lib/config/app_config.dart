class AppConfig {
  // Environment - change based on build
  static const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  // API Base URL
  static String get apiBaseUrl {
    // Use the provided backend for all environments by default
    return 'https://general.swapdez.app/api';
  }
  
  // Timeouts
  static const connectTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int pageSize = 15;
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // App Info
  static const String appName = 'Rental Management';
  static const String appVersion = '1.0.0';
}
