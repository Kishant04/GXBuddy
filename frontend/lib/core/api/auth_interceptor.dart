import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../storage/auth_token_store.dart';
import 'api_exception.dart';

/// Attaches auth headers to every outgoing request.
///
/// Priority:
/// 1. `Authorization: Bearer <token>` when a JWT is stored (production).
/// 2. `X-Dev-User-Id: <uuid>` in debug builds when no JWT is available —
///    the backend accepts this when DEBUG=true, removing the need for
///    manual credential entry during development.
class AuthInterceptor extends Interceptor {
  const AuthInterceptor(this._store);

  final AuthTokenStore _store;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _store.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else if (kDebugMode && AppConfig.devUserId.isNotEmpty) {
      options.headers['X-Dev-User-Id'] = AppConfig.devUserId;
    }

    final resetKey = _store.demoResetKey;
    if (resetKey != null && resetKey.isNotEmpty) {
      options.headers['X-Demo-Reset-Key'] = resetKey;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const UnauthorizedException(),
        ),
      );
    } else {
      handler.next(err);
    }
  }
}
