import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/app_config.dart';
import 'config/theme.dart';
import 'core/network/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/payment_repository.dart';
import 'data/repositories/property_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'presentation/auth/providers/auth_provider.dart';
import 'presentation/common/providers/payment_provider.dart';
import 'presentation/common/providers/property_provider.dart';
import 'presentation/common/providers/dashboard_provider.dart';
import 'presentation/common/providers/notification_provider.dart';
import 'config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local caching
  await Hive.initFlutter();
  
  // Initialize dependencies
  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClient();
  
  // Initialize repositories
  final authRepo = AuthRepository(apiClient, prefs);
  final paymentRepo = PaymentRepository(apiClient);
  final propertyRepo = PropertyRepository(apiClient);
  final notificationRepo = NotificationRepository(apiClient);
  
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return MaterialApp.router(
          title: AppConfig.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          routerConfig: AppRouter.router(auth.user),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
