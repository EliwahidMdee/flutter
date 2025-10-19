# Flutter Project Folder Structure Template

This document provides a ready-to-use folder structure for the Rental Management mobile app.

## Complete Directory Tree

```
rental_management_app/
├── android/                              # Android platform code
│   ├── app/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── AndroidManifest.xml
│   │   │       ├── kotlin/
│   │   │       └── res/
│   │   └── build.gradle
│   ├── gradle/
│   └── build.gradle
│
├── ios/                                  # iOS platform code
│   ├── Runner/
│   │   ├── Info.plist
│   │   └── Assets.xcassets/
│   ├── Runner.xcodeproj/
│   └── Runner.xcworkspace/
│
├── lib/                                  # Main application code
│   ├── main.dart                        # App entry point
│   │
│   ├── config/                          # Configuration
│   │   ├── app_config.dart             # Environment & API configs
│   │   ├── routes.dart                 # Route definitions
│   │   └── theme.dart                  # Theme configuration
│   │
│   ├── core/                            # Core utilities
│   │   ├── constants/
│   │   │   ├── api_constants.dart      # API endpoints
│   │   │   ├── app_constants.dart      # App-wide constants
│   │   │   └── storage_keys.dart       # Storage key names
│   │   │
│   │   ├── errors/
│   │   │   ├── exceptions.dart         # Custom exceptions
│   │   │   └── failures.dart           # Failure types
│   │   │
│   │   ├── network/
│   │   │   ├── api_client.dart         # Dio HTTP client
│   │   │   ├── interceptors.dart       # Request/response interceptors
│   │   │   └── network_info.dart       # Connectivity checker
│   │   │
│   │   ├── storage/
│   │   │   ├── local_storage.dart      # SharedPreferences wrapper
│   │   │   └── secure_storage.dart     # FlutterSecureStorage wrapper
│   │   │
│   │   └── utils/
│   │       ├── validators.dart         # Form validators
│   │       ├── formatters.dart         # Data formatters
│   │       ├── logger.dart             # Logger utility
│   │       └── date_utils.dart         # Date utilities
│   │
│   ├── data/                            # Data layer
│   │   ├── models/                      # Data models
│   │   │   ├── user_model.dart
│   │   │   ├── user_model.g.dart       # Generated JSON serialization
│   │   │   ├── property_model.dart
│   │   │   ├── property_model.g.dart
│   │   │   ├── payment_model.dart
│   │   │   ├── payment_model.g.dart
│   │   │   ├── tenant_model.dart
│   │   │   ├── lease_model.dart
│   │   │   ├── notification_model.dart
│   │   │   └── report_model.dart
│   │   │
│   │   ├── repositories/                # Repository implementations
│   │   │   ├── auth_repository.dart
│   │   │   ├── property_repository.dart
│   │   │   ├── payment_repository.dart
│   │   │   ├── tenant_repository.dart
│   │   │   ├── notification_repository.dart
│   │   │   └── report_repository.dart
│   │   │
│   │   └── datasources/                 # Data sources
│   │       ├── remote/                  # API data sources
│   │       │   ├── auth_remote_datasource.dart
│   │       │   ├── property_remote_datasource.dart
│   │       │   ├── payment_remote_datasource.dart
│   │       │   └── tenant_remote_datasource.dart
│   │       └── local/                   # Local cache
│   │           ├── auth_local_datasource.dart
│   │           └── cache_datasource.dart
│   │
│   ├── presentation/                    # UI layer
│   │   ├── common/                      # Shared components
│   │   │   ├── widgets/
│   │   │   │   ├── custom_app_bar.dart
│   │   │   │   ├── custom_button.dart
│   │   │   │   ├── custom_text_field.dart
│   │   │   │   ├── loading_indicator.dart
│   │   │   │   ├── error_widget.dart
│   │   │   │   ├── empty_state_widget.dart
│   │   │   │   ├── dashboard_card.dart
│   │   │   │   └── role_based_nav.dart
│   │   │   ├── dialogs/
│   │   │   │   ├── confirmation_dialog.dart
│   │   │   │   ├── error_dialog.dart
│   │   │   │   └── loading_dialog.dart
│   │   │   └── providers/
│   │   │       ├── dashboard_provider.dart
│   │   │       ├── payment_provider.dart
│   │   │       └── property_provider.dart
│   │   │
│   │   ├── auth/                        # Authentication
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── forgot_password_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── login_form.dart
│   │   │   │   └── password_field.dart
│   │   │   └── providers/
│   │   │       └── auth_provider.dart
│   │   │
│   │   ├── admin/                       # Admin role
│   │   │   ├── dashboard/
│   │   │   │   ├── admin_dashboard_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── admin_stats_card.dart
│   │   │   │       └── activity_list.dart
│   │   │   ├── reports/
│   │   │   │   ├── financial_report_screen.dart
│   │   │   │   ├── tenant_report_screen.dart
│   │   │   │   ├── property_report_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── report_chart.dart
│   │   │   │       └── report_filter.dart
│   │   │   ├── payments/
│   │   │   │   ├── payment_approval_screen.dart
│   │   │   │   ├── payment_detail_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── payment_approval_card.dart
│   │   │   │       └── approval_actions.dart
│   │   │   └── management/
│   │   │       ├── tenant_management_screen.dart
│   │   │       ├── landlord_management_screen.dart
│   │   │       └── widgets/
│   │   │           └── user_list_item.dart
│   │   │
│   │   ├── landlord/                    # Landlord role
│   │   │   ├── dashboard/
│   │   │   │   ├── landlord_dashboard_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── property_overview_card.dart
│   │   │   │       └── revenue_chart.dart
│   │   │   ├── properties/
│   │   │   │   ├── property_list_screen.dart
│   │   │   │   ├── property_detail_screen.dart
│   │   │   │   ├── add_property_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── property_card.dart
│   │   │   │       └── property_form.dart
│   │   │   ├── payments/
│   │   │   │   ├── payment_list_screen.dart
│   │   │   │   ├── payment_request_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── payment_list_item.dart
│   │   │   └── tenants/
│   │   │       ├── tenant_list_screen.dart
│   │   │       ├── tenant_detail_screen.dart
│   │   │       └── widgets/
│   │   │           └── tenant_card.dart
│   │   │
│   │   └── tenant/                      # Tenant role
│   │       ├── dashboard/
│   │       │   ├── tenant_dashboard_screen.dart
│   │       │   └── widgets/
│   │       │       ├── rent_status_card.dart
│   │       │       └── quick_actions.dart
│   │       ├── payments/
│   │       │   ├── make_payment_screen.dart
│   │       │   ├── payment_history_screen.dart
│   │       │   ├── receipt_screen.dart
│   │       │   └── widgets/
│   │       │       ├── payment_form.dart
│   │       │       └── payment_history_item.dart
│   │       ├── lease/
│   │       │   ├── lease_detail_screen.dart
│   │       │   └── widgets/
│   │       │       └── lease_info_card.dart
│   │       └── notifications/
│   │           ├── notification_list_screen.dart
│   │           └── widgets/
│   │               └── notification_item.dart
│   │
│   └── services/                        # Services
│       ├── notification_service.dart    # Push notifications
│       ├── cache_service.dart          # Caching service
│       └── background_service.dart     # Background tasks
│
├── test/                                # Unit & Widget tests
│   ├── core/
│   │   ├── network/
│   │   │   └── api_client_test.dart
│   │   └── utils/
│   │       └── validators_test.dart
│   ├── data/
│   │   ├── models/
│   │   │   └── user_model_test.dart
│   │   └── repositories/
│   │       └── auth_repository_test.dart
│   ├── presentation/
│   │   ├── auth/
│   │   │   └── providers/
│   │   │       └── auth_provider_test.dart
│   │   └── widgets/
│   │       └── dashboard_card_test.dart
│   └── widget_test.dart
│
├── integration_test/                    # Integration tests
│   ├── app_test.dart
│   ├── login_flow_test.dart
│   └── payment_flow_test.dart
│
├── assets/                              # Assets
│   ├── images/
│   │   ├── logo.png
│   │   ├── placeholder.png
│   │   └── splash.png
│   ├── icons/
│   │   ├── ic_property.svg
│   │   ├── ic_payment.svg
│   │   └── ic_tenant.svg
│   └── fonts/
│       └── (optional custom fonts)
│
├── .gitignore                          # Git ignore file
├── .metadata                           # Flutter metadata
├── analysis_options.yaml               # Dart analysis options
├── pubspec.yaml                        # Dependencies
├── pubspec.lock                        # Locked dependencies
└── README.md                           # Project README
```

