import 'package:dio/dio.dart';
import '../storage/auth_token_store.dart';
import 'api_exception.dart';

/// Attaches `Authorization: Bearer <token>` to every outgoing request when a
/// token is present. Converts 401 responses into [UnauthorizedException].
class AuthInterceptor extends Interceptor {
  const AuthInterceptor(this._store);

  final AuthTokenStore _store;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _store.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
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
