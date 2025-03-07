import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:tottouchordertastemobileapplication/core/errors/exceptions.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/data/data_source/customer_profile_data_source.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/entity/customer_profile_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/repository/customer_profile_repository.dart';

class CustomerProfileRepositoryImpl implements CustomerProfileRepository {
  final CustomerProfileDataSource remoteDataSource;
  final CustomerProfileDataSource localDataSource;

  CustomerProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, CustomerProfileEntity>> getCustomerProfile(
      String userId) async {
    try {
      // Try to get from local cache first
      try {
        final localProfile = await localDataSource.getCustomerProfile(userId);
        return Right(localProfile);
      } catch (e) {
        debugPrint('No local profile data, fetching from remote: $e');
        // If local cache fails, fetch from remote
      }

      final remoteProfile = await remoteDataSource.getCustomerProfile(userId);

      // Cache the profile for future use
      await localDataSource.cacheCustomerProfile(remoteProfile);

      return Right(remoteProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerProfileEntity>> updateCustomerProfile(
    CustomerProfileEntity profile, {
    File? imageFile,
  }) async {
    try {
      final updatedProfile = await remoteDataSource.updateCustomerProfile(
        profile,
        imageFile: imageFile,
      );

      // Update local cache
      await localDataSource.cacheCustomerProfile(updatedProfile);

      return Right(updatedProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(File imageFile) async {
    try {
      // Always use the remote data source for image uploads
      final imageUrl = await remoteDataSource.uploadProfileImage(imageFile);
      return Right(imageUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCustomerProfile(String userId) async {
    try {
      final result = await remoteDataSource.deleteCustomerProfile(userId);

      if (result) {
        await localDataSource.clearCustomerProfile(userId);
      }

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
