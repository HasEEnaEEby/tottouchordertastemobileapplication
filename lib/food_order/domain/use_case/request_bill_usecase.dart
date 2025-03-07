import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/repository/food_order_repository.dart';

class RequestBillUseCase {
  final FoodOrderRepository repository;

  RequestBillUseCase(this.repository);

  Future<Either<Failure, FoodOrderEntity>> call(String orderId) async {
    try {
      return await repository.requestBill(orderId);
    } catch (e) {
      return Left(ServerFailure('Failed to request bill: $e'));
    }
  }
}
