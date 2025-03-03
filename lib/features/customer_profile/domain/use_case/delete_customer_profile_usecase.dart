import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/repository/customer_profile_repository.dart';

class DeleteCustomerProfileUseCase {
  final CustomerProfileRepository repository;

  DeleteCustomerProfileUseCase(this.repository);

  Future<Either<Failure, bool>> call(String userId) {
    return repository.deleteCustomerProfile(userId);
  }
}