## Creating the Structure

### Using Command Line (Linux/macOS)

```bash
# Navigate to your project
cd rental_management_app

# Create all directories
mkdir -p lib/{config,core/{constants,errors,network,storage,utils},data/{models,repositories,datasources/{remote,local}},presentation/{common/{widgets,dialogs,providers},auth/{screens,widgets,providers},admin/{dashboard/{widgets},reports/{widgets},payments/{widgets},management/{widgets}},landlord/{dashboard/{widgets},properties/{widgets},payments/{widgets},tenants/{widgets}},tenant/{dashboard/{widgets},payments/{widgets},lease/{widgets},notifications/{widgets}}},services}

# Create test directories
mkdir -p test/{core/{network,utils},data/{models,repositories},presentation/{auth/providers,widgets}}
mkdir -p integration_test

# Create asset directories
mkdir -p assets/{images,icons,fonts}

# Create initial files
touch lib/config/{app_config,routes,theme}.dart
touch lib/core/constants/{api_constants,app_constants,storage_keys}.dart
touch lib/core/network/{api_client,interceptors,network_info}.dart
touch lib/core/utils/{validators,formatters,logger,date_utils}.dart
```

### Using Command Line (Windows PowerShell)

```powershell
# Navigate to your project
cd rental_management_app

# Create main lib structure
New-Item -ItemType Directory -Force -Path lib\config, lib\core\constants, lib\core\errors, lib\core\network, lib\core\storage, lib\core\utils

# Create data layer
New-Item -ItemType Directory -Force -Path lib\data\models, lib\data\repositories, lib\data\datasources\remote, lib\data\datasources\local

# Create presentation layer
New-Item -ItemType Directory -Force -Path lib\presentation\common\widgets, lib\presentation\common\dialogs, lib\presentation\common\providers
New-Item -ItemType Directory -Force -Path lib\presentation\auth\screens, lib\presentation\auth\widgets, lib\presentation\auth\providers

# Create role-specific directories
New-Item -ItemType Directory -Force -Path lib\presentation\admin\dashboard\widgets, lib\presentation\admin\reports\widgets, lib\presentation\admin\payments\widgets, lib\presentation\admin\management\widgets

New-Item -ItemType Directory -Force -Path lib\presentation\landlord\dashboard\widgets, lib\presentation\landlord\properties\widgets, lib\presentation\landlord\payments\widgets, lib\presentation\landlord\tenants\widgets

New-Item -ItemType Directory -Force -Path lib\presentation\tenant\dashboard\widgets, lib\presentation\tenant\payments\widgets, lib\presentation\tenant\lease\widgets, lib\presentation\tenant\notifications\widgets

# Create services
New-Item -ItemType Directory -Force -Path lib\services

# Create test directories
New-Item -ItemType Directory -Force -Path test\core\network, test\core\utils, test\data\models, test\data\repositories, test\presentation\auth\providers, test\presentation\widgets

# Create integration test
New-Item -ItemType Directory -Force -Path integration_test

# Create assets
New-Item -ItemType Directory -Force -Path assets\images, assets\icons, assets\fonts
```

