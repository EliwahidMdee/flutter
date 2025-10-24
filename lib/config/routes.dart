import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../presentation/auth/screens/login_screen.dart';
import '../presentation/auth/screens/splash_screen.dart';
import '../presentation/admin/dashboard/admin_dashboard_screen.dart';
import '../presentation/admin/reports/financial_report_screen.dart';
import '../presentation/admin/reports/report_detail_screen.dart';
import '../presentation/admin/payments/payment_approval_screen.dart';
import '../presentation/admin/management/tenant_management_screen.dart';
import '../presentation/landlord/dashboard/landlord_dashboard_screen.dart';
import '../presentation/landlord/properties/property_list_screen.dart';
import '../presentation/landlord/properties/property_detail_screen.dart';
import '../presentation/landlord/properties/add_property_screen.dart';
import '../presentation/landlord/tenants/tenant_list_screen.dart';
import '../presentation/landlord/payments/payment_list_screen.dart';
import '../presentation/tenant/dashboard/tenant_dashboard_screen.dart';
import '../presentation/tenant/payments/make_payment_screen.dart';
import '../presentation/tenant/payments/payment_history_screen.dart';
import '../presentation/tenant/lease/lease_detail_screen.dart';
import '../presentation/tenant/notifications/notification_list_screen.dart';
import '../presentation/common/screens/profile_screen.dart';
import '../presentation/common/screens/settings_screen.dart';
import 'package:rental_management_app/presentation/common/providers/report_provider.dart';

class AppRouter {
  static GoRouter router(UserModel? user) {
    return GoRouter(
      initialLocation: user == null ? '/login' : _getInitialRoute(user),
      routes: [
        // Splash screen
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        
        // Auth routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        
        // Admin routes
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/reports',
          builder: (context, state) => const FinancialReportScreen(),
        ),
        // Report detail routes (income statement, balance sheet, trial balance)
        GoRoute(
          path: '/admin/reports/income-statement/summary',
          builder: (context, state) => const ReportDetailScreen(tab: ReportTab.profitLoss, title: 'Income Statement - Summary', detailed: false),
        ),
        GoRoute(
          path: '/admin/reports/income-statement/detailed',
          builder: (context, state) => const ReportDetailScreen(tab: ReportTab.profitLoss, title: 'Income Statement - Detailed', detailed: true),
        ),
        GoRoute(
          path: '/admin/reports/balance-sheet/summary',
          builder: (context, state) => const ReportDetailScreen(tab: ReportTab.balanceSheet, title: 'Balance Sheet - Summary'),
        ),
        GoRoute(
          path: '/admin/reports/balance-sheet/detailed',
          builder: (context, state) => const ReportDetailScreen(tab: ReportTab.balanceSheet, title: 'Balance Sheet - Detailed'),
        ),
        GoRoute(
          path: '/admin/reports/occupancy/summary',
          builder: (context, state) => const ReportDetailScreen(tab: ReportTab.occupancy, title: 'Occupancy - Summary'),
        ),
        GoRoute(
          path: '/admin/reports/occupancy/detailed',
          builder: (context, state) => const ReportDetailScreen(tab: ReportTab.occupancy, title: 'Occupancy - Detailed'),
        ),
        GoRoute(
          path: '/admin/reports/trial-balance/summary',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Trial Balance - Summary')),
            body: const Center(child: Text('Trial Balance summary view coming soon')),
          ),
        ),
        GoRoute(
          path: '/admin/reports/trial-balance/detailed',
          builder: (context, state) => Scaffold(
            appBar: AppBar(title: const Text('Trial Balance - Detailed')),
            body: const Center(child: Text('Trial Balance detailed view coming soon')),
          ),
        ),
        GoRoute(
          path: '/admin/payments',
          builder: (context, state) => const PaymentApprovalScreen(),
        ),
        GoRoute(
          path: '/admin/tenants',
          builder: (context, state) => const TenantManagementScreen(),
        ),
        
        // Landlord routes
        GoRoute(
          path: '/landlord',
          builder: (context, state) => const LandlordDashboardScreen(),
        ),
        GoRoute(
          path: '/landlord/properties',
          builder: (context, state) => const PropertyListScreen(),
        ),
        GoRoute(
          path: '/landlord/properties/add',
          builder: (context, state) => const AddPropertyScreen(),
        ),
        GoRoute(
          path: '/landlord/properties/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return PropertyDetailScreen(propertyId: int.parse(id));
          },
        ),
        GoRoute(
          path: '/landlord/tenants',
          builder: (context, state) => const TenantListScreen(),
        ),
        GoRoute(
          path: '/landlord/payments',
          builder: (context, state) => const PaymentListScreen(),
        ),
        
        // Tenant routes
        GoRoute(
          path: '/tenant',
          builder: (context, state) => const TenantDashboardScreen(),
        ),
        GoRoute(
          path: '/tenant/make-payment',
          builder: (context, state) => const MakePaymentScreen(),
        ),
        GoRoute(
          path: '/tenant/payment-history',
          builder: (context, state) => const PaymentHistoryScreen(),
        ),
        GoRoute(
          path: '/tenant/lease',
          builder: (context, state) => const LeaseDetailScreen(),
        ),
        GoRoute(
          path: '/tenant/notifications',
          builder: (context, state) => const NotificationListScreen(),
        ),
        
        // Common routes
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = user != null;
        // Use the Uri path from the GoRouterState (safer across go_router versions)
        final isSplashRoute = state.uri.path == '/splash';
        final isLoginRoute = state.uri.path == '/login';

        // If not logged in and not on splash or login, redirect to splash
        if (!isLoggedIn && !isSplashRoute && !isLoginRoute) {
          return '/splash';
        }
        
        // If logged in and on splash or login, redirect to role-based dashboard
        if (isLoggedIn && (isSplashRoute || isLoginRoute)) {
          return _getInitialRoute(user);
        }
        
        return null;
      },
    );
  }
  
  static String _getInitialRoute(UserModel user) {
    if (user.isAdmin) return '/admin';
    if (user.isLandlord) return '/landlord';
    if (user.isTenant) return '/tenant';
    return '/login';
  }
}
