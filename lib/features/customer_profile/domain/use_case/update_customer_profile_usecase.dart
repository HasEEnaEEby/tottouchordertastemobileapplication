// lib/features/customer_profile/domain/use_case/update_customer_profile_usecase.dart
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/entity/customer_profile_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/repository/customer_profile_repository.dart';

class UpdateCustomerProfileUseCase {
  final CustomerProfileRepository repository;

  UpdateCustomerProfileUseCase(this.repository);

  Future<Either<Failure, CustomerProfileEntity>> call(
    CustomerProfileEntity profile, {
    File? imageFile,
  }) {
    return repository.updateCustomerProfile(profile, imageFile: imageFile);
  }
}
