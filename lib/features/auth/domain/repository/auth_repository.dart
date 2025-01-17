import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entity/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
    required String userType,
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

  Future<Either<Failure, void>> updateProfile({
    required String userId,
    String? username,
    String? phoneNumber,
    Map<String, dynamic>? additionalInfo,
  });

  Future<Either<Failure, void>> updateRestaurantProfile({
    required String userId,
    String? name,
    String? location,
    String? description,
    String? contactNumber,
    String? website,
    Map<String, dynamic>? businessHours,
    List<String>? cuisine,
  });

  Future<Either<Failure, void>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, bool>> checkEmailExists(String email);

  Future<Either<Failure, void>> deleteAccount(String userId);
}