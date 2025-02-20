import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';

abstract class CustomerDashboardRepository {
  Future<Either<Failure, List<RestaurantEntity>>> getAllRestaurants();
}
