import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/models/user_model.dart';
import '../presentation/auth/screens/login_screen.dart';
import '../presentation/auth/screens/splash_screen.dart';
import '../presentation/admin/dashboard/admin_dashboard_screen.dart';
import '../presentation/admin/reports/financial_report_screen.dart';
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

class AppRouter {
  static GoRouter router(UserModel? user) {
    return GoRouter(
      initialLocation: user == null ? '/splash' : _getInitialRoute(user),
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
        final isSplashRoute = state.location == '/splash';
        final isLoginRoute = state.location == '/login';
        
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
