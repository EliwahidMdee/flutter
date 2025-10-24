import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/network/api_client.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  late final StreamSubscription<void> _authClearedSub;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  
  AuthProvider(this._repository) {
    // Listen to global auth-cleared events from ApiClient
    _authClearedSub = ApiClient().onAuthCleared.listen((_) {
      // When auth is cleared at the network layer, update provider state
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Session expired - please login again.';
      notifyListeners();
    });
  }

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
    String? phone,
  }) async {
    try {
      _user = await _repository.updateProfile(
        name: name,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return false;
    }
  }
  
  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
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
    
    // Extract message from DioError
    if (errorStr.contains('DioError')) {
      return 'Network error occurred. Please try again.';
    }
    
    return errorStr;
  }

  @override
  void dispose() {
    _authClearedSub.cancel();
    super.dispose();
  }
}
