import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';

/// Base Exception class used throughout the app.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, [this.statusCode]);

  @override
  String toString() => statusCode != null
      ? 'Status Code: $statusCode, Message: $message'
      : message;
}

/// Authentication related exceptions.
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

/// Network-related exceptions.
class NetworkException extends AppException {
  const NetworkException(super.message, [super.statusCode]);

  factory NetworkException.noConnection() =>
      const NetworkException('No internet connection', 503);

  factory NetworkException.timeout() =>
      const NetworkException('Connection timeout', 408);

  factory NetworkException.requestCancelled() =>
      const NetworkException('Request cancelled', 499);
}

/// Cache-related exceptions.
class CacheException extends AppException {
  const CacheException(super.message, [super.statusCode]);

  factory CacheException.notFound() =>
      const CacheException('Data not found in cache', 404);

  factory CacheException.invalidData() =>
      const CacheException('Invalid data format in cache', 400);
}

/// Validation exceptions.
class ValidationException extends AppException {
  const ValidationException(super.message, [super.statusCode]);

  factory ValidationException.invalidEmail() =>
      const ValidationException('Invalid email format', 400);

  factory ValidationException.invalidPassword() =>
      const ValidationException('Invalid password format', 400);

  factory ValidationException.missingFields(String field) =>
      ValidationException('Required field missing: $field', 400);
}

/// Server exceptions.
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

/// Database exceptions.
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.statusCode]);

  factory DatabaseException.connectionError() =>
      const DatabaseException('Database connection error', 503);

  factory DatabaseException.duplicateEntry() =>
      const DatabaseException('Duplicate entry', 409);
}

/// Sync exceptions.
class SyncException extends AppException {
  const SyncException(super.message, [super.statusCode]);

  factory SyncException.syncFailed() =>
      const SyncException('Sync operation failed', 500);

  factory SyncException.conflictDetected() =>
      const SyncException('Data conflict detected', 409);
}

/// File-related exceptions.
class FileException extends AppException {
  const FileException(super.message, [super.statusCode]);

  factory FileException.uploadFailed() =>
      const FileException('File upload failed', 500);

  factory FileException.invalidFormat() =>
      const FileException('Invalid file format', 400);

  factory FileException.sizeLimitExceeded() =>
      const FileException('File size limit exceeded', 413);
}

/// Optionally, you can add a helper to map exceptions to failures:
Failure mapExceptionToFailure(Exception e) {
  if (e is AuthException) {
    return AuthFailure(e.message);
  } else if (e is NetworkException) {
    return NetworkFailure(e.message);
  } else if (e is CacheException) {
    return CacheFailure(e.message);
  } else if (e is ValidationException) {
    return ValidationFailure(e.message);
  } else if (e is ServerException) {
    return ServerFailure(e.message);
  } else if (e is DatabaseException) {
    return DatabaseFailure(e.message);
  } else if (e is SyncException) {
    return ServerFailure(e.message); // Or create a specific SyncFailure.
  } else if (e is FileException) {
    return ServerFailure(e.message); // Or create a specific FileFailure.
  }
  return const ServerFailure('Unexpected error occurred');
}
