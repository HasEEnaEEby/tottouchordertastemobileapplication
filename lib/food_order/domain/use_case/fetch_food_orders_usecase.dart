import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/bill_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/repository/food_order_repository.dart';

class FetchFoodOrdersUseCase {
  final FoodOrderRepository repository;

  FetchFoodOrdersUseCase(this.repository);

  Future<Either<Failure, List<FoodOrderEntity>>> call() async {
    return await repository.fetchUserOrders();
  }
}

class FetchOrderBillUseCase {
  final FoodOrderRepository repository;

  FetchOrderBillUseCase(this.repository);

  Future<Either<Failure, BillEntity>> call(String orderId) async {
    return await repository.getOrderBill(orderId);
  }
}
