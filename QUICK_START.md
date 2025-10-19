# Quick Start Guide - Flutter Rental Management App

Get your Flutter mobile app up and running in minutes!

## ⚡ Fast Track (30 minutes)

### 1. Prerequisites Check (5 min)

```bash
# Verify Flutter installation
flutter doctor

# Expected output: All checks should pass ✓
# [✓] Flutter (Channel stable, 3.x.x)
# [✓] Android toolchain
# [✓] Chrome
# [✓] Android Studio / VS Code
```

### 2. Create Project (2 min)

```bash
# Create Flutter project
flutter create rental_management_app
cd rental_management_app

# Open in IDE
code .  # VS Code
# or
open -a "Android Studio" .  # macOS
```

### 3. Add Dependencies (3 min)

Replace `pubspec.yaml` dependencies section:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Essential packages
  provider: ^6.1.1              # State management
  dio: ^5.4.0                   # HTTP client
  go_router: ^12.1.3            # Navigation
  shared_preferences: ^2.2.2    # Storage
  flutter_secure_storage: ^9.0.0 # Secure storage
  
  # UI packages
  google_fonts: ^6.1.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  
  # Utilities
  intl: ^0.19.0
  logger: ^2.0.2+1
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

Install:
```bash
flutter pub get
```

### 4. Create Basic Structure (5 min)

```bash
# Create directories
mkdir -p lib/{config,core/{constants,network,utils},data/{models,repositories},presentation/{auth/{screens,providers},common/widgets}}

# Create config files
cat > lib/config/app_config.dart << 'DART'
class AppConfig {
  static const String apiBaseUrl = 'https://your-api-url.com/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
DART
```

### 5. Create API Client (5 min)

```bash
cat > lib/core/network/api_client.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/app_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  
  late Dio _dio;
  final _storage = const FlutterSecureStorage();
  
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.connectTimeout,
      headers: {'Content-Type': 'application/json'},
    ));
  }
  
  Dio get dio => _dio;
  
  Future<void> setToken(String token) async {
    await _storage.write(key: AppConfig.tokenKey, value: token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
}
DART
```

### 6. Create Login Screen (10 min)

```bash
cat > lib/presentation/auth/screens/login_screen.dart << 'DART'
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_work, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              Text('Rental Management',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement login
                  },
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
DART
```

Update `lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'presentation/auth/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rental Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
```

### 7. Run the App! 🚀

```bash
# Run on connected device
flutter run

# Or specify device
flutter devices
flutter run -d <device-id>
```

You should now see a working login screen!

---

## 🎯 Next Steps

Now that you have a basic app running:

### Week 1: Authentication
- [ ] Implement auth provider with Provider package
- [ ] Connect login to Laravel API
- [ ] Add token storage
- [ ] Create user model with role support
- [ ] Implement role-based routing

**Reference:** Main guide Section 6

### Week 2: Dashboard
- [ ] Create admin dashboard
- [ ] Create landlord dashboard
- [ ] Create tenant dashboard
- [ ] Add dashboard cards and metrics
- [ ] Connect to dashboard API

**Reference:** Main guide Section 7, 9

### Week 3: Core Features
- [ ] Implement payment listing
- [ ] Create payment approval flow (Admin/Landlord)
- [ ] Add make payment screen (Tenant)
- [ ] Implement property management
- [ ] Add notifications

**Reference:** CODE_EXAMPLES.md

### Week 4: Polish & Deploy
- [ ] Add error handling
- [ ] Implement offline caching
- [ ] Write tests
- [ ] Build and sign APK/AAB
- [ ] Deploy to Play Store

**Reference:** Main guide Sections 11-13

---

## 🛠️ Development Tips

### Hot Reload
Save files to hot reload (r in terminal or ⌘S in IDE)

### Debug Mode
- Add breakpoints in IDE
- Use `print()` or `debugPrint()` for logging
- Check Flutter DevTools

### Common Commands
```bash
flutter clean           # Clean build cache
flutter pub get         # Install dependencies
flutter pub upgrade     # Upgrade packages
flutter doctor -v       # Detailed doctor check
flutter devices         # List connected devices
flutter logs            # View device logs
```

### Useful VS Code Extensions
- Flutter
- Dart
- Flutter Widget Snippets
- Awesome Flutter Snippets
- Pubspec Assist

---

## 📚 Learning Resources

### Official Docs
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Codelabs](https://docs.flutter.dev/codelabs)

### Video Tutorials
- Flutter Official YouTube Channel
- The Net Ninja - Flutter Tutorial
- Academind - Flutter & Dart Course

### Community
- [Flutter Dev Discord](https://discord.gg/flutter)
- [r/FlutterDev](https://reddit.com/r/flutterdev)
- [Stack Overflow - Flutter Tag](https://stackoverflow.com/questions/tagged/flutter)

---

## ⚠️ Troubleshooting

### Issue: "flutter not found"
```bash
# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

### Issue: Android licenses not accepted
```bash
flutter doctor --android-licenses
```

### Issue: iOS setup issues (macOS)
```bash
sudo gem install cocoapods
cd ios && pod install
```

### Issue: Gradle build fails
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Issue: Can't connect to API
- Check API URL in `app_config.dart`
- Use `http://10.0.2.2:8000/api` for Android Emulator
- Use `http://localhost:8000/api` for iOS Simulator
- Use your computer's IP for physical devices

---

## 🎉 Success Checklist

After completing this quick start, you should have:

- ✅ Working Flutter development environment
- ✅ Project created with correct structure
- ✅ Dependencies installed
- ✅ API client configured
- ✅ Basic login screen running
- ✅ App running on device/emulator

**Congratulations!** You're ready to build the full application.

Refer to the main guide for detailed implementation: [FLUTTER_APP_DEVELOPMENT_GUIDE.md](./FLUTTER_APP_DEVELOPMENT_GUIDE.md)

