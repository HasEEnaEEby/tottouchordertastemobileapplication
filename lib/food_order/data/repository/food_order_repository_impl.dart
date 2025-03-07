// lib/food_order/data/repository/food_order_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:tottouchordertastemobileapplication/core/errors/exceptions.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/data/data_source/remote_data_source/food_order_remote_datasource.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/bill_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/repository/food_order_repository.dart';

class FoodOrderRepositoryImpl implements FoodOrderRepository {
  final FoodOrderRemoteDataSource remoteDataSource;

  FoodOrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FoodOrderEntity>> createOrder(
      Map<String, dynamic> orderData) async {
    try {
      final order = await remoteDataSource.createOrder(orderData);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FoodOrderEntity>> getOrderDetails(
      String orderId) async {
    try {
      final order = await remoteDataSource.getOrderDetails(orderId);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FoodOrderEntity>> getOrderById(String orderId) async {
    try {
      final order = await remoteDataSource.getOrderById(orderId);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FoodOrderEntity>> cancelOrder(String orderId,
      {String? reason}) async {
    try {
      final order = await remoteDataSource.cancelOrder(orderId, reason: reason);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FoodOrderEntity>>> fetchUserOrders() async {
    try {
      final orders = await remoteDataSource.fetchUserOrders();
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BillEntity>> getOrderBill(String orderId) async {
    try {
      final bill = await remoteDataSource.getOrderBill(orderId);
      return Right(bill);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FoodOrderEntity>> placeOrder(
      OrderRequestEntity orderRequest) async {
    try {
      final order = await remoteDataSource.placeOrder(orderRequest);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> rateOrder(String orderId, int rating,
      {String? feedback}) async {
    try {
      final result =
          await remoteDataSource.rateOrder(orderId, rating, feedback: feedback);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FoodOrderEntity>> requestBill(String orderId) async {
    try {
      final order = await remoteDataSource.requestBill(orderId);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, FoodOrderEntity>> trackOrderUpdates(String orderId) {
    return remoteDataSource.trackOrderUpdates(orderId).map((event) {
      return Right<Failure, FoodOrderEntity>(event);
    }).handleError((error) {
      if (error is ServerException) {
        return Left<Failure, FoodOrderEntity>(ServerFailure(error.message));
      }
      return Left<Failure, FoodOrderEntity>(ServerFailure(error.toString()));
    });
  }

  @override
  Future<Either<Failure, FoodOrderEntity>> updatePaymentStatus(
      String orderId, String paymentStatus) async {
    try {
      final order =
          await remoteDataSource.updatePaymentStatus(orderId, paymentStatus);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  void stopTrackingOrder(String orderId) {
    try {
      remoteDataSource.stopTrackingOrder(orderId);
    } catch (e) {
      // Log the error but don't throw to avoid UI crashes
      debugPrint('Error stopping order tracking: $e');
    }
  }
}
