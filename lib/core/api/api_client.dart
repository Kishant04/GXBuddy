import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'api_exceptions.dart';

class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(_authInterceptor());
  }

  late final Dio _dio;
  String? _accessToken;

  void setToken(String token) => _accessToken = token;
  void clearToken() => _accessToken = null;

  Interceptor _authInterceptor() => InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: const UnauthorizedException(),
              ),
            );
          } else {
            handler.next(error);
          }
        },
      );

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.get(path, queryParameters: queryParameters);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.post(path, data: data);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  ApiException _wrap(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return NetworkException(e.message ?? 'No internet connection');
    }
    final code = e.response?.statusCode;
    final msg = e.response?.data?['detail'] as String? ?? e.message ?? 'Unexpected error';
    return ApiException(msg, statusCode: code);
  }
}
