import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tottouchordertastemobileapplication/app/constants/api_endpoints.dart';
import 'package:tottouchordertastemobileapplication/app/services/sync_service.dart';
import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart';
import 'package:tottouchordertastemobileapplication/core/errors/exceptions.dart'
    as core_exceptions;
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/data_source/local_data_source/auth_local_datasource.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/auth_api_model.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/sync_hive_model.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/auth_entity.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/repository/auth_repository.dart';

class AuthLocalRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  
  final SyncService _syncService;
  final Dio _dio;
  static const String entityType = 'auth';

  AuthLocalRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
    required SyncService syncService,
    required Dio dio,
  })  : _localDataSource = localDataSource,
        _networkInfo = networkInfo,
        _syncService = syncService,
        _dio = dio;

  Future<Either<Failure, T>> _handleSync<T>({
    required Future<T> Function() action,
    required Map<String, dynamic> Function(T result) toJson,
    required SyncOperation operation,
    String? id,
  }) async {
    try {
      final result = await action();

      if (result != null) {
        final syncId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
        await _syncService.queueSync(
          id: syncId,
          data: toJson(result),
          entityType: entityType,
          operation: operation,
        );
      }

      return Right(result);
    } on core_exceptions.CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on core_exceptions.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on core_exceptions.ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on core_exceptions.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Map<String, dynamic> _entityToJson(AuthEntity entity) {
    return {
      'id': entity.id,
      'email': entity.email,
      'userType': entity.userType,
      'status': entity.status.toString(),
      'profile': entity.profile.toJson(),
      'metadata': entity.metadata.toJson(),
    };
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _localDataSource.getCurrentUser();
      if (user == null) {
        return const Left(AuthFailure('No authenticated user found'));
      }
      return Right(user);
    } on core_exceptions.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
    required String userType,
    String? adminCode,
  }) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw const core_exceptions.NetworkException('No internet connection');
      }

      if (userType.toLowerCase() == 'restaurant' &&
          (adminCode == null || adminCode.isEmpty)) {
        return const Left(
            ValidationFailure('Admin code is required for restaurant login'));
      }

      final requestData = {
        'email': email.trim().toLowerCase(),
        'password': password,
        'role': userType,
        if (adminCode != null) 'adminCode': adminCode,
      };

      final response = await _dio.post(
        ApiEndpoints.login,
        data: requestData,
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final authModel = AuthApiModel.fromJson(response.data['data']);

        await _localDataSource.updateUser(authModel.toEntity());

        return Right(authModel.toEntity());
      } else {
        return const Left(AuthFailure('Login failed'));
      }
    } on core_exceptions.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> register({
    required String email,
    required String password,
    required String userType,
    String? username,
    String? phoneNumber,
    String? restaurantName,
    String? location,
    String? contactNumber,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      // Check network connection
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw const core_exceptions.NetworkException('No internet connection');
      }

      // Input validation
      if (!AuthEntity.isValidEmail(email)) {
        return const Left(ValidationFailure('Invalid email format'));
      }

      if (!AuthEntity.isValidPassword(password)) {
        return const Left(ValidationFailure(
          'Password must be at least 8 characters with letters and numbers',
        ));
      }

      // Process and validate role-specific data
      final normalizedRole = _normalizeRole(userType);
      if (normalizedRole == 'restaurant') {
        _validateRestaurantData(
          restaurantName: restaurantName,
          location: location,
          contactNumber: contactNumber,
        );
      }

      // Prepare registration data
      final registrationData = {
        'email': email.trim().toLowerCase(),
        'password': password,
        'role': normalizedRole,
        'username': username ?? email.split('@')[0],
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (normalizedRole == 'restaurant') ...{
          'restaurantName': restaurantName,
          'location': location,
          'contactNumber': contactNumber,
        },
      };

      // Make API call
      final response = await _dio.post(
        ApiEndpoints.signup,
        data: registrationData,
      );

      if (response.statusCode == 201 && response.data['data'] != null) {
        final authModel = AuthApiModel.fromJson(response.data['data']);
        return Right(authModel.toEntity());
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Registration failed',
        ));
      }
    } on core_exceptions.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on core_exceptions.ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return const Left(ValidationFailure('Email already exists'));
      }
      return Left(ServerFailure(
        e.response?.data['message'] ?? 'Registration failed',
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // --- Helper methods ---
  String _normalizeRole(String role) {
    switch (role.toLowerCase()) {
      case 'restaurant':
        return 'restaurant';
      case 'admin':
        return 'admin';
      case 'customer':
      default:
        return 'customer';
    }
  }

  String _generateUsername(String email, String role) {
    return email.split('@').first;
  }

  void _validateRestaurantData({
    String? restaurantName,
    String? location,
    String? contactNumber,
  }) {
    final errors = <String>[];
    if (restaurantName == null || restaurantName.trim().isEmpty) {
      errors.add('Restaurant name is required');
    }
    if (location == null || location.trim().isEmpty) {
      errors.add('Location is required');
    }
    if (contactNumber == null || contactNumber.trim().isEmpty) {
      errors.add('Contact number is required');
    }
    if (errors.isNotEmpty) {
      throw core_exceptions.ValidationException(errors.join(', '));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    required String userId,
    String? username,
    String? phoneNumber,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final userResult = await _localDataSource.getUserById(userId);
      if (userResult == null) {
        return const Left(AuthFailure('User not found'));
      }

      final updatedProfile = userResult.profile.copyWith(
        username: username ?? userResult.profile.username,
        phoneNumber: phoneNumber ?? userResult.profile.phoneNumber,
        additionalInfo: additionalInfo ?? userResult.profile.additionalInfo,
      );

      final updatedUser = userResult.copyWith(
        profile: updatedProfile,
        metadata: userResult.metadata.copyWith(lastUpdatedAt: DateTime.now()),
      );

      return _handleSync<void>(
        action: () => _localDataSource.updateUser(updatedUser),
        toJson: (_) => _entityToJson(updatedUser),
        operation: SyncOperation.update,
        id: userId,
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateRestaurantProfile({
    required String userId,
    String? name,
    String? location,
    String? description,
    String? contactNumber,
    String? website,
    Map<String, dynamic>? businessHours,
    List<String>? cuisine,
  }) async {
    try {
      final user = await _localDataSource.getUserById(userId);
      if (user == null) {
        return const Left(AuthFailure('User not found'));
      }
      if (user.userType != UserType.restaurant.name) {
        return const Left(AuthFailure('User is not a restaurant'));
      }
      final currentRestaurantInfo =
          user.profile.additionalInfo['restaurant'] as Map<String, dynamic>? ??
              {};
      final updatedRestaurantInfo = {
        ...currentRestaurantInfo,
        if (name != null) 'name': name,
        if (location != null) 'location': location,
        if (description != null) 'description': description,
        if (contactNumber != null) 'contactNumber': contactNumber,
        if (website != null) 'website': website,
        if (businessHours != null) 'businessHours': businessHours,
        if (cuisine != null) 'cuisine': cuisine,
      };

      final updatedProfile = user.profile.copyWith(
        additionalInfo: {
          ...user.profile.additionalInfo,
          'restaurant': updatedRestaurantInfo,
        },
      );

      final updatedUser = user.copyWith(
        profile: updatedProfile,
        metadata: user.metadata.copyWith(lastUpdatedAt: DateTime.now()),
      );

      return _handleSync<void>(
        action: () => _localDataSource.updateUser(updatedUser),
        toJson: (_) => _entityToJson(updatedUser),
        operation: SyncOperation.update,
        id: userId,
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (!AuthEntity.isValidPassword(newPassword)) {
        return const Left(ValidationFailure(
            'New password must be at least 8 characters with letters and numbers'));
      }

      final isValid =
          await _localDataSource.verifyPassword(userId, currentPassword);
      if (!isValid) {
        return const Left(AuthFailure('Current password is incorrect'));
      }

      return _handleSync<void>(
        action: () => _localDataSource.updatePassword(userId, newPassword),
        toJson: (_) => {
          'userId': userId,
          'passwordUpdated': DateTime.now().toIso8601String(),
        },
        operation: SyncOperation.update,
        id: userId,
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String userId) async {
    return _handleSync<void>(
      action: () => _localDataSource.deleteUser(userId),
      toJson: (_) => {'userId': userId},
      operation: SyncOperation.delete,
      id: userId,
    );
  }

  @override
  Future<Either<Failure, bool>> checkEmailExists(String email) async {
    try {
      final exists = await _localDataSource.emailExists(email);
      return Right(exists);
    } on core_exceptions.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final currentUser = await _localDataSource.getCurrentUser();
      if (currentUser != null) {
        await _syncService.syncPendingItems();
      }
      await _localDataSource.logout();
      return const Right(null);
    } on core_exceptions.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> syncPendingChanges() async {
    try {
      if (await _networkInfo.isConnected) {
        await _syncService.syncPendingItems();
      }
      return const Right(null);
    } on core_exceptions.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RestaurantEntity>>> getRestaurants() async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw const core_exceptions.NetworkException('No internet connection');
      }

      return _handleSync<List<RestaurantEntity>>(
        action: () async {
          final restaurants = await _localDataSource.getAllRestaurants();
          return restaurants
              .map((auth) => RestaurantEntity(
                    id: auth.id ?? '',
                    username: auth.profile.username ?? '',
                    restaurantName: auth.profile.additionalInfo['restaurant']
                            ?['name'] ??
                        '',
                    location: auth.profile.additionalInfo['restaurant']
                            ?['location'] ??
                        '',
                    contactNumber: auth.profile.additionalInfo['restaurant']
                            ?['contactNumber'] ??
                        '',
                    quote: auth.profile.additionalInfo['restaurant']
                            ?['quote'] ??
                        '',
                    status: auth.status.toString(),
                  ))
              .toList();
        },
        toJson: (restaurants) => {
          'restaurants': restaurants.map((r) => r.toJson()).toList(),
        },
        operation: SyncOperation.read,
      );
    } on core_exceptions.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on core_exceptions.CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on core_exceptions.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(
      {required String userId}) async {
    // For now, simply throw unimplemented error.
    throw UnimplementedError('getUserProfile is not implemented');
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePicture,
  }) async {
    // For now, simply throw unimplemented error.
    throw UnimplementedError('updateUserProfile is not implemented');
  }

  @override
  Future<Either<Failure, bool>> verifyEmail(String token) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw const core_exceptions.NetworkException('No internet connection');
      }

      final response = await _dio.get(
        '${ApiEndpoints.verifyEmail}$token',
      );

      if (response.statusCode == 200) {
        final currentUser = await _localDataSource.getCurrentUser();
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(
            isEmailVerified: true,
            metadata: currentUser.metadata.copyWith(
              lastUpdatedAt: DateTime.now(),
            ),
          );

          return _handleSync<bool>(
            action: () async {
              await _localDataSource.updateUser(updatedUser);
              return true;
            },
            toJson: (_) => _entityToJson(updatedUser),
            operation: SyncOperation.update,
            id: currentUser.id,
          );
        }
        return const Right(true);
      } else {
        return const Left(
            ValidationFailure('Invalid or expired verification token'));
      }
    } on core_exceptions.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return const Left(
            ValidationFailure('Invalid or expired verification token'));
      }
      return Left(ServerFailure(
          e.response?.data['message'] ?? 'Failed to verify email'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resendVerificationEmail(String email) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw const core_exceptions.NetworkException('No internet connection');
      }

      final response = await _dio.post(
        ApiEndpoints.resendVerification,
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return const Right(true);
      } else {
        final message =
            response.data['message'] ?? 'Failed to resend verification email';
        return Left(ServerFailure(message));
      }
    } on core_exceptions.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Left(ValidationFailure('Email not found'));
      }
      return Left(ServerFailure(e.response?.data['message'] ??
          'Failed to resend verification email'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
}