## File Naming Conventions

Follow these naming conventions for consistency:

### Dart Files
- **Screens:** `*_screen.dart` (e.g., `login_screen.dart`)
- **Widgets:** `*_widget.dart` or descriptive name (e.g., `custom_button.dart`)
- **Providers:** `*_provider.dart` (e.g., `auth_provider.dart`)
- **Models:** `*_model.dart` (e.g., `user_model.dart`)
- **Repositories:** `*_repository.dart` (e.g., `auth_repository.dart`)
- **Services:** `*_service.dart` (e.g., `notification_service.dart`)
- **Constants:** `*_constants.dart` (e.g., `api_constants.dart`)

### Test Files
- Unit tests: `*_test.dart` (matching the source file)
- Widget tests: `*_test.dart`
- Integration tests: `*_test.dart` in `integration_test/` folder

## Recommended VS Code Workspace Settings

Create `.vscode/settings.json`:

```json
{
  "dart.lineLength": 100,
  "editor.rulers": [80, 100],
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "files.exclude": {
    "**/.dart_tool": true,
    "**/.packages": true,
    "**/build": true,
    "**/*.g.dart": true,
    "**/*.freezed.dart": true
  },
  "search.exclude": {
    "**/build": true,
    "**/.dart_tool": true,
    "**/*.g.dart": true
  }
}
```

## Git Configuration

Update `.gitignore`:

```gitignore
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# VSCode
.vscode/

# Flutter/Dart/Pub related
**/doc/api/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
*.g.dart
*.freezed.dart

# Android related
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.java

# iOS/XCode related
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# Coverage
coverage/

# Exceptions
!/packages/flutter_tools/test/data/dart_dependencies_test/**/.packages
```

## Quick Start After Creating Structure

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run code generation:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Verify setup:**
   ```bash
   flutter doctor
   flutter analyze
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

This structure is designed to scale with your application while maintaining organization and separation of concerns.

