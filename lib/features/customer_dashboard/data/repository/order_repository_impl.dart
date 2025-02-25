import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entity/order_entity.dart';
import '../../domain/repository/order_repository.dart';
import '../data_source/remote_data_source/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, OrderEntity>> placeOrder(
      OrderRequestEntity orderRequest) async {
    try {
      final order = await remoteDataSource.placeOrder(orderRequest);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure('Failed to place order: $e'));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getCustomerOrders() async {
    try {
      final orders = await remoteDataSource.getCustomerOrders();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch customer orders: $e'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    try {
      final order = await remoteDataSource.getOrderById(orderId);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch order details: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getOrderStatus(String orderId) async {
    try {
      final status = await remoteDataSource.getOrderStatus(orderId);
      return Right(status);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch order status: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    try {
      await remoteDataSource.cancelOrder(orderId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to cancel order: $e'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> addItemsToOrder(
      String orderId, List<OrderItemEntity> items) async {
    try {
      final order = await remoteDataSource.addItemsToOrder(orderId, items);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure('Failed to add items to order: $e'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> requestBill(String orderId) async {
    try {
      final order = await remoteDataSource.requestBill(orderId);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure('Failed to request bill: $e'));
    }
  }
}
