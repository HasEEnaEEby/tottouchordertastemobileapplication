import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/auth_hive_model.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/auth_entity.dart';

abstract class AuthDataSource {
  Future<AuthEntity> login(
      {required String email,
      required String password,
      required String userType});

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
}

class AuthDataSourceImpl implements AuthDataSource {
  final http.Client client;
  final String baseUrl;

  AuthDataSourceImpl({
    required this.client,
    this.baseUrl = 'http://localhost:4000/api/v1/auth',
  });

  @override
  Future<AuthEntity> login(
      {required String email,
      required String password,
      required String userType}) async {
    final Uri url = Uri.parse('$baseUrl/login');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'userType': userType,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final userJson = responseBody['user'] ?? responseBody;

        final completeUserJson = {
          'id': userJson['id'] ?? '',
          'email': userJson['email'] ?? email,
          'userType': userJson['userType'] ?? userType,
          'status': userJson['status'] ?? 'authenticated',
          'profile': userJson['profile'] ??
              {
                'username': null,
                'displayName': null,
                'phoneNumber': null,
                'profileImage': null,
                'additionalInfo': {},
              },
          'metadata': userJson['metadata'] ??
              {
                'createdAt': DateTime.now().toIso8601String(),
                'lastLoginAt': DateTime.now().toIso8601String(),
                'lastUpdatedAt': null,
                'lastLoginIp': null,
                'securitySettings': {},
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
          'email': email,
          'password': password,
          'userType': userType,
          'profile': {
            'username': profile.username,
            'displayName': profile.displayName,
            'phoneNumber': profile.phoneNumber,
            'profileImage': profile.profileImage,
            'additionalInfo': profile.additionalInfo,
          },
          'metadata': {
            'createdAt': metadata.createdAt?.toIso8601String(),
          },
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 201) {
        // Ensure all required fields are present in the response
        final userJson = responseBody['user'] ?? responseBody;

        // Add default values for missing fields
        final completeUserJson = {
          'id': userJson['id'] ?? '',
          'email': userJson['email'] ?? email,
          'userType': userJson['userType'] ?? userType,
          'status': userJson['status'] ?? 'authenticated',
          'profile': userJson['profile'] ??
              {
                'username': profile.username,
                'displayName': profile.displayName,
                'phoneNumber': profile.phoneNumber,
                'profileImage': profile.profileImage,
                'additionalInfo': profile.additionalInfo,
              },
          'metadata': userJson['metadata'] ??
              {
                'createdAt': DateTime.now().toIso8601String(),
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
      throw ServerFailure('Failed to connect to the server: $e');
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
        body: json.encode({'email': email}),
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
          'email': email,
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
}
