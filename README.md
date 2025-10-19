# Flutter Mobile App Documentation

This directory contains comprehensive documentation for building a Flutter mobile application for the Rental Management System.

## 📚 Documentation Files

### 🚀 Quick Start Guide
**[QUICK_START.md](./QUICK_START.md)**
- **Start here** for rapid setup (30 minutes)
- Fast-track guide to get app running
- Essential steps only
- Perfect for getting started quickly

### 📖 Main Guide
**[FLUTTER_APP_DEVELOPMENT_GUIDE.md](./FLUTTER_APP_DEVELOPMENT_GUIDE.md)**
- Comprehensive step-by-step guide
- Covers all aspects from setup to deployment
- Includes architecture overview and best practices
- In-depth explanations and detailed instructions

### 🏗️ Architecture Diagrams
**[ARCHITECTURE_DIAGRAM.md](./ARCHITECTURE_DIAGRAM.md)**
- Visual representations of system architecture
- Data flow diagrams
- Component relationship diagrams
- Authentication and payment flows
- Role-based navigation structures

### 💻 Code Examples
**[CODE_EXAMPLES.md](./CODE_EXAMPLES.md)**
- Ready-to-use code snippets and implementations
- Complete examples for API clients, models, repositories
- Provider implementations with state management
- Screen examples for all user roles (Admin, Landlord, Tenant)
- Reusable widget components
- Utility functions and helpers

### 📁 Project Structure
**[FOLDER_STRUCTURE_TEMPLATE.md](./FOLDER_STRUCTURE_TEMPLATE.md)**
- Complete directory structure template
- File naming conventions
- Instructions for creating the folder structure
- IDE configuration recommendations
- Git configuration

## 🎯 Getting Started

Choose your path based on your time and experience:

### ⚡ Fast Path (30 minutes)
1. **Follow Quick Start** - [QUICK_START.md](./QUICK_START.md)
2. Get a basic app running with login screen
3. Perfect for rapid prototyping

### 📚 Comprehensive Path (1-2 weeks)
1. **Read the main guide** - [FLUTTER_APP_DEVELOPMENT_GUIDE.md](./FLUTTER_APP_DEVELOPMENT_GUIDE.md)
2. **Understand architecture** - [ARCHITECTURE_DIAGRAM.md](./ARCHITECTURE_DIAGRAM.md)
3. **Set up project structure** - [FOLDER_STRUCTURE_TEMPLATE.md](./FOLDER_STRUCTURE_TEMPLATE.md)
4. **Implement features** - Use [CODE_EXAMPLES.md](./CODE_EXAMPLES.md) for code snippets
5. **Build, test, and deploy** - Follow Sections 12-13 of main guide

## 📋 What You'll Build

A complete mobile application with:

### For Admin Users
- Comprehensive dashboard with system-wide metrics
- Financial and operational reports
- Payment approval workflow
- Tenant and landlord management
- System-wide notifications

### For Landlord Users
- Property management dashboard
- Tenant listing and details
- Payment tracking and requests
- Property-specific reports
- Revenue analytics

### For Tenant Users
- Rent status overview
- Payment submission
- Payment history and receipts
- Lease information
- Notifications from landlords

## 🏗️ Architecture

The mobile app follows **Clean Architecture** principles:

```
┌──────────────────────┐
│  Presentation Layer  │  ← Screens, Widgets, State Management
├──────────────────────┤
│  Business Logic      │  ← Use Cases, Business Rules
├──────────────────────┤
│  Data Layer          │  ← API Client, Repositories, Models
└──────────────────────┘
```

## 🔑 Key Technologies

- **Frontend:** Flutter 3.x / Dart
- **Backend API:** Laravel (existing)
- **Authentication:** Laravel Sanctum (token-based)
- **State Management:** Provider (recommended), or Riverpod/Bloc
- **Local Storage:** Hive + Flutter Secure Storage
- **Networking:** Dio HTTP client
- **Routing:** GoRouter

## 📦 Main Dependencies

