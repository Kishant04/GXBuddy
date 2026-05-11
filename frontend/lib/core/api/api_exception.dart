class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.endpoint,
    this.method,
    this.responseBody,
    this.jwtUsed = false,
  });

  final String message;
  final int? statusCode;
  final String? endpoint;
  final String? method;
  final dynamic responseBody;
  final bool jwtUsed;

  @override
  String toString() {
    final sb = StringBuffer('ApiException: $message');
    if (statusCode != null) sb.write(' (Status: $statusCode)');
    if (method != null && endpoint != null) sb.write('\n$method $endpoint');
    if (responseBody != null) sb.write('\nResponse: $responseBody');
    sb.write('\nJWT Used: $jwtUsed');
    return sb.toString();
  }
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.endpoint,
    super.method,
    super.responseBody,
    super.jwtUsed,
  }) : super('Session expired. Please log in again.', statusCode: 401);
}

class NotFoundException extends ApiException {
  const NotFoundException(
    super.message, {
    super.endpoint,
    super.method,
    super.responseBody,
    super.jwtUsed,
  }) : super(statusCode: 404);
}

class ServerException extends ApiException {
  const ServerException(
    super.message, {
    super.endpoint,
    super.method,
    super.responseBody,
    super.jwtUsed,
  }) : super(statusCode: 500);
}

class ValidationException extends ApiException {
  const ValidationException(
    super.message, {
    super.endpoint,
    super.method,
    super.responseBody,
    super.jwtUsed,
  }) : super(statusCode: 422);
}
