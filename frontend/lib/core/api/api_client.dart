import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/auth_token_store.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

class ApiClient {
  ApiClient({required AuthTokenStore tokenStore}) {
    final options = BaseOptions(
      baseUrl: tokenStore.apiBaseUrlOverride ?? AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    _dio = Dio(options);
    _dio.interceptors.add(AuthInterceptor(tokenStore));
  }

  late final Dio _dio;

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
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.post(path, data: data, queryParameters: queryParameters);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.patch(path, data: data, queryParameters: queryParameters);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<void> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      await _dio.delete(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  ApiException _wrap(DioException err) {
    final msg = err.message ?? 'Unknown error';
    final code = err.response?.statusCode;
    final endpoint = err.requestOptions.path;
    final method = err.requestOptions.method;
    final responseBody = err.response?.data;
    final jwtUsed = err.requestOptions.headers.containsKey('Authorization');

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return NetworkException('Connection timed out. Check your backend.');
    }

    return switch (code) {
      401 => UnauthorizedException(
          endpoint: endpoint,
          method: method,
          responseBody: responseBody,
          jwtUsed: jwtUsed,
        ),
      404 => NotFoundException(
          msg,
          endpoint: endpoint,
          method: method,
          responseBody: responseBody,
          jwtUsed: jwtUsed,
        ),
      422 => ValidationException(
          msg,
          endpoint: endpoint,
          method: method,
          responseBody: responseBody,
          jwtUsed: jwtUsed,
        ),
      int c when c >= 500 => ServerException(
          msg,
          endpoint: endpoint,
          method: method,
          responseBody: responseBody,
          jwtUsed: jwtUsed,
        ),
      _ => ApiException(
          msg,
          statusCode: code,
          endpoint: endpoint,
          method: method,
          responseBody: responseBody,
          jwtUsed: jwtUsed,
        ),
    };
  }
}
