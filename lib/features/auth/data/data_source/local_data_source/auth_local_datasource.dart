import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../../../core/network/hive_service.dart';
import '../../../domain/entity/auth_entity.dart';
import '../../model/auth_hive_model.dart';

abstract class AuthLocalDataSource {
  Future<AuthEntity> login({
    required String email,
    required String password,
    required String userType,
  });

  Future<AuthEntity> register({
    required String email,
    required String password,
    required String userType,
    required UserProfile profile,
    required AuthMetadata metadata,
  });

  Future<void> logout();
  Future<AuthEntity?> getCurrentUser();
  Future<AuthEntity?> getUserById(String userId);
  Future<AuthEntity?> getUserByEmail(String email);
  Future<void> updateUser(AuthEntity user);
  Future<void> updatePassword(String userId, String newPassword);
  Future<bool> verifyPassword(String userId, String password);
  Future<bool> emailExists(String email);
  Future<void> deleteUser(String userId);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final HiveService _hiveService;
  static const String _userBox = 'users';
  static const String _currentUserKey = 'current_user';

  AuthLocalDataSourceImpl({
    required HiveService hiveService,
  }) : _hiveService = hiveService;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<AuthEntity> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final normalizedUserType = userType.trim().toLowerCase();

      final user = await getUserByEmail(normalizedEmail);
      if (user == null) {
        throw const AuthException('User not found');
      }

      if (user.userType.toLowerCase() != normalizedUserType) {
        throw const AuthException('Invalid user type');
      }

      final hashedPassword = _hashPassword(password);
      if (user.profile.additionalInfo['hashedPassword'] != hashedPassword) {
        throw const AuthException('Invalid password');
      }

      final updatedUser = user.copyWith(
        status: AuthStatus.authenticated,
        metadata: user.metadata.copyWith(
          lastLoginAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
        ),
      );

      final authModel = AuthHiveModel.fromEntity(updatedUser);
      final currentUserModel = AuthHiveModel(
        id: authModel.id,
        email: authModel.email,
        userType: authModel.userType,
        status: authModel.status,
        profile: authModel.profile,
        metadata: authModel.metadata,
      );

      await _hiveService.saveData(_userBox, user.id!, authModel);

      await _hiveService.saveData(_userBox, _currentUserKey, currentUserModel);

      return updatedUser;
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthEntity> register({
    required String email,
    required String password,
    required String userType,
    required UserProfile profile,
    required AuthMetadata metadata,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();

      if (await emailExists(normalizedEmail)) {
        throw const AuthException('Email already exists');
      }

      final hashedPassword = _hashPassword(password);
      final userId = DateTime.now().millisecondsSinceEpoch.toString();

      final updatedProfile = profile.copyWith(
        additionalInfo: {
          ...profile.additionalInfo,
          'hashedPassword': hashedPassword,
        },
      );

      final user = AuthEntity(
        id: userId,
        email: normalizedEmail,
        userType: userType.trim().toLowerCase(),
        status: AuthStatus.authenticated,
        profile: updatedProfile,
        metadata: metadata.copyWith(
          createdAt: DateTime.now(),
        ),
      );

      final authModel = AuthHiveModel.fromEntity(user);
      final currentUserModel = AuthHiveModel(
        id: authModel.id,
        email: authModel.email,
        userType: authModel.userType,
        status: authModel.status,
        profile: authModel.profile,
        metadata: authModel.metadata,
      );

      await _hiveService.saveData(_userBox, userId, authModel);

      await _hiveService.saveData(_userBox, _currentUserKey, currentUserModel);

      return user;
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _hiveService.deleteData(_userBox, _currentUserKey);
    } catch (e) {
      throw AuthException('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthEntity?> getCurrentUser() async {
    try {
      final authModel =
          await _hiveService.getData<AuthHiveModel>(_userBox, _currentUserKey);
      return authModel?.toEntity();
    } catch (e) {
      throw AuthException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<AuthEntity?> getUserById(String userId) async {
    try {
      final authModel =
          await _hiveService.getData<AuthHiveModel>(_userBox, userId);
      return authModel?.toEntity();
    } catch (e) {
      throw AuthException('User not found: ${e.toString()}');
    }
  }

  @override
  Future<AuthEntity?> getUserByEmail(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final users = await _hiveService.getAllData<AuthHiveModel>(_userBox);
      final userModel = users.firstWhere(
        (user) => user.email.toLowerCase() == normalizedEmail,
        orElse: () => throw const AuthException('User not found'),
      );
      return userModel.toEntity();
    } catch (e) {
      throw AuthException('User retrieval failed: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUser(AuthEntity user) async {
    try {
      if (user.id == null) {
        throw const AuthException('User ID cannot be null');
      }

      final authModel = AuthHiveModel.fromEntity(user);
      await _hiveService.saveData(_userBox, user.id!, authModel);

      final currentUser = await getCurrentUser();
      if (currentUser?.id == user.id) {
        await _hiveService.saveData(_userBox, _currentUserKey, authModel);
      }
    } catch (e) {
      throw AuthException('User update failed: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword(String userId, String newPassword) async {
    try {
      final user = await getUserById(userId);
      if (user == null) {
        throw const AuthException('User not found');
      }

      final hashedPassword = _hashPassword(newPassword);
      final updatedProfile = user.profile.copyWith(
        additionalInfo: {
          ...user.profile.additionalInfo,
          'hashedPassword': hashedPassword,
        },
      );

      final updatedUser = user.copyWith(
        profile: updatedProfile,
        metadata: user.metadata.copyWith(
          lastUpdatedAt: DateTime.now(),
        ),
      );

      await updateUser(updatedUser);
    } catch (e) {
      throw AuthException('Password update failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyPassword(String userId, String password) async {
    try {
      final user = await getUserById(userId);
      if (user == null) {
        throw const AuthException('User not found');
      }

      final hashedPassword = _hashPassword(password);
      return user.profile.additionalInfo['hashedPassword'] == hashedPassword;
    } catch (e) {
      throw AuthException('Password verification failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> emailExists(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final users = await _hiveService.getAllData<AuthHiveModel>(_userBox);
      return users.any((user) => user.email.toLowerCase() == normalizedEmail);
    } catch (e) {
      throw AuthException('Email existence check failed: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser?.id == userId) {
        await logout();
      }
      await _hiveService.deleteData(_userBox, userId);
    } catch (e) {
      throw AuthException('User deletion failed: ${e.toString()}');
    }
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
