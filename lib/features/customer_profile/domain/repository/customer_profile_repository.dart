import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/entity/customer_profile_entity.dart';

abstract class CustomerProfileRepository {
  Future<Either<Failure, CustomerProfileEntity>> getCustomerProfile(String userId);
  Future<Either<Failure, CustomerProfileEntity>> updateCustomerProfile(
    CustomerProfileEntity profile, {
    File? imageFile,
  });
  Future<Either<Failure, String>> uploadProfileImage(File imageFile);
  Future<Either<Failure, bool>> deleteCustomerProfile(String userId);
}