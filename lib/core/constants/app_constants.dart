class AppConstants {
  // App information
  static const String appName = 'Rental Management';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int defaultPageSize = 15;
  static const int maxPageSize = 100;
  
  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';
  
  // Payment methods
  static const List<String> paymentMethods = [
    'bank_transfer',
    'cash',
    'check',
    'mobile_money',
    'credit_card',
  ];
  
  // Payment statuses
  static const String paymentPending = 'pending';
  static const String paymentPaid = 'paid';
  static const String paymentRejected = 'rejected';
  
  // User roles
  static const String roleAdmin = 'admin';
  static const String roleLandlord = 'landlord';
  static const String roleTenant = 'tenant';
  
  // Error messages
  static const String networkError = 'Network error occurred. Please check your connection.';
  static const String serverError = 'Server error occurred. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String authError = 'Authentication failed. Please login again.';
  
  // Cache duration
  static const Duration cacheShortDuration = Duration(minutes: 5);
  static const Duration cacheMediumDuration = Duration(hours: 1);
  static const Duration cacheLongDuration = Duration(hours: 24);
}
