import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/repository/food_order_repository.dart';

class CancelFoodOrderUseCase {
  final FoodOrderRepository repository;

  CancelFoodOrderUseCase(this.repository);

  Future<Either<Failure, FoodOrderEntity>> call(String orderId,
      {String? reason}) async {
    try {
      return await repository.cancelOrder(orderId, reason: reason);
    } catch (e) {
      return Left(ServerFailure('Failed to cancel order: $e'));
    }
  }
}
