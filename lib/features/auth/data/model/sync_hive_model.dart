import 'package:hive/hive.dart';

part 'sync_hive_model.g.dart';

@HiveType(typeId: 4)
class SyncHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Map<String, dynamic> data;

  @HiveField(2)
  final String entityType;

  @HiveField(3)
  final SyncOperation operation;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  bool isSynced;

  @HiveField(6)
  int retryCount;

  SyncHiveModel({
    required this.id,
    required this.data,
    required this.entityType,
    required this.operation,
    required this.createdAt,
    this.isSynced = false,
    this.retryCount = 0,
  });
}

@HiveType(typeId: 5)
enum SyncOperation {
  @HiveField(0)
  create,

  @HiveField(1)
  update,

  @HiveField(2)
  delete,
}
