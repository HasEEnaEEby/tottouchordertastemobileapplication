import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/data_source/remote_data_source/customer_dashboard_remote_datasource.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/customer_dashboard_repository.dart';

class CustomerDashboardRepositoryImpl implements CustomerDashboardRepository {
  final CustomerDashboardRemoteDataSource remoteDataSource;

  CustomerDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<RestaurantEntity>>> getAllRestaurants() async {
    try {
      final restaurants = await remoteDataSource.getAllRestaurants();
      return Right(restaurants);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
