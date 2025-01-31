import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../../../../../app/constants/api_endpoints.dart';
import '../../../../../core/common/internet_checker.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../domain/entity/auth_entity.dart';
import '../../model/auth_api_model.dart';
import '../auth_data_source.dart';

class AuthRemoteDataSource implements IAuthDataSource {
  final Dio _dio;
  final NetworkInfo _networkInfo;
  final Logger _logger = Logger('AuthRemoteDataSource');

  AuthRemoteDataSource({
    required Dio dio,
    required NetworkInfo networkInfo,
  })  : _dio = dio,
        _networkInfo = networkInfo;

  @override
  Future<AuthEntity> login({
    required String email,
    required String password,
    required String userType,
    String? adminCode,
  }) async {
    try {
      await _checkConnection();

      final response = await _dio.post(
        userType == 'admin' ? ApiEndpoints.adminLogin : ApiEndpoints.login,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
          'role': userType,
          if (adminCode != null) 'adminCode': adminCode,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final authModel = AuthApiModel.fromJson(response.data['data']);
        _updateAuthToken(authModel);
        return authModel.toEntity();
      } else {
        throw AuthException.invalidCredentials();
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw _handleError(e);
    }
  }

  @override
  Future<AuthEntity> register({
    required String email,
    required String password,
    required String userType,
    required String username,
    String? restaurantName,
    String? location,
    String? contactNumber,
    String? quote,
  }) async {
    try {
      await _checkConnection();

      final data = {
        'email': email.trim().toLowerCase(),
        'password': password,
        'role': userType,
        'username': username,
        if (restaurantName != null) 'restaurantName': restaurantName,
        if (location != null) 'location': location,
        if (contactNumber != null) 'contactNumber': contactNumber,
        if (quote != null) 'quote': quote,
      };

      final response = await _dio.post(
        userType == 'admin' ? ApiEndpoints.adminRegister : ApiEndpoints.signup,
        data: data,
      );

      if (response.statusCode == 201 && response.data['data'] != null) {
        final authModel = AuthApiModel.fromJson(response.data['data']);
        _updateAuthToken(authModel);
        return authModel.toEntity();
      } else {
        throw ServerException.badRequest('Registration failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw _handleError(e);
    }
  }

  @override
  Future<bool> verifyEmail(String token) async {
    try {
      await _checkConnection();

      final response = await _dio.get('${ApiEndpoints.verifyEmail}/$token');

      if (response.statusCode == 200) {
        return true;
      }
      throw AuthException('Email verification failed', response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw _handleError(e);
    }
  }

  @override
  Future<bool> resendVerification(String email) async {
    try {
      await _checkConnection();

      final response = await _dio.post(
        ApiEndpoints.resendVerification,
        data: {'email': email.trim().toLowerCase()},
      );

      if (response.statusCode == 200) {
        return true;
      }
      throw ServerException.badRequest('Failed to resend verification email');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw _handleError(e);
    }
  }

  @override
  Future<AuthEntity> refreshToken(String refreshToken) async {
    try {
      await _checkConnection();

      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final authModel = AuthApiModel.fromJson(response.data['data']);
        _updateAuthToken(authModel);
        return authModel.toEntity();
      } else {
        throw AuthException.tokenExpired();
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw _handleError(e);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _checkConnection();

      final response = await _dio.post(ApiEndpoints.logout);

      if (response.statusCode == 200) {
        _clearAuthToken();
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw _handleError(e);
    }
  }

  @override
  Future<AuthEntity> getProfile() async {
    try {
      await _checkConnection();

      final response = await _dio.get(ApiEndpoints.profile);

      if (response.statusCode == 200 && response.data['data'] != null) {
        final authModel = AuthApiModel.fromJson(response.data['data']['user']);
        return authModel.toEntity();
      } else {
        throw AuthException.unauthorized();
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw _handleError(e);
    }
  }

  @override
  Future<AuthEntity> updateProfile(Map<String, dynamic> profileData) async {
    try {
      await _checkConnection();

      final response = await _dio.patch(
        ApiEndpoints.updateProfile,
        data: profileData,
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final authModel = AuthApiModel.fromJson(response.data['data']['user']);
        return authModel.toEntity();
      } else {
        throw ServerException.badRequest('Profile update failed');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw _handleError(e);
    }
  }

  @override
  Future<String> uploadProfilePicture(File image) async {
    try {
      await _checkConnection();

      if (await image.length() > 5 * 1024 * 1024) {
        throw FileException.sizeLimitExceeded();
      }

      final extension = image.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        throw FileException.invalidFormat();
      }

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        ApiEndpoints.uploadImage,
        data: formData,
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return response.data['data']['imageUrl'];
      }
      throw FileException.uploadFailed();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw _handleError(e);
    }
  }

  // Helper methods
  Future<void> _checkConnection() async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException.noConnection();
    }
  }

  void _updateAuthToken(AuthApiModel authModel) {
    if (authModel.token == null || authModel.token!.isEmpty) {
      throw const AuthException('Invalid authentication token', 401);
    }
    _dio.options.headers['Authorization'] = 'Bearer ${authModel.token}';
    _logger.info('Authentication token updated');
  }

  void _clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    _logger.info('Authentication token cleared');
  }

  AppException _handleDioError(DioException error) {
    _logger.severe('API Error', error);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException.timeout();
      case DioExceptionType.cancel:
        return NetworkException.requestCancelled();
      default:
        break;
    }

    final statusCode = error.response?.statusCode ?? 500;
    final message = error.response?.data?['message'] ??
        error.message ??
        'An unexpected error occurred';

    switch (statusCode) {
      case 400:
        if (message.toLowerCase().contains('email')) {
          return ValidationException.invalidEmail();
        }
        if (message.toLowerCase().contains('password')) {
          return ValidationException.invalidPassword();
        }
        return ServerException.badRequest(message);

      case 401:
        if (message.toLowerCase().contains('token')) {
          return AuthException.tokenExpired();
        }
        return AuthException.invalidCredentials();

      case 403:
        if (message.toLowerCase().contains('verify')) {
          return AuthException.emailNotVerified();
        }
        return AuthException('Access forbidden', statusCode);

      case 404:
        return ServerException.notFound();

      case 413:
        return FileException.sizeLimitExceeded();

      case 503:
        return ServerException.serviceUnavailable();

      default:
        return ServerException(message, statusCode);
    }
  }

  AppException _handleError(dynamic error) {
    _logger.severe('Unexpected Error', error);
    return ServerException.internalError();
  }
}
