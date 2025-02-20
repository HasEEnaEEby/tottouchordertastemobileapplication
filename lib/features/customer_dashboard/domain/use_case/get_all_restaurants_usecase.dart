import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/customer_dashboard_repository.dart';

class GetAllRestaurantsUseCase {
  final CustomerDashboardRepository repository;

  GetAllRestaurantsUseCase(this.repository);

  Future<Either<Failure, List<RestaurantEntity>>> call() async {
    return repository.getAllRestaurants();
  }
}
