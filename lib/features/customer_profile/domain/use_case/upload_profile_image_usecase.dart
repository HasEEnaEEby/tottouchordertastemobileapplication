import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/repository/customer_profile_repository.dart';

class UploadProfileImageUseCase {
  final CustomerProfileRepository repository;

  UploadProfileImageUseCase(this.repository);

  /// Upload a profile image and return the image URL
  Future<Either<Failure, String>> call(File imageFile) async {
    try {
      final result = await repository.uploadProfileImage(imageFile);
      return result;
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
