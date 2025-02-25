// lib/features/customer_dashboard/domain/repository/customer_dashboard_repository.dart

import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/menu_item_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';

abstract class CustomerDashboardRepository {
  Future<Either<Failure, List<RestaurantEntity>>> getAllRestaurants();
  Future<Either<Failure, RestaurantEntity>> getRestaurantDetails(
      String restaurantId);
  Future<Either<Failure, List<MenuItemEntity>>> getRestaurantMenu(
      String restaurantId);
  Future<Either<Failure, List<TableEntity>>> getRestaurantTables(
      String restaurantId);
  Future<Either<Failure, TableEntity>> getTableDetails(String tableId);
}
