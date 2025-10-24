import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/app_config.dart';
import '../utils/logger.dart';
import '../constants/storage_keys.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  
  late Dio _dio;
  final _storage = const FlutterSecureStorage();

  // Broadcast stream to notify the app when auth is cleared (e.g., redirect to login)
  final StreamController<void> _authClearedController = StreamController<void>.broadcast();

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

  /// Stream that emits when the client clears authentication (token removal).
  Stream<void> get onAuthCleared => _authClearedController.stream;

  /// Update the API base URL to use the provided subdomain.
  /// Example: subdomain='john' -> https://john.swapdez.app/api
  /// This only updates the Dio instance's baseUrl; persistence is handled by the caller (e.g., SharedPreferences).
  void setApiSubdomain(String subdomain) {
    final newBase = 'https://$subdomain.swapdez.app/api';
    _dio.options.baseUrl = newBase;
    AppLogger.d('API base URL updated to: $newBase');
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
          AppLogger.d('Headers: ${options.headers}');
          if (options.data != null) {
            AppLogger.d('Data: ${options.data}');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          AppLogger.d(
            'RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
          );
          AppLogger.d('Response data: ${response.data}');

          // Detect redirects or HTML responses (server sending HTML login page)
          final contentType = response.headers.value('content-type') ?? '';
          final isHtml = contentType.toLowerCase().contains('text/html') ||
              (response.data is String && (response.data as String).trim().startsWith('<'));

          if (response.statusCode == 302 || isHtml) {
            AppLogger.e('Detected HTML redirect/response from API. Clearing auth and rejecting response.');
            // Clear auth - token may be expired or backend redirected to login page
            await clearToken();

            // Emit auth-cleared event
            _authClearedController.add(null);

            // Reject with a DioError so callers can handle it
            final dioError = DioError(
              requestOptions: response.requestOptions,
              response: response,
              error: 'HTML response/redirect detected (likely unauthenticated). Auth cleared.',
              type: DioErrorType.badResponse,
            );
            return handler.reject(dioError);
          }

          return handler.next(response);
        },
        onError: (error, handler) async {
          AppLogger.e(
            'ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}',
          );
          AppLogger.e('Error message: ${error.message}');
          AppLogger.e('Error response: ${error.response?.data}');

          // If the server returned HTML (e.g., redirect to login), clear token to force re-auth
          final resp = error.response;
          final contentType = resp?.headers.value('content-type') ?? '';
          final isHtml = contentType.toLowerCase().contains('text/html') ||
              (resp?.data is String && (resp?.data as String).trim().startsWith('<'));

          if (resp?.statusCode == 302 || isHtml) {
            AppLogger.e('Error response is HTML or redirect. Clearing auth token.');
            await clearToken();
            // Emit auth-cleared event
            _authClearedController.add(null);
            // Provide a clearer error message
            final dioError = DioError(
              requestOptions: error.requestOptions,
              response: error.response,
              error: 'HTML response/redirect detected (likely unauthenticated). Auth cleared.',
              type: DioErrorType.badResponse,
            );
            return handler.next(dioError);
          }

          // Handle 401 Unauthorized - token expired
          if (error.response?.statusCode == 401) {
            await clearToken();
            // Emit auth-cleared event for 401 as well
            _authClearedController.add(null);
            // Navigation to login should be handled by the app
          }
          
          return handler.next(error);
        },
      ),
    );
  }
  
  Dio get dio => _dio;
  
  // Token management
  Future<void> setToken(String token) async {
    await _storage.write(key: StorageKeys.authToken, value: token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
    // Debug log (mask token for safety)
    try {
      final visible = token.length > 10 ? token.substring(0, 6) + '...' + token.substring(token.length - 4) : token;
      AppLogger.d('Auth token set: $visible');
    } catch (_) {}
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: StorageKeys.authToken);
  }
  
  Future<void> clearToken() async {
    await _storage.delete(key: StorageKeys.authToken);
    _dio.options.headers.remove('Authorization');
    // Notify listeners that auth was cleared (covers direct calls to clearToken)
    try {
      _authClearedController.add(null);
    } catch (_) {}
  }

  // Generic GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // Generic PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}
