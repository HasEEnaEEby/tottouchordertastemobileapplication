import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entity/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderEntity>> placeOrder(
      OrderRequestEntity orderRequest);
  Future<Either<Failure, List<OrderEntity>>> getCustomerOrders();
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);
  Future<Either<Failure, String>> getOrderStatus(String orderId);
  Future<Either<Failure, void>> cancelOrder(String orderId);
  Future<Either<Failure, OrderEntity>> addItemsToOrder(
      String orderId, List<OrderItemEntity> items);
  Future<Either<Failure, OrderEntity>> requestBill(String orderId);
}
