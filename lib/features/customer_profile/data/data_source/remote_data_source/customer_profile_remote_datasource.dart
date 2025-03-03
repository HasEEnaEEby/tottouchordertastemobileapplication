import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:tottouchordertastemobileapplication/app/constants/api_endpoints.dart';
import 'package:tottouchordertastemobileapplication/core/auth/auth_token_manager.dart';
import 'package:tottouchordertastemobileapplication/core/errors/exceptions.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/data/data_source/customer_profile_data_source.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/entity/customer_profile_entity.dart';

class CustomerProfileRemoteDataSourceImpl implements CustomerProfileDataSource {
  final Dio dio;
  final AuthTokenManager tokenManager;

  CustomerProfileRemoteDataSourceImpl({
    required this.dio,
    required this.tokenManager,
  });

  Map<String, String> _getHeaders() {
    final token = tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<CustomerProfileEntity> getCustomerProfile(String userId) async {
    try {
      debugPrint('RemoteDataSource: Getting customer profile');

      final response = await dio.get(
        ApiEndpoints.userProfile,
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200) {
        // Extract user data from the response
        final userData = response.data['data']['user'];

        // Convert response to CustomerProfileEntity
        return CustomerProfileEntity(
          id: userData['_id'] ?? '',
          username: userData['username'] ?? '',
          email: userData['email'] ?? '',
          fullName: userData['fullName'],
          phone: userData['phone'],
          address: userData['address'],
          imageUrl: userData['image'], // Map to 'image' field from backend
          createdAt: userData['createdAt'] != null
              ? DateTime.parse(userData['createdAt'])
              : DateTime.now(),
          updatedAt: userData['updatedAt'] != null
              ? DateTime.parse(userData['updatedAt'])
              : DateTime.now(),
        );
      } else {
        throw ServerException(
            response.data['message'] ?? 'Failed to get profile',
            response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      debugPrint('DioError getting profile: ${e.message}');
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw ServerException("Session expired. Please log in again.",
            e.response?.statusCode ?? 401);
      }
      throw ServerException(
          e.response?.data?['message'] ?? 'Network error: ${e.message}',
          e.response?.statusCode ?? 500);
    } catch (e) {
      debugPrint('Error getting profile: $e');
      throw ServerException(e.toString(), 500);
    }
  }

  @override
  Future<CustomerProfileEntity> updateCustomerProfile(
    CustomerProfileEntity profile, {
    File? imageFile,
  }) async {
    try {
      debugPrint('RemoteDataSource: Updating customer profile');

      // If image file is provided, upload it first
      String? newImageUrl;
      if (imageFile != null) {
        newImageUrl = await uploadProfileImage(imageFile);
      }

      // Create request data
      final Map<String, dynamic> updateData = {
        'fullName': profile.fullName,
        'phone': profile.phone,
        'address': profile.address,
      };

      // Include the new image URL if an image was uploaded
      if (newImageUrl != null) {
        updateData['image'] = newImageUrl;
      }

      final response = await dio.patch(
        ApiEndpoints.updateUserProfile,
        options: Options(headers: _getHeaders()),
        data: updateData,
      );

      if (response.statusCode == 200) {
        // Extract user data from the response
        final userData = response.data['data']['user'];

        // Convert response to CustomerProfileEntity
        return CustomerProfileEntity(
          id: userData['_id'] ?? profile.id,
          username: userData['username'] ?? profile.username,
          email: userData['email'] ?? profile.email,
          fullName: userData['fullName'],
          phone: userData['phone'],
          address: userData['address'],
          imageUrl: userData['image'] ?? newImageUrl ?? profile.imageUrl,
          createdAt: profile.createdAt,
          updatedAt: DateTime.now(),
        );
      } else {
        throw ServerException(
            response.data['message'] ?? 'Failed to update profile',
            response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      debugPrint('DioError updating profile: ${e.message}');
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw ServerException("Session expired. Please log in again.",
            e.response?.statusCode ?? 401);
      }
      throw ServerException(
          e.response?.data?['message'] ?? 'Network error: ${e.message}',
          e.response?.statusCode ?? 500);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw ServerException(e.toString(), 500);
    }
  }

  @override
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      debugPrint('RemoteDataSource: Uploading profile image');

      // Get auth headers but remove content-type since it'll be multipart
      final headers = _getHeaders();
      headers.remove('Content-Type');

      // Prepare form data with the image file
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        ),
      });

      final response = await dio.post(
        ApiEndpoints.uploadProfileImage,
        options: Options(headers: headers),
        data: formData,
      );

      if (response.statusCode == 200) {
        // Extract image URL from the response
        final imageUrl = response.data['data']['imageUrl'];
        if (imageUrl == null) {
          throw const ServerException('Image URL not found in response', 500);
        }
        return imageUrl;
      } else {
        throw ServerException(
            response.data['message'] ?? 'Failed to upload image',
            response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      debugPrint('DioError uploading image: ${e.message}');
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw ServerException("Session expired. Please log in again.",
            e.response?.statusCode ?? 401);
      }
      throw ServerException(
          e.response?.data?['message'] ?? 'Network error: ${e.message}',
          e.response?.statusCode ?? 500);
    } catch (e) {
      debugPrint('Error uploading image: $e');
      throw ServerException(e.toString(), 500);
    }
  }

  @override
  Future<bool> deleteCustomerProfile(String userId) async {
    try {
      final response = await dio.delete('/api/users/$userId/profile');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerException(
            response.data['message'] ?? 'Failed to delete profile',
            response.statusCode ?? 500);
      }
    } catch (e) {
      throw ServerException(e.toString(), 500);
    }
  }

  // Not used for remote data source
  @override
  Future<void> cacheCustomerProfile(CustomerProfileEntity profile) async {
    // No-op for remote data source
  }

  // Not used for remote data source
  @override
  Future<void> clearCustomerProfile(String userId) async {
    // No-op for remote data source
  }
}
