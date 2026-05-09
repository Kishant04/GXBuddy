import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/auth_token_store.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

class ApiClient {
  ApiClient({required AuthTokenStore tokenStore}) {
    final baseUrl = tokenStore.apiBaseUrlOverride ?? AppConfig.apiBaseUrl;
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
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
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.post(path, data: data);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.patch(path, data: data);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
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
    final msg = e.response?.data?['detail'] as String? ??
        e.message ??
        'Unexpected error';
    return switch (code) {
      401 => const UnauthorizedException(),
      404 => NotFoundException(msg),
      422 => ValidationException(msg),
      int c when c >= 500 => ServerException(msg),
      _ => ApiException(msg, statusCode: code),
    };
  }
}
