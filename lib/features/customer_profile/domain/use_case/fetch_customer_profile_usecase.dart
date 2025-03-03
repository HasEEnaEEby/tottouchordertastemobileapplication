import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/entity/customer_profile_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/repository/customer_profile_repository.dart';

class FetchCustomerProfileUseCase {
  final CustomerProfileRepository repository;

  FetchCustomerProfileUseCase(this.repository);

  Future<Either<Failure, CustomerProfileEntity>> call(String userId) {
    return repository.getCustomerProfile(userId);
  }
}
