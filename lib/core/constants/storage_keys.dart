class StorageKeys {
  // Authentication
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userData = 'user_data';
  static const String userRole = 'user_role';
  
  // Settings
  static const String isDarkMode = 'is_dark_mode';
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';
  
  // Cache
  static const String dashboardCache = 'dashboard_cache';
  static const String propertiesCache = 'properties_cache';
  static const String paymentsCache = 'payments_cache';
  static const String notificationsCache = 'notifications_cache';
  
  // App state
  static const String isFirstLaunch = 'is_first_launch';
  static const String lastSyncTime = 'last_sync_time';

  // API subdomain (e.g., 'john' -> john.swapdez.app)
  static const String apiSubdomain = 'api_subdomain';
}
