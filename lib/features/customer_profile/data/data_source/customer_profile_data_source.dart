import 'dart:io';

import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/entity/customer_profile_entity.dart';

abstract class CustomerProfileDataSource {
  Future<CustomerProfileEntity> getCustomerProfile(String userId);
  Future<CustomerProfileEntity> updateCustomerProfile(
    CustomerProfileEntity profile, {
    File? imageFile,
  });
  Future<String> uploadProfileImage(File imageFile);
  Future<bool> deleteCustomerProfile(String userId);
  Future<void> cacheCustomerProfile(CustomerProfileEntity profile);
  Future<void> clearCustomerProfile(String userId);
}
