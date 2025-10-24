import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/app_config.dart';
import 'config/theme.dart';
import 'core/network/api_client.dart';
import 'core/constants/storage_keys.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/payment_repository.dart';
import 'data/repositories/property_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/report_repository.dart';
import 'presentation/auth/providers/auth_provider.dart';
import 'presentation/common/providers/payment_provider.dart';
import 'presentation/common/providers/property_provider.dart';
import 'presentation/common/providers/dashboard_provider.dart';
import 'presentation/common/providers/notification_provider.dart';
import 'package:rental_management_app/presentation/common/providers/report_provider.dart';
import 'config/routes.dart';
import 'package:rental_management_app/presentation/auth/screens/splash_screen.dart';
import 'presentation/common/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local caching
  await Hive.initFlutter();
  
  // Initialize dependencies
  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClient();
  // Apply saved API subdomain (if present) so ApiClient uses correct base URL from app start
  final savedSubdomain = prefs.getString(StorageKeys.apiSubdomain);
  if (savedSubdomain != null && savedSubdomain.isNotEmpty) {
    apiClient.setApiSubdomain(savedSubdomain);
  }

  // Initialize repositories
  final authRepo = AuthRepository(apiClient, prefs);
  final paymentRepo = PaymentRepository(apiClient);
  final propertyRepo = PropertyRepository(apiClient);
  final notificationRepo = NotificationRepository(apiClient);
  final reportRepo = ReportRepository(apiClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepo)..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentProvider(paymentRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => PropertyProvider(propertyRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(notificationRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportProvider(reportRepo),
        ),
        // Theme provider uses the already-initialized SharedPreferences
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, auth, themeProvider, _) {
          return MaterialApp.router(
            title: AppConfig.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router(auth.user),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    ),
  );
}
