# Flutter Rental Property Management App

A complete, production-ready Flutter mobile application for rental property management with role-based access control.

## Features

### 🔐 **User Authentication**
- JWT-based login with Laravel Sanctum backend
- Role-based access (Admin, Landlord, Tenant)
- Secure token storage using `flutter_secure_storage`
- Auto-login functionality

### 👔 **Admin Features**
- Comprehensive dashboard with real-time statistics
- Financial, tenant activity, and property performance reports
- Payment approval workflow
- Tenant and landlord management
- System-wide notifications

### 🏠 **Landlord Features**
- Property management (CRUD operations)
- Tenant listing and details
- Payment tracking and requests
- Revenue and occupancy analytics
- Direct communication with tenants via notifications

### 🏡 **Tenant Features**
- View rent status and payment history
- Make payments with multiple payment methods
- Access lease information
- Receive and respond to notifications from landlords
- Download payment receipts

### 📲 **Notification System**
- Real-time notification updates
- Read/unread status tracking
- **Two-way communication** - Tenants can respond to landlord notifications
- Notification history with responses
- Push notification support

## Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── config/          # App configuration (routes, theme, API)
├── core/            # Core utilities (networking, storage, validation)
├── data/            # Data layer (models, repositories)
└── presentation/    # UI layer (screens, widgets, providers)
```

### State Management
- Provider for state management
- Separate providers for Auth, Payments, Properties, Dashboard, and Notifications

### Networking
- Dio HTTP client with interceptors
- Automatic token injection
- Error handling and retry logic

### Local Storage
- Hive for offline caching
- Flutter Secure Storage for sensitive data
- SharedPreferences for user preferences

## Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio or VS Code
- Laravel backend API

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/EliwahidMdee/flutter.git
   cd flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure API**
   - Update `lib/config/app_config.dart` with your Laravel backend URL
   - For Android emulator, use `http://10.0.2.2:8000/api`
   - For iOS simulator, use `http://localhost:8000/api`
   - For physical devices, use your computer's IP address

5. **Run the app**
   ```bash
   flutter run
   ```

## Demo Credentials

The app includes demo credential suggestions on the login screen:

- **Admin:** admin@example.com / password
- **Landlord:** landlord@example.com / password
- **Tenant:** tenant@example.com / password

## Project Structure

```
rental_management_app/
├── lib/
│   ├── config/                  # App configuration
│   ├── core/                    # Core utilities
│   │   ├── constants/           # API endpoints, app constants
│   │   ├── network/             # API client, interceptors
│   │   └── utils/               # Validators, formatters, logger
│   ├── data/                    # Data layer
│   │   ├── models/              # Data models with JSON serialization
│   │   └── repositories/        # Repository implementations
│   └── presentation/            # UI layer
│       ├── auth/                # Authentication screens
│       ├── admin/               # Admin role screens
│       ├── landlord/            # Landlord role screens
│       ├── tenant/              # Tenant role screens
│       └── common/              # Shared widgets and providers
├── assets/                      # Images, icons, fonts
├── test/                        # Unit tests
├── integration_test/            # Integration tests
└── pubspec.yaml                 # Dependencies
```

## Key Dependencies

- **provider**: State management
- **dio**: HTTP client
- **go_router**: Navigation and routing
- **flutter_secure_storage**: Secure token storage
- **hive**: Local caching
- **google_fonts**: Typography
- **intl**: Internationalization and formatting
- **fl_chart**: Charts for reports

## API Integration

The app connects to a Laravel backend with Sanctum authentication. Key endpoints:

- `POST /api/login` - User authentication
- `GET /api/dashboard` - Dashboard statistics
- `GET /api/payments` - List payments
- `POST /api/payments` - Create payment
- `POST /api/payments/{id}/verify` - Approve payment
- `GET /api/notifications` - List notifications
- `POST /api/notifications/{id}/respond` - Respond to notification

## Testing

Run unit tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test/app_test.dart
```

## Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Features Implemented

- [x] JWT Authentication with role-based access
- [x] Admin dashboard with statistics
- [x] Landlord property management
- [x] Tenant payment system
- [x] Payment approval workflow
- [x] Notification system with responses
- [x] Profile and settings screens
- [x] Offline caching
- [x] Error handling
- [x] Material 3 design
- [x] Role-specific navigation
- [x] Pull-to-refresh functionality
- [x] Loading and error states

## Documentation

See the detailed documentation files:
- `FLUTTER_APP_DEVELOPMENT_GUIDE.md` - Complete development guide
- `ARCHITECTURE_DIAGRAM.md` - Visual system design
- `CODE_EXAMPLES.md` - Code snippets and examples
- `FOLDER_STRUCTURE_TEMPLATE.md` - Project organization
- `DEVELOPMENT_CHECKLIST.md` - Task tracking
- `QUICK_START.md` - Fast-track setup

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- Open an issue in the repository
- Check the documentation files
- Review the code examples

## Contributors

Built with ❤️ by the development team following all Flutter and Dart best practices.
