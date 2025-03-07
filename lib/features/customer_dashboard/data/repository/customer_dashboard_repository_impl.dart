// lib/features/customer_dashboard/data/repository/customer_dashboard_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/data_source/remote_data_source/customer_dashboard_remote_datasource.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/menu_item_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/customer_dashboard_repository.dart';

class CustomerDashboardRepositoryImpl implements CustomerDashboardRepository {
  final CustomerDashboardRemoteDataSource remoteDataSource;

  CustomerDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<RestaurantEntity>>> getAllRestaurants() async {
    try {
      debugPrint('📡 Fetching restaurants from API...');

      final restaurants = await remoteDataSource.getAllRestaurants();

      if (restaurants.isEmpty) {
        debugPrint('🚫 API returned 0 restaurants');
        return const Left(ServerFailure('No restaurants found page'));
      }

      debugPrint('✅ Repository loaded ${restaurants.length} restaurants');
      return Right(restaurants);
    } catch (e) {
      debugPrint('❌ Repository error: $e');

      if (e.toString().contains('Session expired')) {
        return const Left(AuthFailure('Session expired. Please log in again.'));
      }

      return Left(
          ServerFailure('Failed to fetch restaurants: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, RestaurantEntity>> getRestaurantDetails(
      String restaurantId) async {
    try {
      debugPrint(
          'Repository: Attempting to get restaurant details for $restaurantId');
      final restaurant =
          await remoteDataSource.getRestaurantDetails(restaurantId);

      debugPrint('Repository: Successfully fetched restaurant details');
      return Right(restaurant);
    } catch (e) {
      debugPrint('Repository: Error fetching restaurant details - $e');

      if (e.toString().contains('Session expired')) {
        return Left(AuthFailure(e.toString()));
      }

      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getRestaurantMenu(
      String restaurantId) async {
    try {
      debugPrint(
          'Repository: Attempting to get menu items for restaurant $restaurantId');
      final menuItems = await remoteDataSource.getRestaurantMenu(restaurantId);

      debugPrint(
          'Repository: Successfully fetched ${menuItems.length} menu items');
      return Right(menuItems);
    } catch (e) {
      debugPrint('Repository: Error fetching menu items - $e');

      if (e.toString().contains('Session expired')) {
        return Left(AuthFailure(e.toString()));
      }

      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TableEntity>>> getRestaurantTables(
      String restaurantId) async {
    try {
      debugPrint(
          'Repository: Attempting to get tables for restaurant $restaurantId');
      final tables = await remoteDataSource.getRestaurantTables(restaurantId);

      debugPrint('Repository: Successfully fetched ${tables.length} tables');
      return Right(tables);
    } catch (e) {
      debugPrint('Repository: Error fetching tables - $e');

      if (e.toString().contains('Session expired')) {
        return Left(AuthFailure(e.toString()));
      }

      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TableEntity>> getTableDetails(String tableId) async {
    try {
      debugPrint('Repository: Attempting to get details for table $tableId');
      final table = await remoteDataSource.getTableDetails(tableId);

      debugPrint('Repository: Successfully fetched table details');
      return Right(table);
    } catch (e) {
      debugPrint('Repository: Error fetching table details - $e');

      if (e.toString().contains('Session expired')) {
        return Left(AuthFailure(e.toString()));
      }

      return Left(ServerFailure(e.toString()));
    }
  }
}
