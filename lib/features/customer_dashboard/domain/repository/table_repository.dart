import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/model/table_validation_model.dart';

import '../entity/table_entity.dart';

abstract class TableRepository {
  Future<Either<Failure, List<TableEntity>>> getRestaurantTables(
      String restaurantId);
  Future<Either<Failure, List<TableEntity>>> getAvailableTables(
      String restaurantId);
  Future<Either<Failure, TableEntity>> getTableById(String tableId);
  Future<Either<Failure, TableValidationModel>> validateTableQR(
      String restaurantId, String qrData);
  Future<Either<Failure, bool>> requestTable(
      String tableId, String sessionToken);
}
