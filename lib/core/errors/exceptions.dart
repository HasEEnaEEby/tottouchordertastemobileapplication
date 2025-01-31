abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => statusCode != null
      ? 'Status Code: $statusCode, Message: $message'
      : message;
}

class AuthException extends AppException {
  const AuthException(super.message, [super.statusCode]);

  factory AuthException.unauthorized() =>
      const AuthException('Unauthorized access', 401);

  factory AuthException.invalidCredentials() =>
      const AuthException('Invalid credentials', 401);

  factory AuthException.tokenExpired() =>
      const AuthException('Token has expired', 401);

  factory AuthException.emailNotVerified() =>
      const AuthException('Email not verified', 403);
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.statusCode]);

  factory NetworkException.noConnection() =>
      const NetworkException('No internet connection', 503);

  factory NetworkException.timeout() =>
      const NetworkException('Connection timeout', 408);

  factory NetworkException.requestCancelled() =>
      const NetworkException('Request cancelled', 499);
}

class CacheException extends AppException {
  const CacheException(super.message, [super.statusCode]);

  factory CacheException.notFound() =>
      const CacheException('Data not found in cache', 404);

  factory CacheException.invalidData() =>
      const CacheException('Invalid data format in cache', 400);
}

class ValidationException extends AppException {
  const ValidationException(super.message, [super.statusCode]);

  factory ValidationException.invalidEmail() =>
      const ValidationException('Invalid email format', 400);

  factory ValidationException.invalidPassword() =>
      const ValidationException('Invalid password format', 400);

  factory ValidationException.missingFields(String field) =>
      ValidationException('Required field missing: $field', 400);
}

class ServerException extends AppException {
  const ServerException(super.message, int super.statusCode);

  factory ServerException.internalError() =>
      const ServerException('Internal server error', 500);

  factory ServerException.badRequest(String message) =>
      ServerException(message, 400);

  factory ServerException.notFound() =>
      const ServerException('Resource not found', 404);

  factory ServerException.serviceUnavailable() =>
      const ServerException('Service temporarily unavailable', 503);
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.statusCode]);

  factory DatabaseException.connectionError() =>
      const DatabaseException('Database connection error', 503);

  factory DatabaseException.duplicateEntry() =>
      const DatabaseException('Duplicate entry', 409);
}

// New exceptions for specific scenarios
class SyncException extends AppException {
  const SyncException(super.message, [super.statusCode]);

  factory SyncException.syncFailed() =>
      const SyncException('Sync operation failed', 500);

  factory SyncException.conflictDetected() =>
      const SyncException('Data conflict detected', 409);
}

class FileException extends AppException {
  const FileException(super.message, [super.statusCode]);

  factory FileException.uploadFailed() =>
      const FileException('File upload failed', 500);

  factory FileException.invalidFormat() =>
      const FileException('Invalid file format', 400);

  factory FileException.sizeLimitExceeded() =>
      const FileException('File size limit exceeded', 413);
}
