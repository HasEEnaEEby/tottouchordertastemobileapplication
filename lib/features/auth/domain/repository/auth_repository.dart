import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/restaurant_entity.dart';

import '../../../../core/errors/failures.dart';
import '../entity/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
    required String userType,
    String? adminCode,
  });

  Future<Either<Failure, AuthEntity>> register({
    required String email,
    required String password,
    required String userType,
    String? username,
    String? phoneNumber,
    Map<String, dynamic>? additionalInfo,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, List<RestaurantEntity>>> getRestaurants();

  Future<Either<Failure, void>> updateProfile({
    required String userId,
    String? username,
    String? phoneNumber,
    Map<String, dynamic>? additionalInfo,
  });

  Future<Either<Failure, void>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, UserProfile>> getUserProfile({required String userId});

  Future<Either<Failure, UserProfile>> updateUserProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePicture,
  });

  Future<Either<Failure, bool>> checkEmailExists(String email);

  Future<Either<Failure, void>> deleteAccount(String userId);
}
