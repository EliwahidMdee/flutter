# Flutter App Code Examples
## Complete Implementation Snippets

This document provides complete, ready-to-use code examples for implementing the Rental Management mobile app.

---

## Table of Contents

1. [API Client Implementation](#api-client-implementation)
2. [Data Models](#data-models)
3. [Repositories](#repositories)
4. [Providers (State Management)](#providers-state-management)
5. [Screen Examples](#screen-examples)
6. [Common Widgets](#common-widgets)
7. [Utility Functions](#utility-functions)

---

## API Client Implementation

### Complete API Client with Error Handling

**File:** `lib/core/network/api_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/app_config.dart';
import '../utils/logger.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  
  late Dio _dio;
  final _storage = const FlutterSecureStorage();
  
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          AppLogger.d('REQUEST[${options.method}] => ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.d('RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          AppLogger.e('ERROR[${error.response?.statusCode}] => ${error.message}');
          
          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            await clearToken();
            // Navigate to login - implement based on your navigation
          }
          
          return handler.next(error);
        },
      ),
    );
  }
  
  Dio get dio => _dio;
  
  Future<void> setToken(String token) async {
    await _storage.write(key: AppConfig.tokenKey, value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: AppConfig.tokenKey);
  }
  
  Future<void> clearToken() async {
    await _storage.delete(key: AppConfig.tokenKey);
  }
  
  // Generic GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic PUT request
  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic DELETE request
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      rethrow;
    }
  }
}
```

---

## Data Models

### User Model with Role Support

**File:** `lib/data/models/user_model.dart`

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
  @JsonKey(name: 'created_at')
  final String? createdAt;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.firstName,
    this.lastName,
    this.roles,
    this.createdAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  // Computed properties
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return name;
  }
  
  String? get primaryRole => roles?.first.name;
  
  bool hasRole(String roleName) {
    return roles?.any((role) => role.name == roleName) ?? false;
  }
  
  bool get isAdmin => hasRole('admin');
  bool get isLandlord => hasRole('landlord');
  bool get isTenant => hasRole('tenant');
  
  String? get profileImageUrl {
    if (profilePicture == null) return null;
    return '${AppConfig.apiBaseUrl.replaceAll('/api', '')}/storage/$profilePicture';
  }
}

@JsonSerializable()
class RoleModel {
  final int id;
  final String name;
  @JsonKey(name: 'display_name')
  final String? displayName;
  
  RoleModel({
    required this.id,
    required this.name,
    this.displayName,
  });
  
  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      _$RoleModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$RoleModelToJson(this);
}
```

### Payment Model

**File:** `lib/data/models/payment_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel {
  final int id;
  @JsonKey(name: 'tenant_id')
  final int tenantId;
  @JsonKey(name: 'property_id')
  final int? propertyId;
  final double amount;
  @JsonKey(name: 'payment_date')
  final String paymentDate;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  final String status;  // pending, paid, rejected
  final String? notes;
  @JsonKey(name: 'created_at')
  final String createdAt;
  
  // Relationships
  final TenantModel? tenant;
  final PropertyModel? property;
  
  PaymentModel({
    required this.id,
    required this.tenantId,
    this.propertyId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.status,
    this.notes,
    required this.createdAt,
    this.tenant,
    this.property,
  });
  
  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
  
  // Helpers
  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isRejected => status == 'rejected';
  
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending Approval';
      case 'paid':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status.toUpperCase();
    }
  }
  
  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

@JsonSerializable()
class TenantModel {
  final int id;
  final String name;
  final String? email;
  
  TenantModel({required this.id, required this.name, this.email});
  
  factory TenantModel.fromJson(Map<String, dynamic> json) =>
      _$TenantModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$TenantModelToJson(this);
}

@JsonSerializable()
class PropertyModel {
  final int id;
  final String name;
  final String? address;
  
  PropertyModel({required this.id, required this.name, this.address});
  
  factory PropertyModel.fromJson(Map<String, dynamic> json) =>
      _$PropertyModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$PropertyModelToJson(this);
}
```

After creating models, run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Repositories

### Payment Repository

**File:** `lib/data/repositories/payment_repository.dart`

```dart
import '../models/payment_model.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class PaymentRepository {
  final ApiClient _client;
  
  PaymentRepository(this._client);
  
  Future<List<PaymentModel>> getPayments({
    String? status,
    int? tenantId,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (status != null) queryParams['status'] = status;
    if (tenantId != null) queryParams['tenant_id'] = tenantId;
    
    final response = await _client.get(
      ApiEndpoints.payments,
      queryParameters: queryParams,
    );
    
    final data = response.data['data'] as List;
    return data.map((json) => PaymentModel.fromJson(json)).toList();
  }
  
  Future<List<PaymentModel>> getPendingPayments() async {
    final response = await _client.get(ApiEndpoints.pendingPayments);
    final data = response.data['data'] as List;
    return data.map((json) => PaymentModel.fromJson(json)).toList();
  }
  
  Future<PaymentModel> getPaymentById(int id) async {
    final response = await _client.get(ApiEndpoints.paymentDetail(id));
    return PaymentModel.fromJson(response.data['data']);
  }
  
  Future<PaymentModel> createPayment({
    required int tenantId,
    required int propertyId,
    required double amount,
    required String paymentDate,
    required String paymentMethod,
    String? notes,
  }) async {
    final response = await _client.post(
      ApiEndpoints.payments,
      data: {
        'tenant_id': tenantId,
        'property_id': propertyId,
        'amount': amount,
        'payment_date': paymentDate,
        'payment_method': paymentMethod,
        if (notes != null) 'notes': notes,
      },
    );
    
    return PaymentModel.fromJson(response.data['data']);
  }
  
  Future<PaymentModel> verifyPayment(int paymentId) async {
    final response = await _client.post(
      ApiEndpoints.verifyPayment(paymentId),
    );
    
    return PaymentModel.fromJson(response.data['data']);
  }
  
  Future<void> deletePayment(int paymentId) async {
    await _client.delete(ApiEndpoints.paymentDetail(paymentId));
  }
}
```

---

## Providers (State Management)

### Auth Provider

**File:** `lib/presentation/auth/providers/auth_provider.dart`

```dart
import 'package:flutter/foundation.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  
  AuthProvider(this._repository);
  
  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  
  // Check auth status on app start
  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();
    
    try {
      final isLoggedIn = await _repository.isLoggedIn();
      
      if (isLoggedIn) {
        _user = await _repository.getCachedUser();
        
        if (_user != null) {
          // Try to fetch fresh user data
          try {
            _user = await _repository.getCurrentUser();
          } catch (e) {
            // Use cached data if API fails
            debugPrint('Using cached user data: $e');
          }
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _user = await _repository.login(
        email: email,
        password: password,
      );
      
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return false;
    }
  }
  
  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _user = await _repository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      await _repository.logout();
    } finally {
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    }
  }
  
  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      _user = await _repository.updateProfile(
        name: name,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  String _extractErrorMessage(dynamic error) {
    final errorStr = error.toString();
    
    // Extract message from Exception: message format
    if (errorStr.startsWith('Exception: ')) {
      return errorStr.replaceFirst('Exception: ', '');
    }
    
    return errorStr;
  }
}
```

### Payment Provider

**File:** `lib/presentation/common/providers/payment_provider.dart`

```dart
import 'package:flutter/foundation.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/repositories/payment_repository.dart';

enum PaymentViewStatus { initial, loading, loaded, error }

class PaymentProvider with ChangeNotifier {
  final PaymentRepository _repository;
  
  PaymentViewStatus _status = PaymentViewStatus.initial;
  List<PaymentModel> _payments = [];
  List<PaymentModel> _pendingPayments = [];
  String? _error;
  
  PaymentProvider(this._repository);
  
  // Getters
  PaymentViewStatus get status => _status;
  List<PaymentModel> get payments => _payments;
  List<PaymentModel> get pendingPayments => _pendingPayments;
  String? get error => _error;
  bool get isLoading => _status == PaymentViewStatus.loading;
  
  // Fetch all payments
  Future<void> fetchPayments({String? status, int? tenantId}) async {
    _status = PaymentViewStatus.loading;
    notifyListeners();
    
    try {
      _payments = await _repository.getPayments(
        status: status,
        tenantId: tenantId,
      );
      _status = PaymentViewStatus.loaded;
      _error = null;
    } catch (e) {
      _status = PaymentViewStatus.error;
      _error = e.toString();
    }
    
    notifyListeners();
  }
  
  // Fetch pending payments
  Future<void> fetchPendingPayments() async {
    try {
      _pendingPayments = await _repository.getPendingPayments();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Approve payment
  Future<bool> approvePayment(int paymentId) async {
    try {
      await _repository.verifyPayment(paymentId);
      
      // Refresh lists
      await Future.wait([
        fetchPayments(),
        fetchPendingPayments(),
      ]);
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Create payment
  Future<bool> createPayment({
    required int tenantId,
    required int propertyId,
    required double amount,
    required String paymentDate,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      await _repository.createPayment(
        tenantId: tenantId,
        propertyId: propertyId,
        amount: amount,
        paymentDate: paymentDate,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      
      await fetchPayments();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

---

## Screen Examples

### Admin Dashboard Screen

**File:** `lib/presentation/admin/dashboard/admin_dashboard_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/providers/dashboard_provider.dart';
import '../../common/widgets/dashboard_card.dart';
import '../../common/widgets/loading_indicator.dart';
import '../../common/widgets/error_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<DashboardProvider>().fetchDashboardData();
        },
        child: Consumer<DashboardProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.stats == null) {
              return const Center(child: LoadingIndicator());
            }
            
            if (provider.error != null && provider.stats == null) {
              return ErrorDisplayWidget(
                message: provider.error!,
                onRetry: () => provider.fetchDashboardData(),
              );
            }
            
            final stats = provider.stats;
            if (stats == null) {
              return const Center(child: Text('No data available'));
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Text(
                    'Welcome back, Admin!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  
                  // Stats cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      DashboardCard(
                        title: 'Total Properties',
                        value: stats.totalProperties.toString(),
                        icon: Icons.apartment,
                        color: Colors.blue,
                      ),
                      DashboardCard(
                        title: 'Active Tenants',
                        value: stats.activeTenants.toString(),
                        icon: Icons.people,
                        color: Colors.green,
                      ),
                      DashboardCard(
                        title: 'Pending Payments',
                        value: stats.pendingPayments.toString(),
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                      DashboardCard(
                        title: 'Monthly Revenue',
                        value: '\$${stats.monthlyRevenue.toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent activities section
                  Text(
                    'Recent Activities',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  
                  // Activity list
                  ...List.generate(
                    stats.recentActivities?.length ?? 0,
                    (index) {
                      final activity = stats.recentActivities![index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            _getActivityIcon(activity.type),
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(activity.title),
                          subtitle: Text(activity.description),
                          trailing: Text(activity.timeAgo),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payment;
      case 'tenant':
        return Icons.person_add;
      case 'property':
        return Icons.home_work;
      default:
        return Icons.info;
    }
  }
}
```

### Make Payment Screen (Tenant)

**File:** `lib/presentation/tenant/payments/make_payment_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../common/providers/payment_provider.dart';
import '../../auth/providers/auth_provider.dart';

class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({Key? key}) : super(key: key);

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _paymentMethod = 'bank_transfer';
  DateTime _selectedDate = DateTime.now();
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = context.read<AuthProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    final success = await paymentProvider.createPayment(
      tenantId: authProvider.user!.id,
      propertyId: 1, // Get from lease data
      amount: double.parse(_amountController.text),
      paymentDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      paymentMethod: _paymentMethod,
    );
    
    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentProvider.error ?? 'Failed to submit payment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  helperText: 'Enter the payment amount',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Payment date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Payment Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Payment method
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'bank_transfer',
                    child: Text('Bank Transfer'),
                  ),
                  DropdownMenuItem(
                    value: 'cash',
                    child: Text('Cash'),
                  ),
                  DropdownMenuItem(
                    value: 'check',
                    child: Text('Check'),
                  ),
                  DropdownMenuItem(
                    value: 'mobile_money',
                    child: Text('Mobile Money'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Submit button
              ElevatedButton(
                onPressed: _submitPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  'Submit Payment',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Common Widgets

### Dashboard Card Widget

**File:** `lib/presentation/common/widgets/dashboard_card.dart`

```dart
import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Loading Indicator

**File:** `lib/presentation/common/widgets/loading_indicator.dart`

```dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
```

### Error Display Widget

**File:** `lib/presentation/common/widgets/error_widget.dart`

```dart
import 'package:flutter/material.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplayWidget({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## Utility Functions

### Validators

**File:** `lib/core/utils/validators.dart`

```dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a number';
    }
    
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }
  
  static String? validatePositiveNumber(String? value) {
    final numberValidation = validateNumber(value);
    if (numberValidation != null) return numberValidation;
    
    if (double.parse(value!) <= 0) {
      return 'Please enter a positive number';
    }
    
    return null;
  }
}
```

### Formatters

**File:** `lib/core/utils/formatters.dart`

```dart
import 'package:intl/intl.dart';

class AppFormatters {
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }
  
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(date);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }
  
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
  
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
  
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays >= 730 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays >= 60 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
```

---

This completes the code examples. For additional implementation details, refer to:
- The main guide: `FLUTTER_APP_DEVELOPMENT_GUIDE.md`
- API Integration guide: `API_INTEGRATION_GUIDE.md`
- UI Components guide: `UI_COMPONENTS_GUIDE.md`

