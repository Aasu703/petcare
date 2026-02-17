import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/core/services/storage/token_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenService: ref.read(tokenServiceProvider));
});

class ApiClient {
  final TokenService? _tokenService;
  late final Dio _dio;

  ApiClient({TokenService? tokenService}) : _tokenService = tokenService {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors if needed (e.g., for logging, authentication)
    _dio.interceptors.add(_AuthInterceptor(tokenService: _tokenService));

    // Auto retry on network errors
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        // Retry on DioErrorType.other which includes network errors
        retryEvaluator: (error, attempt) {
          return error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError;
        },
      ),
    );

    // Only add logger in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          request: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  // Get Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  // Post Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Put Request

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Delete Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Multipart Request (e.g., for file uploads)
  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    return _dio.post(
      path,
      data: formData,
      options: options,
      onSendProgress: onSendProgress,
    );
  }
}

// Auth interceptor to add token to headers
class _AuthInterceptor extends Interceptor {
  final TokenService? _tokenService;

  _AuthInterceptor({TokenService? tokenService}) : _tokenService = tokenService;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    final publicEndpoints = [ApiEndpoints.userLogin, ApiEndpoints.userRegister];
    final isPublicEndpoint =
        publicEndpoints.any((endpoint) => options.path.startsWith(endpoint));

    if (!isPublicEndpoint) {
      final token = _tokenService != null
          ? await _tokenService.getToken()
          : (await SharedPreferences.getInstance()).getString('auth_token');
      if (token != null && token.isNotEmpty) {
        final bearerToken =
            token.startsWith('Bearer ') ? token : 'Bearer $token';
        options.headers['Authorization'] = bearerToken;
        print('Added token for request to ${options.path}');
      } else {
        print('No token found for request to ${options.path}');
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle unauthorized errors (e.g., token expired)
    if (err.response?.statusCode == 401) {
      if (_tokenService != null) {
        _tokenService.deleteToken();
      } else {
        SharedPreferences.getInstance().then((prefs) {
          prefs.remove('auth_token');
        });
      }
    }
    handler.next(err);
  }
}