```yaml
# Core
flutter
provider                    # State management

# Networking
dio                         # HTTP client
connectivity_plus           # Network status

# Storage
shared_preferences          # Simple storage
flutter_secure_storage      # Secure token storage
hive                        # Local database

# UI
google_fonts                # Custom fonts
cached_network_image        # Image caching
fl_chart                    # Charts for reports

# Forms & Validation
flutter_form_builder        # Form building
form_builder_validators     # Validation

# Utilities
intl                        # Internationalization & formatting
logger                      # Logging
```

## 🎨 UI Design Principles

### Role-Based Theming
Each user role has distinct visual identity:
- **Admin:** Blue accent - authority and control
- **Landlord:** Green accent - growth and prosperity
- **Tenant:** Purple accent - comfort and service

### Responsive Design
- Adapts to different screen sizes
- Supports portrait and landscape orientations
- Touch-friendly UI elements

### Accessibility
- High contrast colors
- Large touch targets
- Screen reader support
- Clear labels and hints

## 🔒 Security Features

- **Token-based authentication** using Laravel Sanctum
- **Secure storage** for sensitive data (tokens, user info)
- **SSL/TLS** communication with backend
- **Input validation** on all forms
- **Role-based access control** enforced on both frontend and backend
- **Auto logout** on token expiration

## 🧪 Testing Strategy

### Unit Tests
- Test business logic in providers
- Test utility functions
- Test data models

### Widget Tests
- Test individual widgets
- Test screen layouts
- Test user interactions

### Integration Tests
- Test complete user flows
- Test authentication flow
- Test payment workflows

## 📱 Platform Support

- **Android:** API 21+ (Android 5.0 Lollipop and above)
- **iOS:** iOS 12+ (iPhone 5s and above)

## 🚀 Deployment

### Android
- Build APK for testing
- Build App Bundle (AAB) for Google Play Store
- Configure ProGuard for code optimization
- Set up signing configuration

### iOS
- Build IPA for App Store
- Configure provisioning profiles
- Submit via App Store Connect
- TestFlight for beta testing

## 📖 Learning Path

### Beginner Path
1. ✅ Read the main guide sections 1-4
2. ✅ Set up development environment
3. ✅ Create basic project structure
4. ✅ Implement authentication (Section 6)
5. ✅ Build one role's dashboard
6. ✅ Deploy to device for testing

### Intermediate Path
1. ✅ Complete beginner path
2. ✅ Implement all role-based screens
3. ✅ Add state management (Section 8)
4. ✅ Implement offline caching (Section 11)
5. ✅ Add error handling
6. ✅ Write unit tests

### Advanced Path
1. ✅ Complete intermediate path
2. ✅ Optimize performance
3. ✅ Implement advanced features (push notifications, etc.)
4. ✅ Write integration tests
5. ✅ Set up CI/CD
6. ✅ Deploy to production

## 🆘 Troubleshooting

### Common Issues

**Issue:** `flutter doctor` shows errors
- **Solution:** Follow the specific error messages and install missing components

**Issue:** API calls return 401 Unauthorized
- **Solution:** Check token storage, ensure token is being sent in headers

**Issue:** Unable to connect to local backend
- **Solution:** 
  - Android Emulator: Use `http://10.0.2.2:8000/api`
  - iOS Simulator: Use `http://localhost:8000/api`
  - Physical devices: Use your computer's local IP

**Issue:** Build errors after adding dependencies
- **Solution:** Run `flutter pub get` and `flutter clean`, then rebuild

**Issue:** Hot reload not working
- **Solution:** Try hot restart (Shift+R) or full restart

## 🤝 Contributing

If you make improvements to this documentation:
1. Update the relevant file
2. Update this README if adding new files
3. Keep code examples tested and working
4. Follow the existing documentation style

## 📞 Support

For questions or issues:
1. Check the troubleshooting section
2. Review Flutter documentation: https://docs.flutter.dev
3. Check Laravel Sanctum docs: https://laravel.com/docs/sanctum
4. Open an issue in the repository

## 📅 Version History

- **v1.0.0** (October 2025) - Initial comprehensive guide
  - Complete development guide
  - Code examples and templates
  - Folder structure template

## 📄 License

This documentation is part of the Rental Management System project and follows the same license as the main project.

---

**Last Updated:** October 2025
**Maintained By:** Development Team

For the latest version of this documentation, visit the repository.

