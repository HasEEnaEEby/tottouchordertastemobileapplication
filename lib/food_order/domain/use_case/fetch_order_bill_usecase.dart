import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/bill_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/repository/food_order_repository.dart';

class FetchBillUseCase {
  final FoodOrderRepository repository;

  FetchBillUseCase(this.repository);

  Future<Either<Failure, BillEntity>> call(String orderId) async {
    try {
      return await repository.getOrderBill(orderId);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch bill: $e'));
    }
  }
}
