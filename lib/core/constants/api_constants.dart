class ApiEndpoints {
  // Auth
  static const login = '/login';
  static const register = '/register';
  static const logout = '/logout';
  static const getUser = '/user';
  static const updateProfile = '/user/profile';
  static const changePassword = '/user/change-password';
  
  // Dashboard
  static const dashboard = '/dashboard';
  static const dashboardStats = '/dashboard/stats';
  
  // Properties
  static const properties = '/properties';
  static String propertyDetail(int id) => '/properties/$id';
  static String propertyUnits(int id) => '/properties/$id/units';
  
  // Payments
  static const payments = '/payments';
  static String paymentDetail(int id) => '/payments/$id';
  static String verifyPayment(int id) => '/payments/$id/verify';
  static const pendingPayments = '/payments/pending/list';
  
  // Tenants
  static const tenants = '/tenants';
  static String tenantDetail(int id) => '/tenants/$id';
  
  // Leases
  static const leases = '/leases';
  static String leaseDetail(int id) => '/leases/$id';
  
  // Reports
  static const revenueReport = '/reports/revenue';
  static const expensesReport = '/reports/expenses';
  static const occupancyReport = '/reports/occupancy';
  static const balanceSheet = '/reports/balance-sheet';
  static const profitLoss = '/reports/profit-loss';
  
  // Notifications
  static const notifications = '/notifications';
  static String markRead(int id) => '/notifications/$id/read';
  static const markAllRead = '/notifications/read-all';
  static String respondToNotification(int id) => '/notifications/$id/respond';
}
