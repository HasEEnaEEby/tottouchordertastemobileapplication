import 'dart:io';

import 'package:tottouchordertastemobileapplication/core/errors/exceptions.dart';
import 'package:tottouchordertastemobileapplication/core/network/hive_service.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/data/data_source/customer_profile_data_source.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/entity/customer_profile_entity.dart';

class CustomerProfileLocalDataSourceImpl implements CustomerProfileDataSource {
  final HiveService hiveService;
  static const String _boxName = 'customer_profiles';

  CustomerProfileLocalDataSourceImpl({
    required this.hiveService,
  });

  @override
  Future<CustomerProfileEntity> getCustomerProfile(String userId) async {
    try {
      final profileData =
          await hiveService.getData<Map<dynamic, dynamic>>(_boxName, userId);

      if (profileData == null) {
        throw const CacheException('Profile not found in cache');
      }

      return CustomerProfileEntity(
        id: profileData['id'] ?? '',
        username: profileData['username'] ?? '',
        email: profileData['email'] ?? '',
        fullName: profileData['fullName'],
        phone: profileData['phone'],
        address: profileData['address'],
        imageUrl: profileData['imageUrl'],
        createdAt: DateTime.parse(profileData['createdAt']),
        updatedAt: DateTime.parse(profileData['updatedAt']),
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<CustomerProfileEntity> updateCustomerProfile(
    CustomerProfileEntity profile, {
    File? imageFile,
  }) async {
    try {
      await cacheCustomerProfile(profile);
      return profile;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<String> uploadProfileImage(File imageFile) async {
    // Local data source cannot upload images - this operation is handled by remote
    throw const CacheException(
        'Profile image upload not supported in local data source');
  }

  @override
  Future<bool> deleteCustomerProfile(String userId) async {
    try {
      await clearCustomerProfile(userId);
      return true;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheCustomerProfile(CustomerProfileEntity profile) async {
    try {
      await hiveService.saveData<Map<String, dynamic>>(_boxName, profile.id, {
        'id': profile.id,
        'username': profile.username,
        'email': profile.email,
        'fullName': profile.fullName,
        'phone': profile.phone,
        'address': profile.address,
        'imageUrl': profile.imageUrl,
        'createdAt': profile.createdAt.toIso8601String(),
        'updatedAt': profile.updatedAt.toIso8601String(),
      });
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clearCustomerProfile(String userId) async {
    try {
      await hiveService.deleteData(_boxName, userId);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
