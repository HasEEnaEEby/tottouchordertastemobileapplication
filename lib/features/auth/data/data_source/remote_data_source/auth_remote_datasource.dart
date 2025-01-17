import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/auth_hive_model.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/auth_entity.dart';

abstract class AuthRemoteDataSource {
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

  Future<bool> logout(String token);

  Future<bool> forgotPassword(String email);
  Future<bool> resetPassword(String email, String newPassword, String token);

  Future<AuthEntity> updateProfile(String userId, UserProfile profile);
  Future<bool> changePassword(
      String userId, String currentPassword, String newPassword);

  Future<bool> verifyEmail(String email, String verificationToken);

  Future<AuthEntity?> getUserById(String userId);
  Future<AuthEntity?> getUserByEmail(String email);
  Future<bool> checkEmailAvailability(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = 'http://localhost:4000/api/v1/auth',
  });

  @override
  Future<AuthEntity> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    final Uri url = Uri.parse('$baseUrl/login');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim().toLowerCase(),
          'password': password,
          'userType': userType.toLowerCase(),
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final userJson = responseBody['user'] ?? responseBody;

        final completeUserJson = {
          'id': userJson['_id'] ?? userJson['id'] ?? '',
          'email': userJson['email'] ?? email,
          'userType': userJson['userType'] ?? userType,
          'status': 'authenticated',
          'profile': {
            'username': userJson['profile']?['username'],
            'displayName': userJson['profile']?['displayName'],
            'phoneNumber': userJson['profile']?['phoneNumber'],
            'profileImage': userJson['profile']?['profileImage'],
            'additionalInfo': userJson['profile']?['additionalInfo'] ?? {},
          },
          'metadata': {
            'createdAt':
                userJson['createdAt'] ?? DateTime.now().toIso8601String(),
            'lastLoginAt': DateTime.now().toIso8601String(),
            'lastUpdatedAt': DateTime.now().toIso8601String(),
            'lastLoginIp': userJson['lastLoginIp'],
            'securitySettings': userJson['securitySettings'] ?? {},
          }
        };

        final authModel = AuthHiveModel.fromJson(completeUserJson);
        return authModel.toEntity();
      } else {
        throw ServerFailure(responseBody['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw ServerFailure('Failed to connect to the server: $e');
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
    final Uri url = Uri.parse('$baseUrl/register');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim().toLowerCase(),
          'password': password,
          'userType': userType.toLowerCase(),
          'profile': {
            'username': profile.username,
            'displayName': profile.displayName,
            'phoneNumber': profile.phoneNumber,
            'profileImage': profile.profileImage,
            'additionalInfo': profile.additionalInfo,
          },
          'metadata': {
            'createdAt': metadata.createdAt?.toIso8601String() ??
                DateTime.now().toIso8601String(),
          },
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 201) {
        final userJson = responseBody['user'] ?? responseBody;

        final completeUserJson = {
          'id': userJson['_id'] ?? userJson['id'] ?? '',
          'email': userJson['email'] ?? email,
          'userType': userJson['userType'] ?? userType,
          'status': 'authenticated',
          'profile': {
            'username': userJson['profile']?['username'] ?? profile.username,
            'displayName':
                userJson['profile']?['displayName'] ?? profile.displayName,
            'phoneNumber':
                userJson['profile']?['phoneNumber'] ?? profile.phoneNumber,
            'profileImage':
                userJson['profile']?['profileImage'] ?? profile.profileImage,
            'additionalInfo': userJson['profile']?['additionalInfo'] ??
                profile.additionalInfo,
          },
          'metadata': {
            'createdAt':
                userJson['createdAt'] ?? DateTime.now().toIso8601String(),
            'lastLoginAt': null,
            'lastUpdatedAt': null,
            'lastLoginIp': null,
            'securitySettings': {},
          }
        };

        final authModel = AuthHiveModel.fromJson(completeUserJson);
        return authModel.toEntity();
      } else {
        throw ServerFailure(responseBody['message'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> logout(String token) async {
    final Uri url = Uri.parse('$baseUrl/logout');

    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerFailure(responseBody['message'] ?? 'Logout failed');
      }
    } catch (e) {
      throw ServerFailure('Failed to connect to the server: $e');
    }
  }

  @override
  Future<bool> forgotPassword(String email) async {
    final Uri url = Uri.parse('$baseUrl/forgot-password');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email.trim().toLowerCase()}),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerFailure(
            responseBody['message'] ?? 'Failed to send reset password link');
      }
    } catch (e) {
      throw ServerFailure('Failed to connect to the server: $e');
    }
  }

  @override
  Future<bool> resetPassword(
      String email, String newPassword, String token) async {
    final Uri url = Uri.parse('$baseUrl/reset-password');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim().toLowerCase(),
          'newPassword': newPassword,
          'token': token,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerFailure(
            responseBody['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      throw ServerFailure('Failed to connect to the server: $e');
    }
  }

  @override
  Future<AuthEntity> updateProfile(String userId, UserProfile profile) async {
    final Uri url = Uri.parse('$baseUrl/update-profile');

    try {
      final response = await client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'profile': {
            'username': profile.username,
            'displayName': profile.displayName,
            'phoneNumber': profile.phoneNumber,
            'profileImage': profile.profileImage,
            'additionalInfo': profile.additionalInfo,
          },
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final userJson = responseBody['user'] ?? responseBody;

        final completeUserJson = {
          'id': userJson['_id'] ?? userJson['id'] ?? userId,
          'email': userJson['email'],
          'userType': userJson['userType'],
          'status': 'authenticated',
          'profile': {
            'username': userJson['profile']?['username'] ?? profile.username,
            'displayName':
                userJson['profile']?['displayName'] ?? profile.displayName,
            'phoneNumber':
                userJson['profile']?['phoneNumber'] ?? profile.phoneNumber,
            'profileImage':
                userJson['profile']?['profileImage'] ?? profile.profileImage,
            'additionalInfo': userJson['profile']?['additionalInfo'] ??
                profile.additionalInfo,
          },
          'metadata': userJson['metadata'],
        };

        final authModel = AuthHiveModel.fromJson(completeUserJson);
        return authModel.toEntity();
      } else {
        throw ServerFailure(responseBody['message'] ?? 'Profile update failed');
      }
    } catch (e) {
      throw ServerFailure('Failed to connect to the server: $e');
    }
  }

  @override
  Future<bool> changePassword(
      String userId, String currentPassword, String newPassword) async {
    final Uri url = Uri.parse('$baseUrl/change-password');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerFailure(
            responseBody['message'] ?? 'Password change failed');
      }
    } catch (e) {
      throw ServerFailure('Failed to connect to the server: $e');
    }
  }


  @override
  Future<bool> verifyEmail(String email, String verificationToken) async {
    final Uri url = Uri.parse('$baseUrl/verify-email');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim().toLowerCase(),
          'token': verificationToken,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerFailure(
            responseBody['message'] ?? 'Email verification failed');
      }
    } catch (e) {
      throw ServerFailure('Failed to connect to the server: $e');
    }
  }

  @override
  Future<AuthEntity?> getUserById(String userId) async {
    final Uri url = Uri.parse('$baseUrl/user/$userId');

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final userJson = responseBody['user'] ?? responseBody;

        final completeUserJson = {
          'id': userJson['_id'] ?? userJson['id'] ?? userId,
          'email': userJson['email'],
          'userType': userJson['userType'],
          'status': 'authenticated',
          'profile': userJson['profile'] ?? {},
          'metadata': userJson['metadata'] ?? {},
        };

        final authModel = AuthHiveModel.fromJson(completeUserJson);
        return authModel.toEntity();
      } else {
        throw ServerFailure('Failed to fetch user by ID: $userId');
      }
    } catch (e) {
      throw ServerFailure('Failed to connect to the server: $e');
    }
  }

  @override
  Future<AuthEntity?> getUserByEmail(String email) async {
    final Uri url = Uri.parse('$baseUrl/user/email/$email');

    try {
      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        final userJson = responseBody['user'] ?? responseBody;

        final completeUserJson = {
          'id': userJson['_id'] ?? userJson['id'] ?? '',
          'email': userJson['email'] ?? email,
          'userType': userJson['userType'] ?? 'unknown',
          'status': 'authenticated',
          'profile': userJson['profile'] ?? {},
          'metadata': userJson['metadata'] ?? {},
        };

        final authModel = AuthHiveModel.fromJson(completeUserJson);
        return authModel.toEntity();
      } else {
        throw ServerFailure(
            'Failed to fetch user by email: $email (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (e is SocketException) {
        throw const ServerFailure(
            'No internet connection. Please check your connection.');
      } else if (e is FormatException) {
        throw const ServerFailure(
            'Error parsing response data from the server.');
      } else {
        throw ServerFailure('Failed to connect to the server: $e');
      }
    }
  }

  @override
  Future<bool> checkEmailAvailability(String email) async {
    final Uri url = Uri.parse('$baseUrl/check-email');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email.trim().toLowerCase()}),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseBody['available'] ?? false;
      } else {
        throw ServerFailure(
            responseBody['message'] ?? 'Email availability check failed');
      }
    } catch (e) {
      throw ServerFailure('Failed to connect to the server: $e');
    }
  }
}
