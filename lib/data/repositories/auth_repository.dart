import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/storage_keys.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _client;
  final SharedPreferences _prefs;
  
  AuthRepository(this._client, this._prefs);
  
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
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

    // Save token and user data
    await _client.setToken(token);
    await _prefs.setString(StorageKeys.authToken, token);
    await _prefs.setString(StorageKeys.userData, jsonEncode(user.toJson()));

    return user;
  }
  
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _client.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'device_name': 'mobile',
      },
    );

    final data = response.data['data'] ?? response.data;
    final token = data['token'];
    final user = UserModel.fromJson(data['user']);

    // Save token and user data
    await _client.setToken(token);
    await _prefs.setString(StorageKeys.authToken, token);
    await _prefs.setString(StorageKeys.userData, jsonEncode(user.toJson()));

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
    final userJson = _prefs.getString(StorageKeys.userData);
    if (userJson == null) return null;

    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _client.get(ApiEndpoints.getUser);
    final user = UserModel.fromJson(response.data['data'] ?? response.data);

    // Update cached user
    await _prefs.setString(StorageKeys.userData, jsonEncode(user.toJson()));

    return user;
  }
  
  Future<bool> isLoggedIn() async {
    final token = _prefs.getString(StorageKeys.authToken);
    return token != null && token.isNotEmpty;
  }
  
  Future<UserModel> updateProfile({
    String? name,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    final response = await _client.put(
      ApiEndpoints.updateProfile,
      data: {
        if (name != null) 'name': name,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      },
    );

    final user = UserModel.fromJson(response.data['data']);

    // Update cached user
    await _prefs.setString(StorageKeys.userData, jsonEncode(user.toJson()));

    return user;
  }
  
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _client.post(
      ApiEndpoints.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
    );
  }
  
  Future<void> _clearAuth() async {
    await _client.clearToken();
    await _prefs.remove(StorageKeys.authToken);
    await _prefs.remove(StorageKeys.userData);
    await _prefs.remove(StorageKeys.userRole);
  }
}
