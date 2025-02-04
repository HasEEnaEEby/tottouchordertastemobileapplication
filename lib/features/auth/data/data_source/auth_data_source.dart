import 'dart:io';

import '../../domain/entity/auth_entity.dart';

abstract interface class IAuthDataSource {
  Future<AuthEntity> login({
    required String email,
    required String password,
    required String userType,
    String? adminCode,
  });

  Future<AuthEntity> register({
    required String email,
    required String password,
    required String userType,
    required String username,
    String? restaurantName,
    String? location,
    String? contactNumber,
    String? quote,
  });

  Future<bool> verifyEmail(String token);
  Future<bool> resendVerification(String email);
  Future<AuthEntity> refreshToken(String refreshToken);
  Future<bool> logout();
  Future<AuthEntity> getProfile();
  Future<AuthEntity> updateProfile(Map<String, dynamic> profileData);
  Future<String> uploadProfilePicture(File image);
}
