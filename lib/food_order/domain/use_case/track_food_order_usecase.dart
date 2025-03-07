import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/repository/food_order_repository.dart';

class TrackFoodOrderUseCase {
  final FoodOrderRepository repository;

  TrackFoodOrderUseCase(this.repository);

  /// Fetches order details once
  Future<Either<Failure, FoodOrderEntity>> call(String orderId) async {
    try {
      return await repository.getOrderDetails(orderId);
    } catch (e) {
      return Left(ServerFailure('Failed to get order details: $e'));
    }
  }

  /// Subscribes to real-time order updates
  Stream<Either<Failure, FoodOrderEntity>> subscribe(String orderId) {
    return repository.trackOrderUpdates(orderId);
  }
}
