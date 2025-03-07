import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:tottouchordertastemobileapplication/app/constants/api_endpoints.dart';
import 'package:tottouchordertastemobileapplication/core/auth/auth_token_manager.dart';

class ImageUploadService {
  final Dio _dio;
  final AuthTokenManager _tokenManager;

  ImageUploadService(this._dio, this._tokenManager);

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      // Get file MIME type
      final mimeType = lookupMimeType(imageFile.path);

      // Create FormData
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType.parse(mimeType ?? 'image/jpeg'),
        ),
      });

      // Get the auth token
      final token = _tokenManager.getToken();

      // Make the upload request
      final response = await _dio.post(
        ApiEndpoints.uploadProfileImage,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Extract and return the uploaded image URL
      return response.data['data']['imageUrl'];
    } catch (e) {
      print('Profile Image upload error: $e');
      return null;
    }
  }

  Future<String?> uploadCoverImage(File imageFile) async {
    try {
      // Get file MIME type
      final mimeType = lookupMimeType(imageFile.path);

      // Create FormData
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType.parse(mimeType ?? 'image/jpeg'),
        ),
      });

      // Get the auth token
      final token = _tokenManager.getToken();

      // Make the upload request
      final response = await _dio.post(
        ApiEndpoints.uploadProfileImage,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Extract and return the uploaded image URL
      return response.data['data']['imageUrl'];
    } catch (e) {
      print('Cover Image upload error: $e');
      return null;
    }
  }
}
