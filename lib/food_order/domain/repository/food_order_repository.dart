// Update your FoodOrderRepository abstract class in lib/food_order/domain/repository/food_order_repository.dart

import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/bill_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';

abstract class FoodOrderRepository {
  /// Fetches all orders for the current user
  Future<Either<Failure, List<FoodOrderEntity>>> fetchUserOrders();

  /// Gets details for a specific order
  Future<Either<Failure, FoodOrderEntity>> getOrderDetails(String orderId);

  /// Gets an order by ID
  Future<Either<Failure, FoodOrderEntity>> getOrderById(String orderId);

  /// Cancels an order
  Future<Either<Failure, FoodOrderEntity>> cancelOrder(String orderId,
      {String? reason});

  /// Tracks real-time updates for an order
  Stream<Either<Failure, FoodOrderEntity>> trackOrderUpdates(String orderId);

  /// Stops tracking updates for an order
  void stopTrackingOrder(String orderId);

  /// Places a new order
  Future<Either<Failure, FoodOrderEntity>> placeOrder(
      OrderRequestEntity orderRequest);

  /// Requests a bill for an order
  Future<Either<Failure, FoodOrderEntity>> requestBill(String orderId);

  /// Get an order's bill
  Future<Either<Failure, BillEntity>> getOrderBill(String orderId);

  /// Updates order payment status
  Future<Either<Failure, FoodOrderEntity>> updatePaymentStatus(
      String orderId, String paymentStatus);

  /// Rates and gives feedback for a completed order
  Future<Either<Failure, bool>> rateOrder(String orderId, int rating,
      {String? feedback});
}
