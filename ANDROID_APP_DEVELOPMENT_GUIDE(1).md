# Complete Android Application Development Guide
## Rental Management System - Mobile Version

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Prerequisites](#prerequisites)
4. [Backend API Development](#backend-api-development)
5. [Android App Architecture](#android-app-architecture)
6. [Step-by-Step Implementation Workflow](#step-by-step-implementation-workflow)
7. [Authentication & Data Synchronization](#authentication--data-synchronization)
8. [UI/UX Design Guidelines](#uiux-design-guidelines)
9. [Database & Local Storage](#database--local-storage)
10. [Testing Strategy](#testing-strategy)
11. [Security Considerations](#security-considerations)
12. [Build & Deployment](#build--deployment)
13. [Maintenance & Updates](#maintenance--updates)

---

## 📱 Project Overview

### Current System
The Rental Management System is a **Laravel 12-based web application** that manages:
- Properties (traditional rentals and Airbnb short-term rentals)
- Tenants and Leases
- Payments and Expenses
- Reservations with multi-currency support
- Financial reports and analytics
- User roles (Admin, Landlord, Tenant)

### Mobile App Goals
Create a **native Android application** that:
- ✅ Provides full feature parity with the web application
- ✅ Ensures data consistency between mobile and web platforms
- ✅ Matches the web application's design aesthetics and user experience
- ✅ Supports offline mode with automatic synchronization
- ✅ Delivers push notifications for important events
- ✅ Optimizes mobile user interactions and performance

### Target Users
1. **Property Owners/Landlords**: Manage properties, view analytics, approve payments
2. **Tenants**: View lease details, make payments, submit maintenance requests
3. **Administrators**: Full system management and oversight
4. **Airbnb Guests**: Browse properties, make reservations

---

## 🛠 Technology Stack

### Backend (Existing Laravel System)

#### Framework & Core
- **Laravel 12.x** (PHP 8.2+)
- **MySQL/MariaDB** for database
- **Laravel Breeze** for authentication
- **Spatie Laravel Permission** for role-based access control

#### Additional Packages
- `barryvdh/laravel-dompdf` - PDF generation
- `maatwebsite/excel` - Excel export functionality
- **Sanctum** - API token authentication (to be added)

### Android Application

#### Core Framework
- **Language**: Kotlin 1.9+
- **Minimum SDK**: API 24 (Android 7.0)
- **Target SDK**: API 34 (Android 14)
- **Build System**: Gradle 8.x with Kotlin DSL

#### Architecture Components
```kotlin
// Android Jetpack Components
implementation("androidx.core:core-ktx:1.12.0")
implementation("androidx.appcompat:appcompat:1.6.1")
implementation("androidx.activity:activity-ktx:1.8.2")
implementation("androidx.fragment:fragment-ktx:1.6.2")

// Jetpack Compose for Modern UI
implementation("androidx.compose.ui:ui:1.6.0")
implementation("androidx.compose.material3:material3:1.2.0")
implementation("androidx.compose.ui:ui-tooling-preview:1.6.0")
implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")
implementation("androidx.navigation:navigation-compose:2.7.6")

// Architecture Components
implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.7.0")
implementation("androidx.lifecycle:lifecycle-livedata-ktx:2.7.0")

// Room Database for local storage
implementation("androidx.room:room-runtime:2.6.1")
implementation("androidx.room:room-ktx:2.6.1")
kapt("androidx.room:room-compiler:2.6.1")

// Retrofit for API calls
implementation("com.squareup.retrofit2:retrofit:2.9.0")
implementation("com.squareup.retrofit2:converter-gson:2.9.0")
implementation("com.squareup.okhttp3:okhttp:4.12.0")
implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")

// Coroutines for async operations
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")

// Dependency Injection - Hilt
implementation("com.google.dagger:hilt-android:2.50")
kapt("com.google.dagger:hilt-compiler:2.50")

// Image Loading - Coil for Compose
implementation("io.coil-kt:coil-compose:2.5.0")

// DataStore for preferences
implementation("androidx.datastore:datastore-preferences:1.0.0")

// Work Manager for background sync
implementation("androidx.work:work-runtime-ktx:2.9.0")

// Firebase for push notifications (optional)
implementation("com.google.firebase:firebase-messaging:23.4.0")

// Material Design Components
implementation("com.google.android.material:material:1.11.0")

// Gson for JSON parsing
implementation("com.google.code.gson:gson:2.10.1")

// Date/Time handling
implementation("org.jetbrains.kotlinx:kotlinx-datetime:0.5.0")

// Chart library for analytics
implementation("com.github.PhilJay:MPAndroidChart:v3.1.0")

// PDF Viewer (for documents)
implementation("com.github.barteksc:android-pdf-viewer:3.2.0-beta.1")
```

#### Recommended Architecture Pattern
**Clean Architecture with MVVM**
```
app/
├── data/
│   ├── local/        # Room database, DAOs, entities
│   ├── remote/       # API services, DTOs
│   └── repository/   # Repository implementations
├── domain/
│   ├── model/        # Business models
│   ├── repository/   # Repository interfaces
│   └── usecase/      # Business logic use cases
├── presentation/
│   ├── ui/
│   │   ├── auth/     # Login, Registration screens
│   │   ├── dashboard/
│   │   ├── properties/
│   │   ├── tenants/
│   │   ├── payments/
│   │   ├── airbnb/
│   │   └── reports/
│   ├── viewmodel/    # ViewModels for each screen
│   └── theme/        # Compose theme and styling
├── di/               # Dependency injection modules
└── util/             # Utility classes and extensions
```

---

## 📋 Prerequisites

### Development Environment Setup

#### 1. Install Required Software
```bash
# Android Studio (Latest version - Hedgehog or later)
# Download from: https://developer.android.com/studio

# JDK 17 or higher
# Check version
java -version

# Git for version control
git --version
```

#### 2. Configure Android Studio
- Install Android SDK API 24-34
- Install Android SDK Build-Tools
- Install Android Emulator
- Install Kotlin plugin (usually pre-installed)

#### 3. Backend Prerequisites
```bash
# Install Composer packages for API support
cd /path/to/rental-management
composer require laravel/sanctum

# Publish Sanctum configuration
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"

# Run Sanctum migration
php artisan migrate

# Clear caches
php artisan config:clear
php artisan cache:clear
```

---

## 🔌 Backend API Development

### Phase 1: Setup Laravel Sanctum for API Authentication

#### Step 1.1: Configure Sanctum
```php
// config/sanctum.php - Ensure mobile support
'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
    '%s%s',
    'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
    env('APP_URL') ? ','.parse_url(env('APP_URL'), PHP_URL_HOST) : ''
))),

'middleware' => [
    'verify_csrf_token' => App\Http\Middleware\VerifyCsrfToken::class,
    'encrypt_cookies' => App\Http\Middleware\EncryptCookies::class,
],

// Token expiration (optional)
'expiration' => null, // Never expires, or set to 60 * 24 for 24 hours
```

#### Step 1.2: Update Kernel Middleware
```php
// app/Http/Kernel.php or bootstrap/app.php (Laravel 11+)
'api' => [
    \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
    'throttle:api',
    \Illuminate\Routing\Middleware\SubstituteBindings::class,
],
```

#### Step 1.3: Create API Routes File
```php
// routes/api.php (create if doesn't exist)
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\PropertyController;
use App\Http\Controllers\Api\TenantController;
use App\Http\Controllers\Api\LeaseController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ReservationController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\AirbnbController;

// Public routes
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Authentication
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    Route::put('/user/profile', [AuthController::class, 'updateProfile']);
    Route::post('/user/change-password', [AuthController::class, 'changePassword']);
    
    // Dashboard
    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::get('/dashboard/stats', [DashboardController::class, 'stats']);
    
    // Properties
    Route::apiResource('properties', PropertyController::class);
    Route::get('properties/{id}/units', [PropertyController::class, 'units']);
    Route::get('properties/{id}/images', [PropertyController::class, 'images']);
    Route::post('properties/{id}/images', [PropertyController::class, 'uploadImages']);
    Route::delete('properties/images/{imageId}', [PropertyController::class, 'deleteImage']);
    
    // Tenants
    Route::apiResource('tenants', TenantController::class);
    Route::get('tenants/{id}/leases', [TenantController::class, 'leases']);
    Route::get('tenants/{id}/payments', [TenantController::class, 'payments']);
    
    // Leases
    Route::apiResource('leases', LeaseController::class);
    Route::post('leases/{id}/renew', [LeaseController::class, 'renew']);
    Route::post('leases/{id}/terminate', [LeaseController::class, 'terminate']);
    
    // Payments
    Route::apiResource('payments', PaymentController::class);
    Route::post('payments/{id}/verify', [PaymentController::class, 'verify']);
    Route::get('payments/pending/list', [PaymentController::class, 'pending']);
    
    // Expenses
    Route::apiResource('expenses', ExpenseController::class);
    
    // Airbnb Module
    Route::prefix('airbnb')->group(function () {
        Route::get('properties', [AirbnbController::class, 'properties']);
        Route::get('properties/{id}', [AirbnbController::class, 'show']);
        Route::get('reservations', [AirbnbController::class, 'reservations']);
        Route::post('reservations', [AirbnbController::class, 'store']);
        Route::put('reservations/{id}', [AirbnbController::class, 'update']);
        Route::post('reservations/{id}/approve', [AirbnbController::class, 'approve']);
        Route::post('reservations/{id}/cancel', [AirbnbController::class, 'cancel']);
        Route::get('exchange-rates', [AirbnbController::class, 'exchangeRates']);
        Route::get('reports', [AirbnbController::class, 'reports']);
    });
    
    // Reports
    Route::prefix('reports')->group(function () {
        Route::get('revenue', [ReportController::class, 'revenue']);
        Route::get('expenses', [ReportController::class, 'expenses']);
        Route::get('occupancy', [ReportController::class, 'occupancy']);
        Route::get('balance-sheet', [ReportController::class, 'balanceSheet']);
        Route::get('profit-loss', [ReportController::class, 'profitLoss']);
    });
    
    // Notifications
    Route::get('notifications', [NotificationController::class, 'index']);
    Route::post('notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::post('notifications/read-all', [NotificationController::class, 'markAllAsRead']);
});
```


### Phase 2: Create API Controllers

#### Step 2.1: Create Base API Controller
```php
// app/Http/Controllers/Api/BaseApiController.php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

class BaseApiController extends Controller
{
    /**
     * Success response
     */
    protected function successResponse($data = null, string $message = 'Success', int $code = 200): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], $code);
    }

    /**
     * Error response
     */
    protected function errorResponse(string $message, int $code = 400, $errors = null): JsonResponse
    {
        $response = [
            'success' => false,
            'message' => $message,
        ];

        if ($errors) {
            $response['errors'] = $errors;
        }

        return response()->json($response, $code);
    }

    /**
     * Paginated response
     */
    protected function paginatedResponse($paginator, string $message = 'Success'): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $paginator->items(),
            'meta' => [
                'current_page' => $paginator->currentPage(),
                'last_page' => $paginator->lastPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
                'from' => $paginator->firstItem(),
                'to' => $paginator->lastItem(),
            ]
        ]);
    }
}
```

#### Step 2.2: Authentication Controller
```php
// app/Http/Controllers/Api/AuthController.php
<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class AuthController extends BaseApiController
{
    /**
     * Login user
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required',
            'device_name' => 'required|string',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', 422, $validator->errors());
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return $this->errorResponse('Invalid credentials', 401);
        }

        // Update last login
        $user->update(['last_login_at' => now()]);

        // Create token
        $token = $user->createToken($request->device_name)->plainTextToken;

        // Load user relationships and roles
        $user->load('roles', 'permissions');

        return $this->successResponse([
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'profile_picture' => $user->profile_picture,
                'roles' => $user->roles->pluck('name'),
                'permissions' => $user->getAllPermissions()->pluck('name'),
            ],
            'token' => $token,
            'token_type' => 'Bearer',
        ], 'Login successful');
    }

    /**
     * Register new user
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'device_name' => 'required|string',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', 422, $validator->errors());
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        // Assign default role (tenant)
        $user->assignRole('tenant');

        $token = $user->createToken($request->device_name)->plainTextToken;

        return $this->successResponse([
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'roles' => $user->roles->pluck('name'),
            ],
            'token' => $token,
            'token_type' => 'Bearer',
        ], 'Registration successful', 201);
    }

    /**
     * Logout user
     */
    public function logout(Request $request)
    {
        // Revoke current token
        $request->user()->currentAccessToken()->delete();

        return $this->successResponse(null, 'Logged out successfully');
    }

    /**
     * Get authenticated user
     */
    public function user(Request $request)
    {
        $user = $request->user();
        $user->load('roles', 'permissions');

        return $this->successResponse([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'profile_picture' => $user->profile_picture,
            'last_login_at' => $user->last_login_at,
            'roles' => $user->roles->pluck('name'),
            'permissions' => $user->getAllPermissions()->pluck('name'),
        ]);
    }

    /**
     * Update user profile
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|string|email|max:255|unique:users,email,' . $user->id,
            'profile_picture' => 'sometimes|image|max:2048',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', 422, $validator->errors());
        }

        if ($request->hasFile('profile_picture')) {
            $path = $request->file('profile_picture')->store('profile_pictures', 'public');
            $user->profile_picture = $path;
        }

        $user->update($request->only(['name', 'email']));

        return $this->successResponse($user, 'Profile updated successfully');
    }

    /**
     * Change password
     */
    public function changePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required',
            'new_password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', 422, $validator->errors());
        }

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return $this->errorResponse('Current password is incorrect', 400);
        }

        $user->update([
            'password' => Hash::make($request->new_password),
        ]);

        return $this->successResponse(null, 'Password changed successfully');
    }

    /**
     * Forgot password
     */
    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', 422, $validator->errors());
        }

        // Implement password reset logic here
        // Send email with reset token

        return $this->successResponse(null, 'Password reset link sent to your email');
    }
}
```

#### Step 2.3: Dashboard Controller
```php
// app/Http/Controllers/Api/DashboardController.php
<?php

namespace App\Http\Controllers\Api;

use App\Models\Property;
use App\Models\Tenant;
use App\Models\Lease;
use App\Models\Payment;
use App\Models\Expense;
use App\Models\Reservation;
use Illuminate\Http\Request;
use Carbon\Carbon;

class DashboardController extends BaseApiController
{
    /**
     * Get dashboard overview
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $role = $user->roles->first()->name ?? 'tenant';

        $data = [];

        switch ($role) {
            case 'admin':
            case 'Admin':
            case 'Super Admin':
                $data = $this->adminDashboard();
                break;
            case 'landlord':
            case 'Landlord':
                $data = $this->landlordDashboard($user);
                break;
            case 'tenant':
            case 'Tenant':
                $data = $this->tenantDashboard($user);
                break;
        }

        return $this->successResponse($data);
    }

    /**
     * Admin dashboard data
     */
    private function adminDashboard()
    {
        $currentMonth = Carbon::now()->startOfMonth();
        
        return [
            'stats' => [
                'total_properties' => Property::count(),
                'total_tenants' => Tenant::count(),
                'active_leases' => Lease::where('status', 'active')->count(),
                'total_revenue' => Payment::whereMonth('created_at', $currentMonth)->sum('amount'),
                'total_expenses' => Expense::whereMonth('created_at', $currentMonth)->sum('amount'),
                'pending_payments' => Payment::where('status', 'pending')->count(),
                'airbnb_reservations' => Reservation::where('status', 'approved')->count(),
            ],
            'recent_payments' => Payment::with(['tenant', 'property'])
                ->latest()
                ->take(5)
                ->get(),
            'recent_leases' => Lease::with(['tenant', 'property', 'unit'])
                ->latest()
                ->take(5)
                ->get(),
            'occupancy_rate' => $this->calculateOccupancyRate(),
        ];
    }

    /**
     * Landlord dashboard data
     */
    private function landlordDashboard($user)
    {
        $properties = Property::where('landlord_id', $user->id)->pluck('id');
        $currentMonth = Carbon::now()->startOfMonth();

        return [
            'stats' => [
                'my_properties' => $properties->count(),
                'total_units' => Property::whereIn('id', $properties)->withCount('units')->get()->sum('units_count'),
                'active_leases' => Lease::whereIn('property_id', $properties)->where('status', 'active')->count(),
                'monthly_revenue' => Payment::whereIn('property_id', $properties)
                    ->whereMonth('created_at', $currentMonth)
                    ->sum('amount'),
                'monthly_expenses' => Expense::whereIn('property_id', $properties)
                    ->whereMonth('created_at', $currentMonth)
                    ->sum('amount'),
                'pending_payments' => Payment::whereIn('property_id', $properties)
                    ->where('status', 'pending')
                    ->count(),
            ],
            'my_properties' => Property::where('landlord_id', $user->id)
                ->withCount(['units', 'reservations'])
                ->take(10)
                ->get(),
            'recent_payments' => Payment::whereIn('property_id', $properties)
                ->with(['tenant', 'property'])
                ->latest()
                ->take(5)
                ->get(),
        ];
    }

    /**
     * Tenant dashboard data
     */
    private function tenantDashboard($user)
    {
        $leases = Lease::where('tenant_id', $user->id)->get();
        
        return [
            'stats' => [
                'active_leases' => $leases->where('status', 'active')->count(),
                'total_paid' => Payment::where('tenant_id', $user->id)
                    ->where('status', 'completed')
                    ->sum('amount'),
                'pending_payments' => Payment::where('tenant_id', $user->id)
                    ->where('status', 'pending')
                    ->sum('amount'),
            ],
            'my_leases' => $leases->load(['property', 'unit']),
            'recent_payments' => Payment::where('tenant_id', $user->id)
                ->with('property')
                ->latest()
                ->take(5)
                ->get(),
            'upcoming_payments' => $this->getUpcomingPayments($user),
        ];
    }

    /**
     * Calculate occupancy rate
     */
    private function calculateOccupancyRate()
    {
        $totalUnits = \App\Models\Unit::count();
        $occupiedUnits = Lease::where('status', 'active')->distinct('unit_id')->count();

        return $totalUnits > 0 ? round(($occupiedUnits / $totalUnits) * 100, 2) : 0;
    }

    /**
     * Get upcoming payments for tenant
     */
    private function getUpcomingPayments($user)
    {
        $leases = Lease::where('tenant_id', $user->id)
            ->where('status', 'active')
            ->get();

        $upcomingPayments = [];
        foreach ($leases as $lease) {
            $upcomingPayments[] = [
                'property' => $lease->property->name,
                'unit' => $lease->unit->unit_number ?? 'N/A',
                'amount' => $lease->rent_amount,
                'due_date' => Carbon::parse($lease->start_date)->addMonth(),
            ];
        }

        return $upcomingPayments;
    }

    /**
     * Get detailed stats
     */
    public function stats(Request $request)
    {
        $period = $request->get('period', 'month'); // month, quarter, year

        $startDate = match($period) {
            'month' => Carbon::now()->startOfMonth(),
            'quarter' => Carbon::now()->startOfQuarter(),
            'year' => Carbon::now()->startOfYear(),
            default => Carbon::now()->startOfMonth(),
        };

        $user = $request->user();
        $role = $user->roles->first()->name ?? 'tenant';

        // Get properties based on role
        $propertyIds = match($role) {
            'admin', 'Admin', 'Super Admin' => Property::pluck('id'),
            'landlord', 'Landlord' => Property::where('landlord_id', $user->id)->pluck('id'),
            default => collect([]),
        };

        return $this->successResponse([
            'revenue_trend' => $this->getRevenueTrend($propertyIds, $startDate),
            'expense_trend' => $this->getExpenseTrend($propertyIds, $startDate),
            'occupancy_trend' => $this->getOccupancyTrend($propertyIds, $startDate),
            'payment_status' => $this->getPaymentStatusBreakdown($propertyIds),
        ]);
    }

    /**
     * Get revenue trend data
     */
    private function getRevenueTrend($propertyIds, $startDate)
    {
        return Payment::whereIn('property_id', $propertyIds)
            ->where('created_at', '>=', $startDate)
            ->where('status', 'completed')
            ->selectRaw('DATE(created_at) as date, SUM(amount) as total')
            ->groupBy('date')
            ->orderBy('date')
            ->get();
    }

    /**
     * Get expense trend data
     */
    private function getExpenseTrend($propertyIds, $startDate)
    {
        return Expense::whereIn('property_id', $propertyIds)
            ->where('created_at', '>=', $startDate)
            ->selectRaw('DATE(created_at) as date, SUM(amount) as total')
            ->groupBy('date')
            ->orderBy('date')
            ->get();
    }

    /**
     * Get occupancy trend
     */
    private function getOccupancyTrend($propertyIds, $startDate)
    {
        // Simplified occupancy calculation
        // In production, you'd calculate this more accurately based on lease dates
        return [];
    }

    /**
     * Get payment status breakdown
     */
    private function getPaymentStatusBreakdown($propertyIds)
    {
        return Payment::whereIn('property_id', $propertyIds)
            ->selectRaw('status, COUNT(*) as count, SUM(amount) as total')
            ->groupBy('status')
            ->get();
    }
}
```


### Phase 3: Additional API Controllers (Property, Tenant, etc.)

#### Step 3.1: Property Controller Template
```php
// app/Http/Controllers/Api/PropertyController.php
<?php

namespace App\Http\Controllers\Api;

use App\Models\Property;
use App\Models\PropertyImage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class PropertyController extends BaseApiController
{
    /**
     * Get all properties (paginated)
     */
    public function index(Request $request)
    {
        $perPage = $request->get('per_page', 15);
        $search = $request->get('search');
        $type = $request->get('type'); // apartment, house, commercial
        $paymentTerms = $request->get('payment_terms'); // monthly_rent, airbnb_per_night

        $query = Property::with(['landlord', 'units', 'images'])
            ->withCount('units');

        // Apply filters
        if ($search) {
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%")
                  ->orWhere('region', 'like', "%{$search}%");
            });
        }

        if ($type) {
            $query->where('type', $type);
        }

        if ($paymentTerms) {
            $query->where('payment_terms', $paymentTerms);
        }

        // Check user role for filtering
        $user = $request->user();
        if ($user->hasRole(['landlord', 'Landlord'])) {
            $query->where('landlord_id', $user->id);
        }

        $properties = $query->latest()->paginate($perPage);

        return $this->paginatedResponse($properties);
    }

    /**
     * Get single property
     */
    public function show($id)
    {
        $property = Property::with([
            'landlord',
            'units',
            'images',
            'reservations' => function($q) {
                $q->where('status', '!=', 'cancelled')->latest()->take(5);
            }
        ])->find($id);

        if (!$property) {
            return $this->errorResponse('Property not found', 404);
        }

        // Calculate availability
        $property->is_available = $this->checkAvailability($property);
        $property->next_available_date = $this->getNextAvailableDate($property);

        return $this->successResponse($property);
    }

    /**
     * Create property
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'type' => 'required|in:apartment,house,commercial,other',
            'description' => 'nullable|string',
            'region' => 'required|string',
            'district' => 'required|string',
            'ward' => 'nullable|string',
            'street' => 'nullable|string',
            'bedrooms' => 'nullable|integer|min:0',
            'bathrooms' => 'nullable|integer|min:0',
            'area_sqft' => 'nullable|numeric|min:0',
            'payment_terms' => 'required|in:monthly_rent,airbnb_per_night',
            'per_night_rate' => 'required_if:payment_terms,airbnb_per_night|nullable|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', 422, $validator->errors());
        }

        $property = Property::create(array_merge(
            $request->all(),
            ['landlord_id' => $request->user()->id]
        ));

        return $this->successResponse($property, 'Property created successfully', 201);
    }

    /**
     * Update property
     */
    public function update(Request $request, $id)
    {
        $property = Property::find($id);

        if (!$property) {
            return $this->errorResponse('Property not found', 404);
        }

        // Check authorization
        if (!$request->user()->hasRole(['admin', 'Admin', 'Super Admin']) 
            && $property->landlord_id !== $request->user()->id) {
            return $this->errorResponse('Unauthorized', 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'type' => 'sometimes|in:apartment,house,commercial,other',
            'description' => 'nullable|string',
            'region' => 'sometimes|string',
            'district' => 'sometimes|string',
            'payment_terms' => 'sometimes|in:monthly_rent,airbnb_per_night',
            'per_night_rate' => 'nullable|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', 422, $validator->errors());
        }

        $property->update($request->all());

        return $this->successResponse($property, 'Property updated successfully');
    }

    /**
     * Delete property
     */
    public function destroy(Request $request, $id)
    {
        $property = Property::find($id);

        if (!$property) {
            return $this->errorResponse('Property not found', 404);
        }

        // Check authorization
        if (!$request->user()->hasRole(['admin', 'Admin', 'Super Admin']) 
            && $property->landlord_id !== $request->user()->id) {
            return $this->errorResponse('Unauthorized', 403);
        }

        // Check if property has active leases
        if ($property->units()->whereHas('leases', function($q) {
            $q->where('status', 'active');
        })->exists()) {
            return $this->errorResponse('Cannot delete property with active leases', 400);
        }

        $property->delete();

        return $this->successResponse(null, 'Property deleted successfully');
    }

    /**
     * Get property units
     */
    public function units($id)
    {
        $property = Property::find($id);

        if (!$property) {
            return $this->errorResponse('Property not found', 404);
        }

        $units = $property->units()->with(['leases' => function($q) {
            $q->where('status', 'active');
        }])->get();

        return $this->successResponse($units);
    }

    /**
     * Get property images
     */
    public function images($id)
    {
        $property = Property::find($id);

        if (!$property) {
            return $this->errorResponse('Property not found', 404);
        }

        $images = $property->images;

        return $this->successResponse($images);
    }

    /**
     * Upload property images
     */
    public function uploadImages(Request $request, $id)
    {
        $property = Property::find($id);

        if (!$property) {
            return $this->errorResponse('Property not found', 404);
        }

        $validator = Validator::make($request->all(), [
            'images' => 'required|array',
            'images.*' => 'image|mimes:jpeg,png,jpg|max:5120', // 5MB max
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation Error', 422, $validator->errors());
        }

        $uploadedImages = [];

        foreach ($request->file('images') as $image) {
            $path = $image->store('properties', 'public');
            
            $propertyImage = PropertyImage::create([
                'property_id' => $property->id,
                'image_path' => $path,
            ]);

            $uploadedImages[] = $propertyImage;
        }

        return $this->successResponse($uploadedImages, 'Images uploaded successfully', 201);
    }

    /**
     * Delete property image
     */
    public function deleteImage(Request $request, $imageId)
    {
        $image = PropertyImage::find($imageId);

        if (!$image) {
            return $this->errorResponse('Image not found', 404);
        }

        // Check authorization
        $property = $image->property;
        if (!$request->user()->hasRole(['admin', 'Admin', 'Super Admin']) 
            && $property->landlord_id !== $request->user()->id) {
            return $this->errorResponse('Unauthorized', 403);
        }

        // Delete file from storage
        if (Storage::disk('public')->exists($image->image_path)) {
            Storage::disk('public')->delete($image->image_path);
        }

        $image->delete();

        return $this->successResponse(null, 'Image deleted successfully');
    }

    /**
     * Check property availability
     */
    private function checkAvailability($property)
    {
        // For Airbnb properties
        if ($property->payment_terms === 'airbnb_per_night') {
            $today = now()->startOfDay();
            return !$property->reservations()
                ->where('status', 'approved')
                ->where('check_in', '<=', $today)
                ->where('check_out', '>=', $today)
                ->exists();
        }

        // For rental properties
        $totalUnits = $property->units->count();
        $occupiedUnits = $property->units()->whereHas('leases', function($q) {
            $q->where('status', 'active');
        })->count();

        return $occupiedUnits < $totalUnits;
    }

    /**
     * Get next available date
     */
    private function getNextAvailableDate($property)
    {
        if ($property->payment_terms === 'airbnb_per_night') {
            $nextReservation = $property->reservations()
                ->where('status', 'approved')
                ->where('check_out', '>', now())
                ->orderBy('check_out')
                ->first();

            return $nextReservation ? $nextReservation->check_out : now();
        }

        return null;
    }
}
```

### Phase 4: Configure CORS for Mobile Access

```php
// config/cors.php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'], // In production, specify your mobile app's origin
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

---

## 📱 Android App Architecture

### Project Structure

```
com.yourcompany.rentalmanagement/
├── data/
│   ├── local/
│   │   ├── dao/
│   │   │   ├── PropertyDao.kt
│   │   │   ├── TenantDao.kt
│   │   │   ├── PaymentDao.kt
│   │   │   └── UserDao.kt
│   │   ├── entity/
│   │   │   ├── PropertyEntity.kt
│   │   │   ├── TenantEntity.kt
│   │   │   ├── PaymentEntity.kt
│   │   │   └── UserEntity.kt
│   │   ├── database/
│   │   │   └── RentalDatabase.kt
│   │   └── preferences/
│   │       └── UserPreferences.kt
│   ├── remote/
│   │   ├── api/
│   │   │   ├── AuthApi.kt
│   │   │   ├── PropertyApi.kt
│   │   │   ├── TenantApi.kt
│   │   │   ├── PaymentApi.kt
│   │   │   └── AirbnbApi.kt
│   │   ├── dto/
│   │   │   ├── request/
│   │   │   │   ├── LoginRequest.kt
│   │   │   │   └── CreatePropertyRequest.kt
│   │   │   └── response/
│   │   │       ├── ApiResponse.kt
│   │   │       ├── PropertyResponse.kt
│   │   │       └── UserResponse.kt
│   │   └── interceptor/
│   │       ├── AuthInterceptor.kt
│   │       └── ErrorInterceptor.kt
│   └── repository/
│       ├── AuthRepositoryImpl.kt
│       ├── PropertyRepositoryImpl.kt
│       ├── TenantRepositoryImpl.kt
│       └── PaymentRepositoryImpl.kt
├── domain/
│   ├── model/
│   │   ├── User.kt
│   │   ├── Property.kt
│   │   ├── Tenant.kt
│   │   ├── Payment.kt
│   │   ├── Lease.kt
│   │   └── Reservation.kt
│   ├── repository/
│   │   ├── AuthRepository.kt
│   │   ├── PropertyRepository.kt
│   │   ├── TenantRepository.kt
│   │   └── PaymentRepository.kt
│   └── usecase/
│       ├── auth/
│       │   ├── LoginUseCase.kt
│       │   ├── LogoutUseCase.kt
│       │   └── GetUserUseCase.kt
│       ├── property/
│       │   ├── GetPropertiesUseCase.kt
│       │   ├── GetPropertyDetailUseCase.kt
│       │   └── CreatePropertyUseCase.kt
│       └── payment/
│           ├── GetPaymentsUseCase.kt
│           └── MakePaymentUseCase.kt
├── presentation/
│   ├── ui/
│   │   ├── auth/
│   │   │   ├── LoginScreen.kt
│   │   │   ├── RegisterScreen.kt
│   │   │   └── ForgotPasswordScreen.kt
│   │   ├── dashboard/
│   │   │   ├── DashboardScreen.kt
│   │   │   └── components/
│   │   │       ├── StatCard.kt
│   │   │       └── RecentActivityCard.kt
│   │   ├── property/
│   │   │   ├── PropertyListScreen.kt
│   │   │   ├── PropertyDetailScreen.kt
│   │   │   ├── CreatePropertyScreen.kt
│   │   │   └── components/
│   │   │       ├── PropertyCard.kt
│   │   │       └── PropertyImageGallery.kt
│   │   ├── tenant/
│   │   │   ├── TenantListScreen.kt
│   │   │   └── TenantDetailScreen.kt
│   │   ├── payment/
│   │   │   ├── PaymentListScreen.kt
│   │   │   ├── PaymentDetailScreen.kt
│   │   │   └── MakePaymentScreen.kt
│   │   ├── airbnb/
│   │   │   ├── AirbnbPropertiesScreen.kt
│   │   │   ├── ReservationScreen.kt
│   │   │   └── AirbnbReportsScreen.kt
│   │   ├── reports/
│   │   │   ├── ReportsScreen.kt
│   │   │   └── components/
│   │   │       └── ChartComponent.kt
│   │   └── common/
│   │       ├── LoadingScreen.kt
│   │       ├── ErrorScreen.kt
│   │       └── EmptyStateScreen.kt
│   ├── viewmodel/
│   │   ├── AuthViewModel.kt
│   │   ├── DashboardViewModel.kt
│   │   ├── PropertyViewModel.kt
│   │   ├── TenantViewModel.kt
│   │   ├── PaymentViewModel.kt
│   │   └── AirbnbViewModel.kt
│   ├── navigation/
│   │   ├── NavGraph.kt
│   │   ├── Screen.kt
│   │   └── NavigationActions.kt
│   └── theme/
│       ├── Color.kt
│       ├── Theme.kt
│       ├── Type.kt
│       └── Shape.kt
├── di/
│   ├── AppModule.kt
│   ├── NetworkModule.kt
│   ├── DatabaseModule.kt
│   └── RepositoryModule.kt
├── util/
│   ├── Constants.kt
│   ├── NetworkResult.kt
│   ├── DateUtils.kt
│   ├── CurrencyUtils.kt
│   └── Extensions.kt
└── MainActivity.kt
```


---

## 🚀 Step-by-Step Implementation Workflow

### STEP 1: Setup Backend API (Laravel)

#### 1.1 Install and Configure Sanctum
```bash
# In your Laravel project directory
composer require laravel/sanctum

# Publish Sanctum configuration
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"

# Run migrations
php artisan migrate

# Clear cache
php artisan config:clear
php artisan cache:clear
```

#### 1.2 Update .env for API
```env
# Add these to your .env file
API_URL=https://yourdomain.com/api
SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1
SESSION_DRIVER=cookie
```

#### 1.3 Create API Routes (routes/api.php)
Create the API routes file as shown in the Backend API Development section above.

#### 1.4 Create All API Controllers
Create these controllers in `app/Http/Controllers/Api/`:
- BaseApiController.php
- AuthController.php
- DashboardController.php
- PropertyController.php
- TenantController.php (similar structure to PropertyController)
- LeaseController.php
- PaymentController.php
- ReservationController.php
- AirbnbController.php
- ReportController.php

#### 1.5 Test API Endpoints
```bash
# Use Postman or cURL to test

# Test login
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"password","device_name":"mobile"}'

# Test authenticated endpoint
curl -X GET http://localhost:8000/api/user \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

### STEP 2: Create Android Project

#### 2.1 Create New Project in Android Studio
```
1. Open Android Studio
2. File → New → New Project
3. Select "Empty Activity" with Compose
4. Name: RentalManagement
5. Package: com.yourcompany.rentalmanagement
6. Language: Kotlin
7. Minimum SDK: API 24 (Android 7.0)
8. Build configuration language: Kotlin DSL (build.gradle.kts)
9. Click Finish
```

#### 2.2 Configure build.gradle.kts (Project Level)
```kotlin
// build.gradle.kts (Project level)
plugins {
    id("com.android.application") version "8.2.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.20" apply false
    id("com.google.dagger.hilt.android") version "2.50" apply false
    id("com.google.devtools.ksp") version "1.9.20-1.0.14" apply false
}
```

#### 2.3 Configure build.gradle.kts (App Level)
```kotlin
// app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.dagger.hilt.android")
    id("com.google.devtools.ksp")
    id("kotlin-parcelize")
}

android {
    namespace = "com.yourcompany.rentalmanagement"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.yourcompany.rentalmanagement"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        
        // API Base URL
        buildConfigField("String", "BASE_URL", "\"https://yourdomain.com/api/\"")
        buildConfigField("String", "IMAGE_BASE_URL", "\"https://yourdomain.com/storage/\"")
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isDebuggable = true
            applicationIdSuffix = ".debug"
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
    
    buildFeatures {
        compose = true
        buildConfig = true
    }
    
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.4"
    }
    
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    // Core Android
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.activity:activity-compose:1.8.2")

    // Compose
    implementation(platform("androidx.compose:compose-bom:2024.01.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    
    // Navigation
    implementation("androidx.navigation:navigation-compose:2.7.6")
    
    // ViewModel
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.7.0")
    
    // Hilt for DI
    implementation("com.google.dagger:hilt-android:2.50")
    ksp("com.google.dagger:hilt-compiler:2.50")
    implementation("androidx.hilt:hilt-navigation-compose:1.1.0")
    
    // Room Database
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    ksp("androidx.room:room-compiler:2.6.1")
    
    // Retrofit & OkHttp
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")
    
    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
    
    // DataStore
    implementation("androidx.datastore:datastore-preferences:1.0.0")
    
    // Coil for image loading
    implementation("io.coil-kt:coil-compose:2.5.0")
    
    // WorkManager
    implementation("androidx.work:work-runtime-ktx:2.9.0")
    
    // Gson
    implementation("com.google.code.gson:gson:2.10.1")
    
    // Date/Time
    implementation("org.jetbrains.kotlinx:kotlinx-datetime:0.5.0")
    
    // Charts
    implementation("com.github.PhilJay:MPAndroidChart:v3.1.0")
    
    // Testing
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation(platform("androidx.compose:compose-bom:2024.01.00"))
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}
```

#### 2.4 Add Required Permissions (AndroidManifest.xml)
```xml
<!-- app/src/main/AndroidManifest.xml -->
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <!-- Network permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Storage permissions for image upload -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    
    <!-- Camera permission (optional for taking property photos) -->
    <uses-permission android:name="android.permission.CAMERA" />
    
    <!-- Notification permissions -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <application
        android:name=".RentalManagementApp"
        android:allowBackup="true"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.RentalManagement"
        android:usesCleartextTraffic="true"
        tools:targetApi="31">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/Theme.RentalManagement">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
```

---

### STEP 3: Implement Core Architecture Components

#### 3.1 Create Application Class
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/RentalManagementApp.kt
package com.yourcompany.rentalmanagement

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class RentalManagementApp : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialize any required libraries here
    }
}
```

#### 3.2 Create Network Result Wrapper
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/util/NetworkResult.kt
package com.yourcompany.rentalmanagement.util

sealed class NetworkResult<T>(
    val data: T? = null,
    val message: String? = null
) {
    class Success<T>(data: T) : NetworkResult<T>(data)
    class Error<T>(message: String, data: T? = null) : NetworkResult<T>(data, message)
    class Loading<T> : NetworkResult<T>()
}
```

#### 3.3 Create Constants
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/util/Constants.kt
package com.yourcompany.rentalmanagement.util

object Constants {
    // API
    const val BASE_URL = "https://yourdomain.com/api/"
    const val IMAGE_BASE_URL = "https://yourdomain.com/storage/"
    
    // Preferences
    const val PREF_NAME = "rental_management_prefs"
    const val KEY_TOKEN = "auth_token"
    const val KEY_USER_ID = "user_id"
    const val KEY_USER_NAME = "user_name"
    const val KEY_USER_EMAIL = "user_email"
    const val KEY_USER_ROLE = "user_role"
    
    // Database
    const val DATABASE_NAME = "rental_management_db"
    const val DATABASE_VERSION = 1
    
    // Pagination
    const val PAGE_SIZE = 20
    const val PREFETCH_DISTANCE = 5
    
    // Date Formats
    const val DATE_FORMAT = "yyyy-MM-dd"
    const val DATE_TIME_FORMAT = "yyyy-MM-dd HH:mm:ss"
    const val DISPLAY_DATE_FORMAT = "MMM dd, yyyy"
    const val DISPLAY_DATE_TIME_FORMAT = "MMM dd, yyyy HH:mm"
    
    // Currencies
    val SUPPORTED_CURRENCIES = listOf("TZS", "USD", "EUR", "GBP")
    
    // Request Codes
    const val REQUEST_IMAGE_PICK = 1001
    const val REQUEST_IMAGE_CAPTURE = 1002
    const val REQUEST_PERMISSIONS = 1003
}
```

#### 3.4 Create API Response DTOs
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/data/remote/dto/response/ApiResponse.kt
package com.yourcompany.rentalmanagement.data.remote.dto.response

import com.google.gson.annotations.SerializedName

data class ApiResponse<T>(
    @SerializedName("success")
    val success: Boolean,
    
    @SerializedName("message")
    val message: String,
    
    @SerializedName("data")
    val data: T?,
    
    @SerializedName("errors")
    val errors: Map<String, List<String>>? = null,
    
    @SerializedName("meta")
    val meta: PaginationMeta? = null
)

data class PaginationMeta(
    @SerializedName("current_page")
    val currentPage: Int,
    
    @SerializedName("last_page")
    val lastPage: Int,
    
    @SerializedName("per_page")
    val perPage: Int,
    
    @SerializedName("total")
    val total: Int,
    
    @SerializedName("from")
    val from: Int?,
    
    @SerializedName("to")
    val to: Int?
)
```

#### 3.5 Create Auth DTOs
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/data/remote/dto/request/LoginRequest.kt
package com.yourcompany.rentalmanagement.data.remote.dto.request

import com.google.gson.annotations.SerializedName

data class LoginRequest(
    @SerializedName("email")
    val email: String,
    
    @SerializedName("password")
    val password: String,
    
    @SerializedName("device_name")
    val deviceName: String = "Android"
)

// app/src/main/java/com/yourcompany/rentalmanagement/data/remote/dto/response/LoginResponse.kt
package com.yourcompany.rentalmanagement.data.remote.dto.response

import com.google.gson.annotations.SerializedName

data class LoginResponse(
    @SerializedName("user")
    val user: UserDto,
    
    @SerializedName("token")
    val token: String,
    
    @SerializedName("token_type")
    val tokenType: String
)

data class UserDto(
    @SerializedName("id")
    val id: Int,
    
    @SerializedName("name")
    val name: String,
    
    @SerializedName("email")
    val email: String,
    
    @SerializedName("profile_picture")
    val profilePicture: String?,
    
    @SerializedName("roles")
    val roles: List<String>,
    
    @SerializedName("permissions")
    val permissions: List<String>?
)
```


#### 3.6 Setup Retrofit and OkHttp
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/data/remote/interceptor/AuthInterceptor.kt
package com.yourcompany.rentalmanagement.data.remote.interceptor

import com.yourcompany.rentalmanagement.data.local.preferences.UserPreferences
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import okhttp3.Interceptor
import okhttp3.Response
import javax.inject.Inject

class AuthInterceptor @Inject constructor(
    private val userPreferences: UserPreferences
) : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val token = runBlocking {
            userPreferences.getAuthToken().first()
        }
        
        val request = chain.request().newBuilder()
        
        if (!token.isNullOrEmpty()) {
            request.addHeader("Authorization", "Bearer $token")
        }
        
        request.addHeader("Accept", "application/json")
        request.addHeader("Content-Type", "application/json")
        
        return chain.proceed(request.build())
    }
}

// app/src/main/java/com/yourcompany/rentalmanagement/di/NetworkModule.kt
package com.yourcompany.rentalmanagement.di

import com.yourcompany.rentalmanagement.BuildConfig
import com.yourcompany.rentalmanagement.data.remote.api.*
import com.yourcompany.rentalmanagement.data.remote.interceptor.AuthInterceptor
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
    
    @Provides
    @Singleton
    fun provideLoggingInterceptor(): HttpLoggingInterceptor {
        return HttpLoggingInterceptor().apply {
            level = if (BuildConfig.DEBUG) {
                HttpLoggingInterceptor.Level.BODY
            } else {
                HttpLoggingInterceptor.Level.NONE
            }
        }
    }
    
    @Provides
    @Singleton
    fun provideOkHttpClient(
        loggingInterceptor: HttpLoggingInterceptor,
        authInterceptor: AuthInterceptor
    ): OkHttpClient {
        return OkHttpClient.Builder()
            .addInterceptor(authInterceptor)
            .addInterceptor(loggingInterceptor)
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build()
    }
    
    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient): Retrofit {
        return Retrofit.Builder()
            .baseUrl(BuildConfig.BASE_URL)
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }
    
    @Provides
    @Singleton
    fun provideAuthApi(retrofit: Retrofit): AuthApi {
        return retrofit.create(AuthApi::class.java)
    }
    
    @Provides
    @Singleton
    fun providePropertyApi(retrofit: Retrofit): PropertyApi {
        return retrofit.create(PropertyApi::class.java)
    }
    
    @Provides
    @Singleton
    fun provideDashboardApi(retrofit: Retrofit): DashboardApi {
        return retrofit.create(DashboardApi::class.java)
    }
    
    // Add other API providers as needed
}
```

#### 3.7 Setup Room Database
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/data/local/entity/UserEntity.kt
package com.yourcompany.rentalmanagement.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey
    val id: Int,
    val name: String,
    val email: String,
    val profilePicture: String?,
    val roles: String, // Stored as JSON string
    val lastSyncedAt: Long
)

// app/src/main/java/com/yourcompany/rentalmanagement/data/local/entity/PropertyEntity.kt
package com.yourcompany.rentalmanagement.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "properties")
data class PropertyEntity(
    @PrimaryKey
    val id: Int,
    val landlordId: Int,
    val name: String,
    val type: String,
    val description: String?,
    val region: String,
    val district: String,
    val ward: String?,
    val street: String?,
    val bedrooms: Int?,
    val bathrooms: Int?,
    val areaSquareFeet: Double?,
    val paymentTerms: String,
    val perNightRate: Double?,
    val imageUrl: String?,
    val unitsCount: Int,
    val isAvailable: Boolean,
    val lastSyncedAt: Long
)

// app/src/main/java/com/yourcompany/rentalmanagement/data/local/dao/PropertyDao.kt
package com.yourcompany.rentalmanagement.data.local.dao

import androidx.room.*
import com.yourcompany.rentalmanagement.data.local.entity.PropertyEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface PropertyDao {
    @Query("SELECT * FROM properties ORDER BY lastSyncedAt DESC")
    fun getAllProperties(): Flow<List<PropertyEntity>>
    
    @Query("SELECT * FROM properties WHERE id = :id")
    suspend fun getPropertyById(id: Int): PropertyEntity?
    
    @Query("SELECT * FROM properties WHERE landlordId = :landlordId")
    fun getPropertiesByLandlord(landlordId: Int): Flow<List<PropertyEntity>>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertProperty(property: PropertyEntity)
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertProperties(properties: List<PropertyEntity>)
    
    @Delete
    suspend fun deleteProperty(property: PropertyEntity)
    
    @Query("DELETE FROM properties")
    suspend fun deleteAllProperties()
}

// app/src/main/java/com/yourcompany/rentalmanagement/data/local/database/RentalDatabase.kt
package com.yourcompany.rentalmanagement.data.local.database

import androidx.room.Database
import androidx.room.RoomDatabase
import com.yourcompany.rentalmanagement.data.local.dao.*
import com.yourcompany.rentalmanagement.data.local.entity.*

@Database(
    entities = [
        UserEntity::class,
        PropertyEntity::class,
        // Add other entities
    ],
    version = 1,
    exportSchema = false
)
abstract class RentalDatabase : RoomDatabase() {
    abstract fun userDao(): UserDao
    abstract fun propertyDao(): PropertyDao
    // Add other DAOs
}

// app/src/main/java/com/yourcompany/rentalmanagement/di/DatabaseModule.kt
package com.yourcompany.rentalmanagement.di

import android.content.Context
import androidx.room.Room
import com.yourcompany.rentalmanagement.data.local.database.RentalDatabase
import com.yourcompany.rentalmanagement.util.Constants
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {
    
    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): RentalDatabase {
        return Room.databaseBuilder(
            context,
            RentalDatabase::class.java,
            Constants.DATABASE_NAME
        )
        .fallbackToDestructiveMigration()
        .build()
    }
    
    @Provides
    fun provideUserDao(database: RentalDatabase) = database.userDao()
    
    @Provides
    fun providePropertyDao(database: RentalDatabase) = database.propertyDao()
    
    // Add other DAOs
}
```

#### 3.8 Setup DataStore for Preferences
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/data/local/preferences/UserPreferences.kt
package com.yourcompany.rentalmanagement.data.local.preferences

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.yourcompany.rentalmanagement.util.Constants
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = Constants.PREF_NAME)

@Singleton
class UserPreferences @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private val dataStore = context.dataStore
    
    companion object {
        val KEY_TOKEN = stringPreferencesKey(Constants.KEY_TOKEN)
        val KEY_USER_ID = intPreferencesKey(Constants.KEY_USER_ID)
        val KEY_USER_NAME = stringPreferencesKey(Constants.KEY_USER_NAME)
        val KEY_USER_EMAIL = stringPreferencesKey(Constants.KEY_USER_EMAIL)
        val KEY_USER_ROLE = stringPreferencesKey(Constants.KEY_USER_ROLE)
    }
    
    suspend fun saveAuthToken(token: String) {
        dataStore.edit { preferences ->
            preferences[KEY_TOKEN] = token
        }
    }
    
    fun getAuthToken(): Flow<String?> {
        return dataStore.data.map { preferences ->
            preferences[KEY_TOKEN]
        }
    }
    
    suspend fun saveUserData(id: Int, name: String, email: String, role: String) {
        dataStore.edit { preferences ->
            preferences[KEY_USER_ID] = id
            preferences[KEY_USER_NAME] = name
            preferences[KEY_USER_EMAIL] = email
            preferences[KEY_USER_ROLE] = role
        }
    }
    
    fun getUserId(): Flow<Int?> {
        return dataStore.data.map { preferences ->
            preferences[KEY_USER_ID]
        }
    }
    
    fun getUserName(): Flow<String?> {
        return dataStore.data.map { preferences ->
            preferences[KEY_USER_NAME]
        }
    }
    
    fun getUserEmail(): Flow<String?> {
        return dataStore.data.map { preferences ->
            preferences[KEY_USER_EMAIL]
        }
    }
    
    fun getUserRole(): Flow<String?> {
        return dataStore.data.map { preferences ->
            preferences[KEY_USER_ROLE]
        }
    }
    
    suspend fun clearAllData() {
        dataStore.edit { preferences ->
            preferences.clear()
        }
    }
    
    suspend fun isLoggedIn(): Boolean {
        return getAuthToken().map { !it.isNullOrEmpty() }.map { it }.toString().toBoolean()
    }
}
```

---

### STEP 4: Implement Authentication Flow

#### 4.1 Create Auth API Interface
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/data/remote/api/AuthApi.kt
package com.yourcompany.rentalmanagement.data.remote.api

import com.yourcompany.rentalmanagement.data.remote.dto.request.LoginRequest
import com.yourcompany.rentalmanagement.data.remote.dto.response.ApiResponse
import com.yourcompany.rentalmanagement.data.remote.dto.response.LoginResponse
import com.yourcompany.rentalmanagement.data.remote.dto.response.UserDto
import retrofit2.Response
import retrofit2.http.*

interface AuthApi {
    @POST("login")
    suspend fun login(@Body request: LoginRequest): Response<ApiResponse<LoginResponse>>
    
    @POST("register")
    suspend fun register(@Body request: Map<String, String>): Response<ApiResponse<LoginResponse>>
    
    @POST("logout")
    suspend fun logout(): Response<ApiResponse<Nothing>>
    
    @GET("user")
    suspend fun getUser(): Response<ApiResponse<UserDto>>
    
    @PUT("user/profile")
    suspend fun updateProfile(@Body request: Map<String, String>): Response<ApiResponse<UserDto>>
    
    @POST("user/change-password")
    suspend fun changePassword(@Body request: Map<String, String>): Response<ApiResponse<Nothing>>
}
```

#### 4.2 Create Auth Repository
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/domain/repository/AuthRepository.kt
package com.yourcompany.rentalmanagement.domain.repository

import com.yourcompany.rentalmanagement.domain.model.User
import com.yourcompany.rentalmanagement.util.NetworkResult
import kotlinx.coroutines.flow.Flow

interface AuthRepository {
    suspend fun login(email: String, password: String): Flow<NetworkResult<User>>
    suspend fun register(name: String, email: String, password: String): Flow<NetworkResult<User>>
    suspend fun logout(): Flow<NetworkResult<Unit>>
    suspend fun getUser(): Flow<NetworkResult<User>>
    suspend fun isLoggedIn(): Boolean
}

// app/src/main/java/com/yourcompany/rentalmanagement/data/repository/AuthRepositoryImpl.kt
package com.yourcompany.rentalmanagement.data.repository

import com.yourcompany.rentalmanagement.data.local.preferences.UserPreferences
import com.yourcompany.rentalmanagement.data.remote.api.AuthApi
import com.yourcompany.rentalmanagement.data.remote.dto.request.LoginRequest
import com.yourcompany.rentalmanagement.domain.model.User
import com.yourcompany.rentalmanagement.domain.repository.AuthRepository
import com.yourcompany.rentalmanagement.util.NetworkResult
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.first
import javax.inject.Inject

class AuthRepositoryImpl @Inject constructor(
    private val authApi: AuthApi,
    private val userPreferences: UserPreferences
) : AuthRepository {
    
    override suspend fun login(email: String, password: String): Flow<NetworkResult<User>> = flow {
        emit(NetworkResult.Loading())
        
        try {
            val response = authApi.login(LoginRequest(email, password))
            
            if (response.isSuccessful && response.body()?.success == true) {
                val loginData = response.body()!!.data!!
                
                // Save token and user data
                userPreferences.saveAuthToken(loginData.token)
                userPreferences.saveUserData(
                    id = loginData.user.id,
                    name = loginData.user.name,
                    email = loginData.user.email,
                    role = loginData.user.roles.firstOrNull() ?: "tenant"
                )
                
                val user = User(
                    id = loginData.user.id,
                    name = loginData.user.name,
                    email = loginData.user.email,
                    profilePicture = loginData.user.profilePicture,
                    roles = loginData.user.roles,
                    token = loginData.token
                )
                
                emit(NetworkResult.Success(user))
            } else {
                val errorMessage = response.body()?.message ?: "Login failed"
                emit(NetworkResult.Error(errorMessage))
            }
        } catch (e: Exception) {
            emit(NetworkResult.Error(e.message ?: "An error occurred"))
        }
    }
    
    override suspend fun register(
        name: String,
        email: String,
        password: String
    ): Flow<NetworkResult<User>> = flow {
        emit(NetworkResult.Loading())
        
        try {
            val request = mapOf(
                "name" to name,
                "email" to email,
                "password" to password,
                "password_confirmation" to password,
                "device_name" to "Android"
            )
            
            val response = authApi.register(request)
            
            if (response.isSuccessful && response.body()?.success == true) {
                val loginData = response.body()!!.data!!
                
                userPreferences.saveAuthToken(loginData.token)
                userPreferences.saveUserData(
                    id = loginData.user.id,
                    name = loginData.user.name,
                    email = loginData.user.email,
                    role = loginData.user.roles.firstOrNull() ?: "tenant"
                )
                
                val user = User(
                    id = loginData.user.id,
                    name = loginData.user.name,
                    email = loginData.user.email,
                    profilePicture = loginData.user.profilePicture,
                    roles = loginData.user.roles,
                    token = loginData.token
                )
                
                emit(NetworkResult.Success(user))
            } else {
                emit(NetworkResult.Error(response.body()?.message ?: "Registration failed"))
            }
        } catch (e: Exception) {
            emit(NetworkResult.Error(e.message ?: "An error occurred"))
        }
    }
    
    override suspend fun logout(): Flow<NetworkResult<Unit>> = flow {
        emit(NetworkResult.Loading())
        
        try {
            authApi.logout()
            userPreferences.clearAllData()
            emit(NetworkResult.Success(Unit))
        } catch (e: Exception) {
            // Even if API call fails, clear local data
            userPreferences.clearAllData()
            emit(NetworkResult.Success(Unit))
        }
    }
    
    override suspend fun getUser(): Flow<NetworkResult<User>> = flow {
        emit(NetworkResult.Loading())
        
        try {
            val response = authApi.getUser()
            
            if (response.isSuccessful && response.body()?.success == true) {
                val userDto = response.body()!!.data!!
                val token = userPreferences.getAuthToken().first()
                
                val user = User(
                    id = userDto.id,
                    name = userDto.name,
                    email = userDto.email,
                    profilePicture = userDto.profilePicture,
                    roles = userDto.roles,
                    token = token
                )
                
                emit(NetworkResult.Success(user))
            } else {
                emit(NetworkResult.Error(response.body()?.message ?: "Failed to get user"))
            }
        } catch (e: Exception) {
            emit(NetworkResult.Error(e.message ?: "An error occurred"))
        }
    }
    
    override suspend fun isLoggedIn(): Boolean {
        return !userPreferences.getAuthToken().first().isNullOrEmpty()
    }
}
```


#### 4.3 Create Auth ViewModel
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/presentation/viewmodel/AuthViewModel.kt
package com.yourcompany.rentalmanagement.presentation.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yourcompany.rentalmanagement.domain.model.User
import com.yourcompany.rentalmanagement.domain.repository.AuthRepository
import com.yourcompany.rentalmanagement.util.NetworkResult
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val authRepository: AuthRepository
) : ViewModel() {
    
    private val _loginState = MutableStateFlow<NetworkResult<User>?>(null)
    val loginState: StateFlow<NetworkResult<User>?> = _loginState
    
    private val _isLoggedIn = MutableStateFlow(false)
    val isLoggedIn: StateFlow<Boolean> = _isLoggedIn
    
    init {
        checkLoginStatus()
    }
    
    fun login(email: String, password: String) {
        viewModelScope.launch {
            authRepository.login(email, password).collect { result ->
                _loginState.value = result
                if (result is NetworkResult.Success) {
                    _isLoggedIn.value = true
                }
            }
        }
    }
    
    fun register(name: String, email: String, password: String) {
        viewModelScope.launch {
            authRepository.register(name, email, password).collect { result ->
                _loginState.value = result
                if (result is NetworkResult.Success) {
                    _isLoggedIn.value = true
                }
            }
        }
    }
    
    fun logout() {
        viewModelScope.launch {
            authRepository.logout().collect { result ->
                if (result is NetworkResult.Success) {
                    _isLoggedIn.value = false
                }
            }
        }
    }
    
    private fun checkLoginStatus() {
        viewModelScope.launch {
            _isLoggedIn.value = authRepository.isLoggedIn()
        }
    }
}
```

#### 4.4 Create Login Screen (Jetpack Compose)
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/presentation/ui/auth/LoginScreen.kt
package com.yourcompany.rentalmanagement.presentation.ui.auth

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.yourcompany.rentalmanagement.presentation.viewmodel.AuthViewModel
import com.yourcompany.rentalmanagement.util.NetworkResult

@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit,
    onNavigateToRegister: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel()
) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var showError by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf("") }
    
    val loginState by viewModel.loginState.collectAsState()
    
    LaunchedEffect(loginState) {
        when (loginState) {
            is NetworkResult.Success -> {
                onLoginSuccess()
            }
            is NetworkResult.Error -> {
                showError = true
                errorMessage = (loginState as NetworkResult.Error).message ?: "Login failed"
            }
            else -> {}
        }
    }
    
    Scaffold { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "Rental Management",
                style = MaterialTheme.typography.headlineLarge,
                color = MaterialTheme.colorScheme.primary
            )
            
            Spacer(modifier = Modifier.height(48.dp))
            
            OutlinedTextField(
                value = email,
                onValueChange = { email = it },
                label = { Text("Email") },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            OutlinedTextField(
                value = password,
                onValueChange = { password = it },
                label = { Text("Password") },
                visualTransformation = PasswordVisualTransformation(),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            
            if (showError) {
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = errorMessage,
                    color = MaterialTheme.colorScheme.error,
                    style = MaterialTheme.typography.bodySmall
                )
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            
            Button(
                onClick = { viewModel.login(email, password) },
                modifier = Modifier.fillMaxWidth(),
                enabled = email.isNotBlank() && password.isNotBlank() && loginState !is NetworkResult.Loading
            ) {
                if (loginState is NetworkResult.Loading) {
                    CircularProgressIndicator(
                        color = MaterialTheme.colorScheme.onPrimary,
                        modifier = Modifier.size(24.dp)
                    )
                } else {
                    Text("Login")
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            TextButton(onClick = onNavigateToRegister) {
                Text("Don't have an account? Register")
            }
        }
    }
}
```

---

## 🔄 Authentication & Data Synchronization

### Strategy for Data Consistency

#### 1. Hybrid Sync Approach
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/data/sync/SyncManager.kt
package com.yourcompany.rentalmanagement.data.sync

import android.content.Context
import androidx.work.*
import com.yourcompany.rentalmanagement.domain.repository.*
import dagger.hilt.android.qualifiers.ApplicationContext
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SyncManager @Inject constructor(
    @ApplicationContext private val context: Context
) {
    /**
     * Schedule periodic background sync
     */
    fun schedulePeriodicSync() {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()
        
        val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(
            15, TimeUnit.MINUTES
        )
        .setConstraints(constraints)
        .build()
        
        WorkManager.getInstance(context)
            .enqueueUniquePeriodicWork(
                "periodic_sync",
                ExistingPeriodicWorkPolicy.KEEP,
                syncRequest
            )
    }
    
    /**
     * Trigger manual sync
     */
    fun triggerManualSync() {
        val syncRequest = OneTimeWorkRequestBuilder<SyncWorker>()
            .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
            .build()
        
        WorkManager.getInstance(context)
            .enqueueUniqueWork(
                "manual_sync",
                ExistingWorkPolicy.REPLACE,
                syncRequest
            )
    }
}

// Worker for background sync
class SyncWorker @Inject constructor(
    context: Context,
    params: WorkerParameters,
    private val propertyRepository: PropertyRepository,
    private val paymentRepository: PaymentRepository
    // Add other repositories
) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        return try {
            // Sync properties
            propertyRepository.syncProperties()
            
            // Sync payments
            paymentRepository.syncPayments()
            
            // Sync other data...
            
            Result.success()
        } catch (e: Exception) {
            Result.retry()
        }
    }
}
```

#### 2. Offline-First Architecture
```kotlin
/**
 * Repository pattern for offline-first data access
 * 
 * Data Flow:
 * 1. Try to load from local database first (instant response)
 * 2. Show cached data to user
 * 3. Fetch fresh data from API in background
 * 4. Update local database with fresh data
 * 5. UI automatically updates via Flow
 */

// Example: Property Repository with offline support
@Singleton
class PropertyRepositoryImpl @Inject constructor(
    private val propertyApi: PropertyApi,
    private val propertyDao: PropertyDao,
    private val networkConnectivity: NetworkConnectivity
) : PropertyRepository {
    
    override fun getProperties(): Flow<NetworkResult<List<Property>>> = flow {
        // 1. Emit cached data first (for offline support)
        emit(NetworkResult.Loading())
        
        val cachedProperties = propertyDao.getAllProperties().first()
        if (cachedProperties.isNotEmpty()) {
            emit(NetworkResult.Success(cachedProperties.map { it.toDomainModel() }))
        }
        
        // 2. Fetch fresh data if connected
        if (networkConnectivity.isConnected()) {
            try {
                val response = propertyApi.getProperties()
                if (response.isSuccessful && response.body()?.success == true) {
                    val properties = response.body()!!.data!!
                    
                    // 3. Update local database
                    propertyDao.insertProperties(properties.map { it.toEntity() })
                    
                    // 4. Emit fresh data
                    emit(NetworkResult.Success(properties.map { it.toDomainModel() }))
                } else {
                    if (cachedProperties.isEmpty()) {
                        emit(NetworkResult.Error("Failed to load properties"))
                    }
                }
            } catch (e: Exception) {
                if (cachedProperties.isEmpty()) {
                    emit(NetworkResult.Error(e.message ?: "Network error"))
                }
            }
        } else {
            if (cachedProperties.isEmpty()) {
                emit(NetworkResult.Error("No internet connection"))
            }
        }
    }
}
```

#### 3. Conflict Resolution Strategy
```kotlin
/**
 * Conflict Resolution Rules:
 * - Server data always wins for read operations
 * - Local pending changes are queued and synced when online
 * - Timestamp-based conflict resolution for simultaneous edits
 */

data class PendingChange(
    val id: Long,
    val entityType: String, // "property", "payment", etc.
    val entityId: Int?,
    val operation: Operation, // CREATE, UPDATE, DELETE
    val data: String, // JSON representation
    val timestamp: Long,
    val synced: Boolean
)

enum class Operation {
    CREATE, UPDATE, DELETE
}
```

---

## 🎨 UI/UX Design Guidelines

### Design System Matching Web Application

#### 1. Color Scheme (matching web gradient)
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/presentation/theme/Color.kt
package com.yourcompany.rentalmanagement.presentation.theme

import androidx.compose.ui.graphics.Color

// Primary Colors (Purple to Pink gradient from web)
val Purple700 = Color(0xFF7C3AED)
val Purple500 = Color(0xFF9333EA)
val Pink500 = Color(0xFFEC4899)
val Pink400 = Color(0xFFF472B6)

// Neutral Colors
val Gray50 = Color(0xFFF9FAFB)
val Gray100 = Color(0xFFF3F4F6)
val Gray200 = Color(0xFFE5E7EB)
val Gray700 = Color(0xFF374151)
val Gray800 = Color(0xFF1F2937)
val Gray900 = Color(0xFF111827)

// Semantic Colors
val Success = Color(0xFF10B981)
val Warning = Color(0xFFF59E0B)
val Error = Color(0xFFEF4444)
val Info = Color(0xFF3B82F6)

// Theme Colors
val DarkPrimary = Purple500
val DarkOnPrimary = Color.White
val DarkSecondary = Pink500
val DarkBackground = Gray900
val DarkSurface = Gray800

val LightPrimary = Purple700
val LightOnPrimary = Color.White
val LightSecondary = Pink500
val LightBackground = Gray50
val LightSurface = Color.White
```

#### 2. Typography (matching web font styles)
```kotlin
// app/src/main/java/com/yourcompany/rentalmanagement/presentation/theme/Type.kt
package com.yourcompany.rentalmanagement.presentation.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

val Typography = Typography(
    displayLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Bold,
        fontSize = 34.sp,
        lineHeight = 40.sp
    ),
    headlineLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Bold,
        fontSize = 28.sp,
        lineHeight = 36.sp
    ),
    headlineMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.SemiBold,
        fontSize = 24.sp,
        lineHeight = 32.sp
    ),
    titleLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.SemiBold,
        fontSize = 20.sp,
        lineHeight = 28.sp
    ),
    bodyLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp
    ),
    bodyMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 14.sp,
        lineHeight = 20.sp
    ),
    labelLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Medium,
        fontSize = 14.sp,
        lineHeight = 20.sp
    )
)
```

#### 3. Component Library (matching web cards and layouts)
```kotlin
// Gradient Header Card (matching web design)
@Composable
fun GradientHeaderCard(
    title: String,
    subtitle: String?,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(
            containerColor = Color.Transparent
        )
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    brush = Brush.horizontalGradient(
                        colors = listOf(Purple700, Pink500)
                    )
                )
                .padding(24.dp)
        ) {
            Column {
                Text(
                    text = title,
                    style = MaterialTheme.typography.headlineLarge,
                    color = Color.White
                )
                if (subtitle != null) {
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = subtitle,
                        style = MaterialTheme.typography.bodyLarge,
                        color = Color.White.copy(alpha = 0.9f)
                    )
                }
            }
        }
    }
}

// Stat Card (matching web stat cards)
@Composable
fun StatCard(
    title: String,
    value: String,
    icon: ImageVector,
    trend: String? = null,
    onClick: () -> Unit = {}
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.bodyMedium,
                    color = Gray700
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = value,
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold
                )
                if (trend != null) {
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = trend,
                        style = MaterialTheme.typography.bodySmall,
                        color = if (trend.startsWith("+")) Success else Error
                    )
                }
            }
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = Purple500,
                modifier = Modifier.size(40.dp)
            )
        }
    }
}
```

---

## 🗄️ Database & Local Storage

### Room Database Schema
```kotlin
// Complete database structure matching web application

@Entity(tableName = "properties")
data class PropertyEntity(...)

@Entity(tableName = "tenants")
data class TenantEntity(...)

@Entity(tableName = "leases")
data class LeaseEntity(...)

@Entity(tableName = "payments")
data class PaymentEntity(...)

@Entity(tableName = "expenses")
data class ExpenseEntity(...)

@Entity(tableName = "reservations")
data class ReservationEntity(...)

@Entity(tableName = "accounts")
data class AccountEntity(...)
```

---

## 🧪 Testing Strategy

### 1. Unit Tests
```kotlin
// Test repositories
@Test
fun `login with valid credentials returns success`() = runTest {
    // Arrange
    val email = "test@example.com"
    val password = "password"
    
    // Act
    authRepository.login(email, password).test {
        // Assert
        assertThat(awaitItem()).isInstanceOf(NetworkResult.Loading::class.java)
        assertThat(awaitItem()).isInstanceOf(NetworkResult.Success::class.java)
        awaitComplete()
    }
}
```

### 2. UI Tests
```kotlin
@Test
fun loginScreen_validInput_showsSuccessNavigation() {
    composeTestRule.setContent {
        LoginScreen(
            onLoginSuccess = { /* verify navigation */ },
            onNavigateToRegister = { }
        )
    }
    
    composeTestRule.onNodeWithText("Email").performTextInput("test@example.com")
    composeTestRule.onNodeWithText("Password").performTextInput("password")
    composeTestRule.onNodeWithText("Login").performClick()
    
    // Verify success state
}
```

---

## 🔒 Security Considerations

### 1. Secure Token Storage
```kotlin
// Use encrypted DataStore for sensitive data
implementation("androidx.security:security-crypto:1.1.0-alpha06")
```

### 2. Network Security Configuration
```xml
<!-- res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

### 3. Certificate Pinning (Production)
```kotlin
val certificatePinner = CertificatePinner.Builder()
    .add("yourdomain.com", "sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=")
    .build()

val client = OkHttpClient.Builder()
    .certificatePinner(certificatePinner)
    .build()
```

---

## 📦 Build & Deployment

### 1. Build Variants
```kotlin
android {
    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-DEBUG"
            buildConfigField("String", "BASE_URL", "\"http://10.0.2.2:8000/api/\"")
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            buildConfigField("String", "BASE_URL", "\"https://yourdomain.com/api/\"")
            
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### 2. Generate Signed APK/AAB
```bash
# In Android Studio:
# Build → Generate Signed Bundle / APK
# Select Android App Bundle (AAB) for Google Play
# Or APK for direct distribution

# Command line:
./gradlew assembleRelease
# Output: app/build/outputs/apk/release/app-release.apk

./gradlew bundleRelease
# Output: app/build/outputs/bundle/release/app-release.aab
```

### 3. Google Play Store Deployment
```
1. Create Google Play Console account
2. Create new app
3. Complete store listing (title, description, screenshots)
4. Upload AAB file
5. Complete content rating questionnaire
6. Set pricing & distribution
7. Submit for review
```

---

## 🔄 Maintenance & Updates

### Versioning Strategy
```kotlin
// Semantic Versioning: MAJOR.MINOR.PATCH
versionCode = 1  // Increment for each release
versionName = "1.0.0"

// Example progression:
// 1.0.0 - Initial release
// 1.0.1 - Bug fixes
// 1.1.0 - New features
// 2.0.0 - Breaking changes
```

### CI/CD Pipeline (GitHub Actions)
```yaml
# .github/workflows/android.yml
name: Android CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      
      - name: Grant execute permission for gradlew
        run: chmod +x gradlew
      
      - name: Build with Gradle
        run: ./gradlew build
      
      - name: Run tests
        run: ./gradlew test
      
      - name: Build Release APK
        run: ./gradlew assembleRelease
      
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: app-release
          path: app/build/outputs/apk/release/app-release.apk
```

---

## 📝 Summary Checklist for AI Agent

### Backend Preparation
- [ ] Install Laravel Sanctum
- [ ] Create all API routes in `routes/api.php`
- [ ] Create `BaseApiController.php`
- [ ] Create `AuthController.php`
- [ ] Create `DashboardController.php`
- [ ] Create `PropertyController.php` and others
- [ ] Configure CORS for mobile access
- [ ] Test all API endpoints with Postman

### Android Project Setup
- [ ] Create new Android project with Jetpack Compose
- [ ] Configure `build.gradle.kts` with all dependencies
- [ ] Add permissions to `AndroidManifest.xml`
- [ ] Create Application class with Hilt

### Architecture Implementation
- [ ] Setup Retrofit and OkHttp with interceptors
- [ ] Create Room database with all entities and DAOs
- [ ] Setup DataStore for user preferences
- [ ] Implement NetworkResult wrapper
- [ ] Create constants and utility classes

### Feature Implementation
- [ ] Implement authentication (login, register, logout)
- [ ] Implement dashboard with role-based data
- [ ] Implement property management (CRUD)
- [ ] Implement tenant management
- [ ] Implement payments and expenses
- [ ] Implement Airbnb reservations
- [ ] Implement reports and analytics

### UI/UX
- [ ] Create theme matching web design (colors, typography)
- [ ] Implement gradient header cards
- [ ] Implement stat cards with icons
- [ ] Implement navigation with NavHost
- [ ] Create all screens with Compose

### Data Synchronization
- [ ] Implement offline-first repository pattern
- [ ] Create WorkManager for background sync
- [ ] Implement conflict resolution strategy
- [ ] Add pending changes queue

### Testing & QA
- [ ] Write unit tests for repositories
- [ ] Write unit tests for ViewModels
- [ ] Write UI tests for critical flows
- [ ] Test offline functionality
- [ ] Test on multiple devices and API levels

### Security
- [ ] Implement encrypted token storage
- [ ] Add network security configuration
- [ ] Add ProGuard rules for release
- [ ] Test security vulnerabilities

### Deployment
- [ ] Configure release build variant
- [ ] Generate signing key
- [ ] Build signed AAB
- [ ] Create Play Store listing
- [ ] Upload to Play Store
- [ ] Submit for review

---

## 🎯 Expected Outcomes

After following this guide, you will have:

1. **Fully Functional Android App** with feature parity to web version
2. **Seamless Data Sync** between mobile and web platforms
3. **Offline Support** with local database caching
4. **Modern UI** matching the web application's gradient design
5. **Role-Based Access** (Admin, Landlord, Tenant roles)
6. **Production-Ready** app ready for Play Store deployment

---

## 📞 Support & Resources

### Documentation Links
- [Laravel Sanctum](https://laravel.com/docs/sanctum)
- [Jetpack Compose](https://developer.android.com/jetpack/compose)
- [Room Database](https://developer.android.com/training/data-storage/room)
- [Retrofit](https://square.github.io/retrofit/)
- [Hilt Dependency Injection](https://developer.android.com/training/dependency-injection/hilt-android)

### Estimated Timeline
- **Backend API Development**: 3-5 days
- **Android Project Setup**: 1-2 days
- **Core Features Implementation**: 10-15 days
- **UI/UX Polish**: 5-7 days
- **Testing & Bug Fixes**: 5-7 days
- **Deployment**: 2-3 days
- **Total**: 26-39 days (approximately 5-8 weeks)

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Status**: Ready for Implementation

---

## 🎉 Conclusion

This comprehensive guide provides everything needed to create a perfect Android application for the Rental Management System. The app will maintain data consistency with the web version, match its beautiful gradient design, and provide an excellent mobile user experience with offline support.

When given to an AI agent, this document contains all necessary technical details, code examples, and step-by-step instructions to implement the Android application exactly as envisioned.

