import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/menu_item_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/customer_dashboard_repository.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/order_repository.dart';

// Restaurant-related use cases
class GetAllRestaurantsUseCase {
  final CustomerDashboardRepository repository;

  GetAllRestaurantsUseCase(this.repository);

  Future<Either<Failure, List<RestaurantEntity>>> call() {
    return repository.getAllRestaurants(); 
  }
}

class GetRestaurantDetailsUseCase {
  final CustomerDashboardRepository repository;

  GetRestaurantDetailsUseCase(this.repository);

  // Return the Either directly from the repository
  Future<Either<Failure, RestaurantEntity>> call(String restaurantId) async {
    try {
      debugPrint(
          'GetRestaurantDetailsUseCase: Fetching details for restaurant $restaurantId');

      return await repository.getRestaurantDetails(restaurantId);
    } catch (e) {
      debugPrint('GetRestaurantDetailsUseCase error: $e');

      if (e.toString().contains('Session expired')) {
        return Left(AuthFailure(e.toString()));
      }

      return Left(ServerFailure('Failed to fetch restaurant details: $e'));
    }
  }
}

class GetRestaurantMenuUseCase {
  final CustomerDashboardRepository repository;

  GetRestaurantMenuUseCase(this.repository);

  // Return the Either directly from the repository
  Future<Either<Failure, List<MenuItemEntity>>> call(
      String restaurantId) async {
    try {
      debugPrint(
          'GetRestaurantMenuUseCase: Fetching menu for restaurant $restaurantId');

      return await repository.getRestaurantMenu(restaurantId);
    } catch (e) {
      debugPrint('GetRestaurantMenuUseCase error: $e');

      if (e.toString().contains('Session expired')) {
        return Left(AuthFailure(e.toString()));
      }

      return Left(ServerFailure('Failed to fetch restaurant menu: $e'));
    }
  }
}

class GetRestaurantTablesUseCase {
  final CustomerDashboardRepository repository;

  GetRestaurantTablesUseCase(this.repository);

  // Return the Either directly from the repository
  Future<Either<Failure, List<TableEntity>>> call(String restaurantId) async {
    try {
      debugPrint(
          'GetRestaurantTablesUseCase: Fetching tables for restaurant $restaurantId');

      return await repository.getRestaurantTables(restaurantId);
    } catch (e) {
      debugPrint('GetRestaurantTablesUseCase error: $e');

      if (e.toString().contains('Session expired')) {
        return Left(AuthFailure(e.toString()));
      }

      return Left(ServerFailure('Failed to fetch restaurant tables: $e'));
    }
  }
}

class GetTableDetailsUseCase {
  final CustomerDashboardRepository repository;

  GetTableDetailsUseCase(this.repository);

  // Return the Either directly from the repository
  Future<Either<Failure, TableEntity>> call(String tableId) async {
    try {
      debugPrint('GetTableDetailsUseCase: Fetching details for table $tableId');

      return await repository.getTableDetails(tableId);
    } catch (e) {
      debugPrint('GetTableDetailsUseCase error: $e');

      if (e.toString().contains('Session expired')) {
        return Left(AuthFailure(e.toString()));
      }

      return Left(ServerFailure('Failed to fetch table details: $e'));
    }
  }
}

// Order-related use cases
class PlaceOrderUseCase {
  final OrderRepository repository;

  PlaceOrderUseCase(this.repository);

  // Return the Either directly from the repository
  Future<Either<Failure, OrderEntity>> call(
      OrderRequestEntity orderRequest) async {
    try {
      debugPrint('PlaceOrderUseCase: Placing order');

      final orderEither = await repository.placeOrder(orderRequest);

      return orderEither;
    } catch (e) {
      debugPrint('PlaceOrderUseCase error: $e');

      if (e.toString().contains('Session expired')) {
        return Left(AuthFailure(e.toString()));
      }

      return Left(ServerFailure('Failed to place order: $e'));
    }
  }
}

class GetCustomerOrdersUseCase {
  final OrderRepository repository;

  GetCustomerOrdersUseCase(this.repository);

  // Return the Either directly from the repository
  Future<Either<Failure, List<OrderEntity>>> call() async {
    try {
      debugPrint('GetCustomerOrdersUseCase: Fetching customer orders');

      return await repository.getCustomerOrders();
    } catch (e) {
      debugPrint('GetCustomerOrdersUseCase error: $e');

      if (e.toString().contains('Session expired')) {
        return Left(AuthFailure(e.toString()));
      }

      return Left(ServerFailure('Failed to fetch customer orders: $e'));
    }
  }
}

class GetOrderDetailsUseCase {
  final OrderRepository repository;

  GetOrderDetailsUseCase(this.repository);

  // Return the Either directly from the repository
  Future<Either<Failure, OrderEntity>> call(String orderId) async {
    try {
      debugPrint('GetOrderDetailsUseCase: Fetching details for order $orderId');

      return await repository.getOrderById(orderId);
    } catch (e) {
      debugPrint('GetOrderDetailsUseCase error: $e');

      if (e.toString().contains('Session expired')) {
        return Left(AuthFailure(e.toString()));
      }

      return Left(ServerFailure('Failed to fetch order details: $e'));
    }
  }
}

class GetOrderStatusUseCase {
  final OrderRepository repository;

  GetOrderStatusUseCase(this.repository);

  // Return the Either directly from the repository
  Future<Either<Failure, String>> call(String orderId) async {
    try {
      debugPrint('GetOrderStatusUseCase: Fetching status for order $orderId');

      return await repository.getOrderStatus(orderId);
    } catch (e) {
      debugPrint('GetOrderStatusUseCase error: $e');

      if (e.toString().contains('Session expired')) {
        return Left(AuthFailure(e.toString()));
      }

      return Left(ServerFailure('Failed to fetch order status: $e'));
    }
  }
}

class CancelOrderUseCase {
  final OrderRepository repository;

  CancelOrderUseCase(this.repository);

  // Return the Either directly from the repository
  Future<Either<Failure, void>> call(String orderId) async {
    try {
      debugPrint('CancelOrderUseCase: Cancelling order $orderId');

      return await repository.cancelOrder(orderId);
    } catch (e) {
      debugPrint('CancelOrderUseCase error: $e');

      if (e.toString().contains('Session expired')) {
        return Left(AuthFailure(e.toString()));
      }

      return Left(ServerFailure('Failed to cancel order: $e'));
    }
  }
}
