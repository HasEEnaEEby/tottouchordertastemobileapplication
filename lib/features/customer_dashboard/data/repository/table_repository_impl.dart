import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart';
import 'package:tottouchordertastemobileapplication/core/errors/exceptions.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/data_source/table_data_source.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/model/table_validation_model.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/table_repository.dart';

class TableRepositoryImpl implements TableRepository {
  final TableDataSource dataSource;
  final NetworkInfo networkInfo;

  TableRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<TableEntity>>> getRestaurantTables(
      String restaurantId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final response = await dataSource.getRestaurantTables(restaurantId);
      final List<dynamic> tablesJson = response['data']['tables'];
      final List<TableEntity> tables =
          tablesJson.map((json) => TableEntity.fromJson(json)).toList();
      return Right(tables);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TableEntity>>> getAvailableTables(
      String restaurantId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final response = await dataSource.getAvailableTables(restaurantId);
      final List<dynamic> tablesJson = response['data']['tables'];
      final List<TableEntity> tables =
          tablesJson.map((json) => TableEntity.fromJson(json)).toList();
      return Right(tables);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TableEntity>> getTableById(String tableId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final response = await dataSource.getTableById(tableId);
      final tableJson = response['data']['table'];
      final TableEntity table = TableEntity.fromJson(tableJson);
      return Right(table);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TableValidationModel>> validateTableQR(
      String restaurantId, String qrData) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final TableValidationModel validationModel =
          await dataSource.validateTableQR(restaurantId, qrData);
      return Right(validationModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestTable(
      String tableId, String sessionToken) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final bool success = await dataSource.requestTable(tableId, sessionToken);
      return Right(success);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
