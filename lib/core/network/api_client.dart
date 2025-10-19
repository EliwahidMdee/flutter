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
          AppLogger.d('Headers: ${options.headers}');
          if (options.data != null) {
            AppLogger.d('Data: ${options.data}');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.d(
            'RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
          );
          AppLogger.d('Response data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          AppLogger.e(
            'ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}',
          );
          AppLogger.e('Error message: ${error.message}');
          AppLogger.e('Error response: ${error.response?.data}');
          
          // Handle 401 Unauthorized - token expired
          if (error.response?.statusCode == 401) {
            await clearToken();
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
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: StorageKeys.authToken);
  }
  
  Future<void> clearToken() async {
    await _storage.delete(key: StorageKeys.authToken);
    _dio.options.headers.remove('Authorization');
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
