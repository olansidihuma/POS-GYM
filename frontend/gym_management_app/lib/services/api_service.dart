import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  String? _token;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            await _handleUnauthorized();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> setToken(String? token) async {
    _token = token;
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.authTokenKey, token);
    }
  }

  Future<void> _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.userDataKey);
    _token = null;
    // Navigate to login will be handled by AuthController
  }

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
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

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
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

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
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

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
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    String fieldName = 'file',
  }) async {
    try {
      FormData formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?data,
      });

      return await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return _extractErrorMessage(error.response);
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return 'Network error. Please try again.';
    }
  }

  String _extractErrorMessage(Response? response) {
    if (response == null) return 'Unknown error occurred.';
    
    try {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] ?? 
               data['error'] ?? 
               'Error: ${response.statusCode}';
      }
      return 'Error: ${response.statusCode}';
    } catch (e) {
      return 'Error: ${response.statusCode}';
    }
  }
}
