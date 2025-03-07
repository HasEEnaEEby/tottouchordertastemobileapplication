import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/repository/food_order_repository.dart';

class RateOrderUseCase {
  final FoodOrderRepository repository;

  RateOrderUseCase(this.repository);

  Future<Either<Failure, bool>> call(String orderId, int rating,
      {String? feedback}) async {
    try {
      return await repository.rateOrder(orderId, rating, feedback: feedback);
    } catch (e) {
      return Left(ServerFailure('Failed to submit order rating: $e'));
    }
  }
}
