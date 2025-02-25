import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/order_repository.dart';

class PlaceOrderUseCase {
  final OrderRepository repository;

  PlaceOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(
      OrderRequestEntity orderRequest) async {
    try {
      return await repository.placeOrder(orderRequest);
    } catch (e) {
      return Left(ServerFailure('Failed to place order: $e'));
    }
  }
}

class GetCustomerOrdersUseCase {
  final OrderRepository repository;

  GetCustomerOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call() async {
    try {
      return await repository.getCustomerOrders();
    } catch (e) {
      return Left(ServerFailure('Failed to fetch customer orders: $e'));
    }
  }
}

class GetOrderByIdUseCase {
  final OrderRepository repository;

  GetOrderByIdUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String orderId) async {
    try {
      return await repository.getOrderById(orderId);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch order details: $e'));
    }
  }
}

class RequestBillUseCase {
  final OrderRepository repository;

  RequestBillUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String orderId) async {
    try {
      return await repository.requestBill(orderId);
    } catch (e) {
      return Left(ServerFailure('Failed to request bill: $e'));
    }
  }
}
