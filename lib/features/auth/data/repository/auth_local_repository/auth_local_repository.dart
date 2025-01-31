import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/sync_hive_model.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/auth_entity.dart';

import '../../../../../app/services/sync_service.dart';
import '../../../../../core/common/internet_checker.dart';
import '../../../../../core/errors/exceptions.dart' as core_exceptions;
import '../../../../../core/errors/failures.dart';
import '../../../domain/repository/auth_repository.dart';
import '../../data_source/local_data_source/auth_local_datasource.dart';

class AuthLocalRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final SyncService _syncService;
  static const String entityType = 'auth';

  AuthLocalRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
    required SyncService syncService,
  })  : _localDataSource = localDataSource,
        _networkInfo = networkInfo,
        _syncService = syncService;

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
  }) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        throw const core_exceptions.NetworkException('No internet connection');
      }

      return _handleSync<AuthEntity>(
        action: () => _localDataSource.login(
          email: email,
          password: password,
          userType: userType,
        ),
        toJson: _entityToJson,
        operation: SyncOperation.update,
        id: email,
      );
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
      // Validate email
      if (!AuthEntity.isValidEmail(email)) {
        return const Left(ValidationFailure('Invalid email format'));
      }

      // Validate password
      if (!AuthEntity.isValidPassword(password)) {
        return const Left(ValidationFailure(
            'Password must be at least 8 characters with letters and numbers'));
      }

      // Normalize role
      final normalizedRole = _normalizeRole(userType);

      // Prepare additional info with role-specific details
      final processedAdditionalInfo = additionalInfo ?? {};

      // Add restaurant-specific details if applicable
      if (normalizedRole == 'restaurant') {
        _validateRestaurantData(
          restaurantName: restaurantName,
          location: location,
          contactNumber: contactNumber,
        );

        processedAdditionalInfo['restaurant'] = {
          'name': restaurantName,
          'location': location,
          'contactNumber': contactNumber,
        };
      }

      // Generate username if not provided
      final processedUsername =
          username ?? _generateUsername(email, normalizedRole);

      // Prepare user profile
      final profile = UserProfile(
        username: processedUsername,
        phoneNumber: phoneNumber,
        additionalInfo: processedAdditionalInfo,
      );

      // Prepare metadata
      final metadata = AuthMetadata(
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        securitySettings: const {},
      );

      // Prepare registration data for sync
      final registrationData = {
        'email': email,
        'username': processedUsername,
        'role': normalizedRole,
        'password': password,
        if (normalizedRole == 'restaurant') ...{
          'restaurantName': restaurantName,
          'location': location,
          'contactNumber': contactNumber,
        }
      };

      // Register locally and queue for sync
      return _handleSync<AuthEntity>(
        action: () => _localDataSource.register(
          email: email,
          password: password,
          userType: normalizedRole,
          profile: profile,
          metadata: metadata,
        ),
        toJson: (_) => registrationData,
        operation: SyncOperation.create,
      );
    } catch (e) {
      // Comprehensive error handling
      if (e is core_exceptions.ValidationException) {
        return Left(ValidationFailure(e.message));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

// Normalize role method
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

// Generate username method
  String _generateUsername(String email, String role) {
    if (role == 'restaurant') {
      // For restaurant, you might want a different username generation logic
      return email.split('@').first;
    }
    return email.split('@').first;
  }

// Validate restaurant data method
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

      final isValid = await _localDataSource.verifyPassword(
        userId,
        currentPassword,
      );

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
}
