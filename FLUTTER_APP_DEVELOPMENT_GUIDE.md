# Flutter Mobile App Development Guide
## Rental Management System - Complete Mobile Application

---

## 📑 Table of Contents

1. [Introduction](#1-introduction)
2. [Prerequisites](#2-prerequisites)
3. [Project Setup](#3-project-setup)
4. [Folder Structure](#4-folder-structure)
5. [Backend API Integration](#5-backend-api-integration)
6. [Authentication Flow](#6-authentication-flow)
7. [Role-Based Navigation](#7-role-based-navigation)
8. [State Management](#8-state-management)
9. [UI Design Guidelines](#9-ui-design-guidelines)
10. [Secure API Communication](#10-secure-api-communication)
11. [Error Handling and Offline Caching](#11-error-handling-and-offline-caching)
12. [Testing and Debugging](#12-testing-and-debugging)
13. [Deployment](#13-deployment)
14. [Best Practices](#14-best-practices)

---

## 1. Introduction

### 1.1 Overview

This comprehensive guide walks you through creating a production-ready Flutter mobile application for the existing Laravel-based Rental Management System. The mobile app enables Admin, Landlord, and Tenant users to manage their rental operations on-the-go.

### 1.2 Key Features by Role

**Admin:**
- View all financial, rental, and tenant activity reports
- Approve or reject payment requests from any user
- Manage tenants and landlords across all properties
- Access comprehensive dashboard with real-time metrics
- Receive and respond to all system notifications

**Landlord:**
- View tenant payments and property-specific reports
- Approve or request payments for their properties
- Manage properties, units, and leases
- Track occupancy rates and revenue
- Communicate with tenants through notifications

**Tenant:**
- View rent status and detailed payment history
- Make payments and record transactions
- View and download receipts
- Access lease information and terms
- Receive notifications from landlords

### 1.3 Architecture Overview

The app follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│      Presentation Layer (UI)            │
│  ┌────────────────────────────────────┐ │
│  │  Screens, Widgets, State Management│ │
│  └────────────────────────────────────┘ │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│      Business Logic Layer               │
│  ┌────────────────────────────────────┐ │
│  │  Use Cases, Entities, Repositories │ │
│  └────────────────────────────────────┘ │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│      Data Layer                         │
│  ┌────────────────────────────────────┐ │
│  │  API Client, Local Storage, Models │ │
│  └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Key Technologies:**
- **Frontend:** Flutter/Dart
- **Backend:** Laravel (existing API)
- **Authentication:** Laravel Sanctum (token-based)
- **State Management:** Provider/Riverpod/Bloc
- **Local Storage:** Hive + Flutter Secure Storage
- **Networking:** Dio HTTP client

---

## 2. Prerequisites

### 2.1 Required Software

**Essential Tools:**

1. **Flutter SDK** (3.16.0 or higher)
```bash
# Install Flutter
# Visit: https://docs.flutter.dev/get-started/install

# Verify installation
flutter --version
flutter doctor
```

2. **Dart SDK** (included with Flutter)

3. **IDE - Choose one:**
   - **Android Studio** with Flutter and Dart plugins
   - **VS Code** with Flutter and Dart extensions (lighter weight)

4. **Git** for version control
```bash
git --version  # Should be 2.x or higher
```

5. **Android Development:**
   - Android Studio
   - Android SDK (API 21-34)
   - Java Development Kit (JDK 11 or higher)

6. **iOS Development** (macOS only):
   - Xcode 15 or higher
   - CocoaPods (`sudo gem install cocoapods`)
   - iOS Simulator

### 2.2 Required Knowledge

- **Essential:**
  - Dart programming fundamentals
  - Flutter widgets and layouts
  - REST API concepts
  - JSON data handling
  - Async/await programming

- **Recommended:**
  - State management patterns
  - Clean architecture principles
  - Git workflow
  - Mobile UI/UX best practices

### 2.3 Backend Requirements

Ensure your Laravel backend has:
- ✅ Laravel Sanctum configured for API authentication
- ✅ API routes accessible and documented
- ✅ CORS properly configured for mobile access
- ✅ SSL/TLS certificate (HTTPS) for production
- ✅ Role-based permissions using Spatie Permission package

### 2.4 Environment Setup Checklist

```bash
# 1. Verify Flutter installation
flutter doctor -v

# 2. Check connected devices
flutter devices

# 3. Test Flutter can communicate with devices
flutter emulators  # List available emulators

# 4. Create a test project to verify setup
flutter create test_app
cd test_app
flutter run
```

If `flutter doctor` shows any issues, resolve them before proceeding.

---

## 3. Project Setup

### 3.1 Clone and Understand Backend

First, familiarize yourself with the existing Laravel API:

```bash
# Clone the repository
git clone https://github.com/EliwahidMdee/rental-management.git
cd rental-management

# Install dependencies
composer install
npm install

# Review API structure
cat routes/api.php           # Check API endpoints
ls -R app/Http/Controllers/Api  # Review controllers
ls -R app/Models                # Review data models

# Start the backend (for local testing)
php artisan serve              # Runs on http://localhost:8000
```

**Key API Endpoints to Note:**
- `/api/login` - Authentication
- `/api/dashboard` - Dashboard data
- `/api/properties` - Property management
- `/api/payments` - Payment operations
- `/api/reports/*` - Various reports
- `/api/notifications` - Notifications

### 3.2 Create Flutter Project

```bash
# Navigate to your projects directory
cd ~/Projects  # or your preferred location

# Create new Flutter project
flutter create rental_management_app \
  --org com.yourcompany \
  --description "Mobile app for rental property management"

# Navigate into project
cd rental_management_app

# Open in your IDE
code .  # VS Code
# or
studio .  # Android Studio
```

### 3.3 Configure pubspec.yaml

Replace `pubspec.yaml` content with:

```yaml
name: rental_management_app
description: Mobile app for rental property management
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Core UI
  cupertino_icons: ^1.0.6
  flutter_svg: ^2.0.9
  google_fonts: ^6.1.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  flutter_spinkit: ^5.2.0
  pull_to_refresh: ^2.0.0
  
  # State Management (choose one - we'll use Provider for this guide)
  provider: ^6.1.1
  
  # Networking & API
  dio: ^5.4.0
  http: ^1.1.2
  connectivity_plus: ^5.0.2
  
  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Authentication
  jwt_decoder: ^2.0.1
  
  # Routing
  go_router: ^12.1.3
  
  # Forms & Validation
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^9.1.0
  
  # Date & Time
  intl: ^0.19.0
  
  # Charts (for reports)
  fl_chart: ^0.65.0
  
  # PDF
  pdf: ^3.10.7
  printing: ^5.11.1
  
  # Images
  image_picker: ^1.0.7
  
  # Notifications
  flutter_local_notifications: ^16.3.0
  
  # Utils
  logger: ^2.0.2+1
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  freezed: ^2.4.6
  hive_generator: ^2.0.1
  mockito: ^5.4.4

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
```

### 3.4 Install Dependencies

```bash
# Install packages
flutter pub get

# Verify dependencies
flutter pub deps
```

### 3.5 Create Project Structure

```bash
# Create directory structure
mkdir -p lib/{config,core/{constants,network,storage,utils,errors},data/{models,repositories,datasources/{remote,local}},presentation/{auth,admin,landlord,tenant,common}/{screens,widgets,providers}}

# Create asset directories
mkdir -p assets/{images,icons,fonts}

# Create initial files
touch lib/config/{app_config,theme,routes}.dart
touch lib/core/constants/{api_constants,app_constants}.dart
touch lib/core/network/{api_client,interceptors}.dart
touch lib/core/utils/{logger,validators}.dart
```

### 3.6 Configure Android

Edit `android/app/build.gradle`:

```gradle
android {
    namespace 'com.yourcompany.rental_management_app'
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.yourcompany.rental_management_app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
        debug {
            applicationIdSuffix ".debug"
        }
    }
}
```

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <application
        android:label="Rental Management"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">
        <!-- Rest of config -->
    </application>
</manifest>
```

### 3.7 Configure iOS

Edit `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to upload property images</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos</string>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 3.8 Test Setup

```bash
# Run app on connected device/emulator
flutter run

# Or specify device
flutter run -d <device_id>

# Run in release mode
flutter run --release
```

---

## 4. Folder Structure

A clean, scalable folder structure is essential for maintainability:

```
rental_management_app/
├── android/                          # Android native code
├── ios/                              # iOS native code
├── lib/
│   ├── main.dart                     # App entry point
│   │
│   ├── config/                       # App configuration
│   │   ├── app_config.dart          # Environment configs
│   │   ├── routes.dart              # Route definitions
│   │   └── theme.dart               # Theme & styling
│   │
│   ├── core/                         # Core utilities
│   │   ├── constants/
│   │   │   ├── api_constants.dart   # API endpoints
│   │   │   ├── app_constants.dart   # App constants
│   │   │   └── storage_keys.dart    # Storage keys
│   │   ├── network/
│   │   │   ├── api_client.dart      # HTTP client
│   │   │   ├── interceptors.dart    # Request/response interceptors
│   │   │   └── network_info.dart    # Connectivity check
│   │   ├── storage/
│   │   │   ├── local_storage.dart   # SharedPreferences wrapper
│   │   │   └── secure_storage.dart  # Secure storage
│   │   ├── utils/
│   │   │   ├── validators.dart      # Form validators
│   │   │   ├── formatters.dart      # Data formatters
│   │   │   └── logger.dart          # Logger utility
│   │   └── errors/
│   │       ├── exceptions.dart      # Custom exceptions
│   │       └── failures.dart        # Failure types
│   │
│   ├── data/                         # Data layer
│   │   ├── models/                   # Data models (JSON)
│   │   │   ├── user_model.dart
│   │   │   ├── property_model.dart
│   │   │   ├── payment_model.dart
│   │   │   ├── tenant_model.dart
│   │   │   ├── lease_model.dart
│   │   │   └── notification_model.dart
│   │   ├── repositories/             # Repository implementations
│   │   │   ├── auth_repository.dart
│   │   │   ├── property_repository.dart
│   │   │   ├── payment_repository.dart
│   │   │   └── report_repository.dart
│   │   └── datasources/
│   │       ├── remote/               # API data sources
│   │       └── local/                # Local cache
│   │
│   ├── presentation/                 # UI layer
│   │   ├── common/                   # Shared widgets
│   │   │   ├── widgets/
│   │   │   │   ├── custom_app_bar.dart
│   │   │   │   ├── custom_button.dart
│   │   │   │   ├── loading_indicator.dart
│   │   │   │   └── error_widget.dart
│   │   │   └── dialogs/
│   │   │
│   │   ├── auth/                     # Authentication
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── widgets/
│   │   │   └── providers/
│   │   │       └── auth_provider.dart
│   │   │
│   │   ├── admin/                    # Admin UI
│   │   │   ├── dashboard/
│   │   │   ├── reports/
│   │   │   ├── payments/
│   │   │   └── management/
│   │   │
│   │   ├── landlord/                 # Landlord UI
│   │   │   ├── dashboard/
│   │   │   ├── properties/
│   │   │   ├── payments/
│   │   │   └── tenants/
│   │   │
│   │   └── tenant/                   # Tenant UI
│   │       ├── dashboard/
│   │       ├── payments/
│   │       ├── lease/
│   │       └── notifications/
│   │
│   └── services/                     # Services
│       ├── notification_service.dart
│       └── cache_service.dart
│
├── test/                             # Unit tests
├── integration_test/                 # Integration tests
└── assets/
    ├── images/
    ├── icons/
    └── fonts/
```

### Key Directories Explained

**config/**: Application-wide configuration (API URLs, themes, routes)
**core/**: Reusable utilities and infrastructure (networking, storage, errors)
**data/**: Data layer (models, repositories, API/local data sources)
**presentation/**: UI layer separated by user role
**services/**: Background services and app-level operations

---

## 5. Backend API Integration

### 5.1 Available API Endpoints

From `routes/api.php`, here are the key endpoints:

**Authentication:**
```
POST   /api/login                     # Login with email/password
POST   /api/register                  # Register new user
POST   /api/logout                    # Logout (requires token)
GET    /api/user                      # Get authenticated user
PUT    /api/user/profile              # Update profile
POST   /api/user/change-password      # Change password
```

**Dashboard:**
```
GET    /api/dashboard                 # Dashboard overview
GET    /api/dashboard/stats           # Statistics
GET    /api/dashboard/metrics/*       # Various metrics
```

**Properties:**
```
GET    /api/properties                # List all properties
POST   /api/properties                # Create property
GET    /api/properties/{id}           # Get property details
PUT    /api/properties/{id}           # Update property
DELETE /api/properties/{id}           # Delete property
```

**Payments:**
```
GET    /api/payments                  # List payments
POST   /api/payments                  # Create payment
GET    /api/payments/{id}             # Get payment
PUT    /api/payments/{id}             # Update payment
POST   /api/payments/{id}/verify      # Approve payment
GET    /api/payments/pending/list     # List pending payments
```

**Reports:**
```
GET    /api/reports/revenue           # Revenue report
GET    /api/reports/expenses          # Expenses report
GET    /api/reports/occupancy         # Occupancy report
GET    /api/reports/balance-sheet     # Balance sheet
GET    /api/reports/profit-loss       # P&L statement
```

**Notifications:**
```
GET    /api/notifications             # List notifications
POST   /api/notifications/{id}/read   # Mark as read
POST   /api/notifications/read-all    # Mark all read
```

### 5.2 Create API Configuration

Create `lib/config/app_config.dart`:

```dart
class AppConfig {
  // Environment - change based on build
  static const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'production',
  );
  
  // API Base URL
  static String get apiBaseUrl {
    switch (environment) {
      case 'development':
        return 'http://10.0.2.2:8000/api';  // Android emulator
        // return 'http://localhost:8000/api';  // iOS simulator
      case 'staging':
        return 'https://staging.yourdomain.com/api';
      case 'production':
      default:
        return 'https://yourdomain.com/api';
    }
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
```

Create `lib/core/constants/api_constants.dart`:

```dart
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
  
  // Reports
  static const revenueReport = '/reports/revenue';
  static const expensesReport = '/reports/expenses';
  static const occupancyReport = '/reports/occupancy';
  
  // Notifications
  static const notifications = '/notifications';
  static String markRead(int id) => '/notifications/$id/read';
  static const markAllRead = '/notifications/read-all';
}
```

See the supplementary files for complete API client implementation.

---

## 6. Authentication Flow

### 6.1 Authentication Architecture

```
App Launch
    ↓
Check Token Exists?
    ↓ Yes            ↓ No
Validate Token   Show Login
    ↓ Valid          ↓
Get User Info    Enter Credentials
    ↓                ↓
Load Role       Call /api/login
    ↓                ↓
Route to        Save Token
Dashboard       Get User & Role
                    ↓
                Route to Dashboard
```

### 6.2 User Model with Roles

Create `lib/data/models/user_model.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final List<RoleModel>? roles;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.firstName,
    this.lastName,
    this.roles,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  // Role helpers
  String? get primaryRole => roles?.first.name;
  bool hasRole(String role) => roles?.any((r) => r.name == role) ?? false;
  bool get isAdmin => hasRole('admin');
  bool get isLandlord => hasRole('landlord');
  bool get isTenant => hasRole('tenant');
}

@JsonSerializable()
class RoleModel {
  final int id;
  final String name;
  
  RoleModel({required this.id, required this.name});
  
  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      _$RoleModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$RoleModelToJson(this);
}
```

Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6.3 Authentication Repository

Create `lib/data/repositories/auth_repository.dart`:

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _client;
  final SharedPreferences _prefs;
  
  AuthRepository(this._client, this._prefs);
  
  Future<UserModel> login(String email, String password) async {
    final response = await _client.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
        'device_name': 'mobile',
      },
    );
    
    final data = response.data['data'] ?? response.data;
    final token = data['token'];
    final user = UserModel.fromJson(data['user']);
    
    // Save token
    await _client.setToken(token);
    await _prefs.setString(AppConfig.tokenKey, token);
    await _prefs.setString(AppConfig.userKey, jsonEncode(user.toJson()));
    
    return user;
  }
  
  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } finally {
      await _clearAuth();
    }
  }
  
  Future<UserModel?> getCachedUser() async {
    final userJson = _prefs.getString(AppConfig.userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }
  
  Future<bool> isLoggedIn() async {
    final token = _prefs.getString(AppConfig.tokenKey);
    return token != null;
  }
  
  Future<void> _clearAuth() async {
    await _client.clearToken();
    await _prefs.remove(AppConfig.tokenKey);
    await _prefs.remove(AppConfig.userKey);
  }
}
```

### 6.4 Login Screen

Create `lib/presentation/auth/screens/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Navigation handled by app.dart based on auth status
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Icon(
                    Icons.home_work,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rental Management',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 48),
                  
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Login Button
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _login,
                          child: auth.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Login'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 7. Role-Based Navigation

### 7.1 Navigation Strategy

The app uses different navigation structures based on user roles:

```
Admin Dashboard:
├── Dashboard (Overview)
├── Reports
│   ├── Financial
│   ├── Tenant Activity
│   └── Property Performance
├── Payment Approvals
├── Tenant Management
├── Landlord Management
└── Settings

Landlord Dashboard:
├── Dashboard (My Properties)
├── Properties
│   ├── List
│   └── Details
├── Tenants
├── Payments
│   ├── Received
│   └── Request Payment
├── Reports
└── Settings

Tenant Dashboard:
├── Dashboard (My Lease)
├── Rent Status
├── Make Payment
├── Payment History
├── Lease Details
├── Notifications
└── Settings
```

### 7.2 Implementing Role-Based Routes

Create `lib/config/routes.dart`:

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../presentation/auth/screens/login_screen.dart';
import '../presentation/admin/dashboard/admin_dashboard_screen.dart';
import '../presentation/landlord/dashboard/landlord_dashboard_screen.dart';
import '../presentation/tenant/dashboard/tenant_dashboard_screen.dart';

class AppRouter {
  static GoRouter router(UserModel? user) {
    return GoRouter(
      initialLocation: user == null ? '/login' : _getInitialRoute(user),
      routes: [
        // Auth routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        
        // Admin routes
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
          routes: [
            GoRoute(
              path: 'reports',
              builder: (context, state) => const AdminReportsScreen(),
            ),
            GoRoute(
              path: 'payment-approvals',
              builder: (context, state) => const PaymentApprovalsScreen(),
            ),
            GoRoute(
              path: 'tenant-management',
              builder: (context, state) => const TenantManagementScreen(),
            ),
          ],
        ),
        
        // Landlord routes
        GoRoute(
          path: '/landlord',
          builder: (context, state) => const LandlordDashboardScreen(),
          routes: [
            GoRoute(
              path: 'properties',
              builder: (context, state) => const PropertyListScreen(),
            ),
            GoRoute(
              path: 'tenants',
              builder: (context, state) => const TenantListScreen(),
            ),
            GoRoute(
              path: 'payments',
              builder: (context, state) => const PaymentListScreen(),
            ),
          ],
        ),
        
        // Tenant routes
        GoRoute(
          path: '/tenant',
          builder: (context, state) => const TenantDashboardScreen(),
          routes: [
            GoRoute(
              path: 'make-payment',
              builder: (context, state) => const MakePaymentScreen(),
            ),
            GoRoute(
              path: 'payment-history',
              builder: (context, state) => const PaymentHistoryScreen(),
            ),
            GoRoute(
              path: 'lease',
              builder: (context, state) => const LeaseDetailsScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = user != null;
        final isLoginRoute = state.location == '/login';
        
        if (!isLoggedIn && !isLoginRoute) {
          return '/login';
        }
        
        if (isLoggedIn && isLoginRoute) {
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
```

### 7.3 Bottom Navigation by Role

Create `lib/presentation/common/widgets/role_based_nav.dart`:

```dart
import 'package:flutter/material.dart';

class RoleBasedBottomNav extends StatelessWidget {
  final String role;
  final int currentIndex;
  final Function(int) onTap;

  const RoleBasedBottomNav({
    Key? key,
    required this.role,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  List<BottomNavigationBarItem> _getNavItems() {
    switch (role) {
      case 'admin':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.approval),
            label: 'Approvals',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Manage',
          ),
        ];
      
      case 'landlord':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Properties',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payments',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tenants',
          ),
        ];
      
      case 'tenant':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Pay Rent',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ];
      
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: _getNavItems(),
    );
  }
}
```

---

## 8. State Management

### 8.1 Provider Architecture

We'll use **Provider** for state management (you can adapt to Riverpod or Bloc):

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_config.dart';
import 'config/theme.dart';
import 'core/network/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/payment_repository.dart';
import 'data/repositories/property_repository.dart';
import 'presentation/auth/providers/auth_provider.dart';
import 'presentation/common/providers/payment_provider.dart';
import 'presentation/common/providers/property_provider.dart';
import 'config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClient();
  
  // Initialize repositories
  final authRepo = AuthRepository(apiClient, prefs);
  final paymentRepo = PaymentRepository(apiClient);
  final propertyRepo = PropertyRepository(apiClient);
  
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
          routerConfig: AppRouter.router(auth.user),
        );
      },
    );
  }
}
```

### 8.2 Creating Providers

Example Payment Provider (`lib/presentation/common/providers/payment_provider.dart`):

```dart
import 'package:flutter/foundation.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/repositories/payment_repository.dart';

enum PaymentStatus { initial, loading, loaded, error }

class PaymentProvider with ChangeNotifier {
  final PaymentRepository _repository;
  
  PaymentStatus _status = PaymentStatus.initial;
  List<PaymentModel> _payments = [];
  String? _error;
  
  PaymentProvider(this._repository);
  
  PaymentStatus get status => _status;
  List<PaymentModel> get payments => _payments;
  String? get error => _error;
  
  Future<void> fetchPayments() async {
    _status = PaymentStatus.loading;
    notifyListeners();
    
    try {
      _payments = await _repository.getPayments();
      _status = PaymentStatus.loaded;
      _error = null;
    } catch (e) {
      _status = PaymentStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }
  
  Future<bool> approvePayment(int paymentId) async {
    try {
      await _repository.verifyPayment(paymentId);
      await fetchPayments(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
```

---

## 9. UI Design Guidelines

### 9.1 Theme Configuration

Create `lib/config/theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const primaryColor = Color(0xFF2563EB);  // Blue
  static const secondaryColor = Color(0xFF10B981); // Green
  static const errorColor = Color(0xFFEF4444);     // Red
  static const warningColor = Color(0xFFF59E0B);   // Amber
  
  // Admin theme - Blue accent
  static const adminAccent = Color(0xFF3B82F6);
  
  // Landlord theme - Green accent
  static const landlordAccent = Color(0xFF10B981);
  
  // Tenant theme - Purple accent
  static const tenantAccent = Color(0xFF8B5CF6);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
  );
  
  // Role-specific color
  static Color getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return adminAccent;
      case 'landlord':
        return landlordAccent;
      case 'tenant':
        return tenantAccent;
      default:
        return primaryColor;
    }
  }
}
```

### 9.2 Dashboard Card Widgets

Different cards for different roles:

```dart
// Admin Dashboard Card
class AdminDashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  
  const AdminDashboardCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color ?? AppTheme.adminAccent),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (color ?? AppTheme.adminAccent).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color ?? AppTheme.adminAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 10. Secure API Communication

### 10.1 Token Management

Use **flutter_secure_storage** for sensitive data:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

### 10.2 SSL Pinning (Production)

For production, implement SSL certificate pinning:

```dart
// Add to pubspec.yaml:
// dependencies:
//   dio: ^5.4.0

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';

class SSLPinning {
  static Dio createDioWithPinning() {
    final dio = Dio();
    
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = 
        (HttpClient client) {
      client.badCertificateCallback = 
          (X509Certificate cert, String host, int port) {
        // Verify certificate fingerprint
        return cert.sha1.toString() == 'YOUR_CERT_SHA1_FINGERPRINT';
      };
      return client;
    };
    
    return dio;
  }
}
```

---

## 11. Error Handling and Offline Caching

### 11.1 Error Handling Strategy

```dart
class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout. Check your internet.';
        case DioExceptionType.receiveTimeout:
          return 'Server took too long to respond.';
        case DioExceptionType.badResponse:
          return _handleResponseError(error.response);
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          return 'Network error occurred.';
      }
    }
    return 'An unexpected error occurred.';
  }
  
  static String _handleResponseError(Response? response) {
    if (response == null) return 'Unknown error';
    
    switch (response.statusCode) {
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Server error. Try again later.';
      default:
        return response.data['message'] ?? 'Error occurred';
    }
  }
}
```

### 11.2 Offline Caching with Hive

```dart
import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static late Box _cacheBox;
  
  static Future<void> init() async {
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox('app_cache');
  }
  
  static Future<void> cacheData(String key, dynamic data) async {
    await _cacheBox.put(key, data);
  }
  
  static dynamic getCachedData(String key) {
    return _cacheBox.get(key);
  }
  
  static Future<void> clearCache() async {
    await _cacheBox.clear();
  }
}
```

---

## 12. Testing and Debugging

### 12.1 Unit Testing

Create `test/auth_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ApiClient, SharedPreferences])
void main() {
  group('AuthRepository Tests', () {
    test('login should return user and save token', () async {
      // Arrange
      final mockClient = MockApiClient();
      final mockPrefs = MockSharedPreferences();
      final repository = AuthRepository(mockClient, mockPrefs);
      
      // Act
      final user = await repository.login('test@test.com', 'password');
      
      // Assert
      expect(user.email, 'test@test.com');
      verify(mockPrefs.setString(any, any)).called(2);
    });
  });
}
```

### 12.2 Widget Testing

```dart
testWidgets('Login screen shows email and password fields', 
    (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(home: LoginScreen()),
  );
  
  expect(find.byType(TextFormField), findsNWidgets(2));
  expect(find.text('Email'), findsOneWidget);
  expect(find.text('Password'), findsOneWidget);
});
```

### 12.3 Integration Testing

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete login flow', (WidgetTester tester) async {
    // Start app
    await tester.pumpWidget(MyApp());
    
    // Enter credentials
    await tester.enterText(find.byKey(Key('email_field')), 'test@test.com');
    await tester.enterText(find.byKey(Key('password_field')), 'password');
    
    // Tap login
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pumpAndSettle();
    
    // Verify dashboard loads
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
```

Run tests:
```bash
flutter test
flutter test integration_test/app_test.dart
```

---

## 13. Deployment

### 13.1 Android Deployment

**Step 1: Configure App Signing**

Create `android/key.properties`:
```properties
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=rental-app
storeFile=<path_to_keystore>
```

Generate keystore:
```bash
keytool -genkey -v -keystore rental-app.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias rental-app
```

**Step 2: Update build.gradle**

Edit `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

**Step 3: Build APK/AAB**

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output locations:
# APK: build/app/outputs/flutter-apk/app-release.apk
# AAB: build/app/outputs/bundle/release/app-release.aab
```

**Step 4: Upload to Play Store**

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app
3. Upload app-release.aab
4. Fill in store listing, screenshots, etc.
5. Submit for review

### 13.2 iOS Deployment

**Step 1: Configure Xcode**

```bash
cd ios
pod install
open Runner.xcworkspace
```

In Xcode:
1. Select Runner > General
2. Update Bundle Identifier
3. Select Team
4. Configure Signing

**Step 2: Build IPA**

```bash
flutter build ios --release

# Or build with Xcode:
# Product > Archive
# Then distribute to App Store
```

**Step 3: Upload to App Store**

1. Open Xcode
2. Product > Archive
3. Window > Organizer
4. Select archive > Distribute App
5. App Store Connect
6. Upload

### 13.3 CI/CD with GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Build and Deploy

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk
```

---

## 14. Best Practices

### 14.1 Code Organization
- ✅ Follow Clean Architecture principles
- ✅ Separate UI, business logic, and data layers
- ✅ Use dependency injection
- ✅ Keep widgets small and focused
- ✅ Extract reusable components

### 14.2 Performance
- ✅ Use `const` constructors where possible
- ✅ Implement lazy loading for lists
- ✅ Cache network images
- ✅ Minimize rebuilds with proper state management
- ✅ Use `ListView.builder` for long lists

### 14.3 Security
- ✅ Store tokens in secure storage
- ✅ Implement SSL pinning in production
- ✅ Validate all user inputs
- ✅ Handle sensitive data carefully
- ✅ Implement proper error messages (don't expose internals)

### 14.4 User Experience
- ✅ Show loading indicators for async operations
- ✅ Implement pull-to-refresh
- ✅ Handle offline scenarios gracefully
- ✅ Provide meaningful error messages
- ✅ Use optimistic updates where appropriate

### 14.5 Testing
- ✅ Write unit tests for business logic
- ✅ Write widget tests for UI components
- ✅ Implement integration tests for critical flows
- ✅ Aim for >80% code coverage
- ✅ Test on multiple devices and OS versions

### 14.6 Maintenance
- ✅ Document complex logic
- ✅ Use meaningful variable and function names
- ✅ Follow Dart style guide
- ✅ Keep dependencies updated
- ✅ Monitor crash reports and analytics

---

## 📚 Additional Resources

### Official Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Laravel Sanctum](https://laravel.com/docs/sanctum)

### Recommended Packages
- **State Management:** `provider`, `flutter_riverpod`, `flutter_bloc`
- **Networking:** `dio`, `http`
- **Storage:** `hive`, `flutter_secure_storage`, `shared_preferences`
- **UI:** `flutter_svg`, `cached_network_image`, `shimmer`
- **Navigation:** `go_router`
- **Forms:** `flutter_form_builder`

### Learning Resources
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Dart Packages](https://pub.dev/)
- [Flutter Community](https://flutter.dev/community)

---

## 🎯 Next Steps

1. **Set up your development environment** following Section 2
2. **Create the Flutter project** following Section 3
3. **Implement authentication** following Section 6
4. **Build role-specific UI** following Sections 7-9
5. **Test thoroughly** following Section 12
6. **Deploy** following Section 13

For code examples and detailed implementations, refer to the supplementary files:
- `CODE_EXAMPLES.md` - Complete code snippets
- `API_INTEGRATION.md` - Detailed API integration guide
- `UI_COMPONENTS.md` - Reusable UI components

---

**Document Version:** 1.0.0  
**Last Updated:** October 2025  
**Author:** Technical Documentation Team  
**Support:** For questions, open an issue in the repository

