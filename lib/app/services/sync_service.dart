import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart';
import 'package:tottouchordertastemobileapplication/core/errors/exceptions.dart';
import 'package:tottouchordertastemobileapplication/core/network/hive_box_manager.dart';

import '../../features/auth/data/model/sync_hive_model.dart';

class SyncService {
  final NetworkInfo _networkInfo;
  final HiveBoxManager _hiveManager;
  final Dio _dio;
  final Logger _logger = Logger('SyncService');

  static const String _syncBox = 'syncBox';
  static const String _failedSyncsBox = 'failedSyncsBox';
  static const String _baseUrl = 'http://localhost:4000/api/v1';

  bool _isInitialized = false;

  SyncService({
    required NetworkInfo networkInfo,
    required HiveBoxManager hiveManager,
  })  : _networkInfo = networkInfo,
        _hiveManager = hiveManager,
        _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
          headers: {
            'Content-Type': 'application/json',
          },
        ));

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _hiveManager.openBox<SyncHiveModel>(_syncBox);
      await _hiveManager.openBox<SyncHiveModel>(_failedSyncsBox);
      _isInitialized = true;
      _logger.info('SyncService initialized successfully');
    } catch (e) {
      _logger.severe('Failed to initialize SyncService', e);
      throw CacheException('Failed to initialize sync service: $e');
    }
  }

  Future<Box<SyncHiveModel>> _getSyncBox() async {
    if (!_isInitialized) await initialize();
    return _hiveManager.openBox<SyncHiveModel>(_syncBox);
  }

  Future<Box<SyncHiveModel>> _getFailedSyncBox() async {
    if (!_isInitialized) await initialize();
    return _hiveManager.openBox<SyncHiveModel>(_failedSyncsBox);
  }

  Future<void> queueSync({
    required String id,
    required Map<String, dynamic> data,
    required String entityType,
    required SyncOperation operation,
  }) async {
    try {
      final box = await _getSyncBox();

      final syncItem = SyncHiveModel(
        id: id,
        data: data,
        entityType: entityType,
        operation: operation,
        createdAt: DateTime.now(),
      );

      await box.put(id, syncItem);
      _logger.info(
          'Sync item queued: $id, Type: $entityType, Operation: $operation');

      if (await _networkInfo.isConnected) {
        await syncPendingItems();
      }
    } catch (e) {
      _logger.severe('Failed to queue sync', e);
      throw CacheException('Failed to queue sync: $e');
    }
  }

  Future<void> syncPendingItems() async {
    if (!await _networkInfo.isConnected) {
      _logger.info('No network connection. Sync suspended.');
      return;
    }

    try {
      final box = await _getSyncBox();
      final pendingItems = box.values.where((item) => !item.isSynced).toList();

      _logger.info('Found ${pendingItems.length} pending sync items');

      for (var item in pendingItems) {
        try {
          await _performSync(item);

          item.isSynced = true;
          await box.put(item.id, item);

          _logger.info('Sync successful for item: ${item.id}');
        } catch (e) {
          _logger.warning('Sync failed for item: ${item.id}', e);

          item.retryCount++;
          await box.put(item.id, item);

          if (item.retryCount >= 3) {
            await _handleMaxRetriesReached(item);
          }
        }
      }
    } catch (e) {
      _logger.severe('Error during sync process', e);
      throw ServerException('Failed to sync items: $e');
    }
  }

  Future<void> _performSync(SyncHiveModel item) async {
    try {
      final endpoint = _getEndpoint(item.entityType);

      switch (item.operation) {
        case SyncOperation.create:
          await _dio.post(endpoint, data: item.data);
          break;
        case SyncOperation.update:
          await _dio.put('$endpoint/${item.id}', data: item.data);
          break;
        case SyncOperation.delete:
          await _dio.delete('$endpoint/${item.id}');
          break;
      }
    } on DioException catch (e) {
      _logger.warning('Dio sync error', e);
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      }
      throw ServerException('Sync failed: ${e.message}');
    } catch (e) {
      _logger.severe('Unexpected sync error', e);
      throw ServerException('Sync failed: $e');
    }
  }

  String _getEndpoint(String entityType) {
    switch (entityType) {
      case 'auth':
        return '/auth';
      case 'restaurant':
        return '/restaurants';
      case 'customer':
        return '/customers';
      default:
        throw ValidationException('Invalid entity type: $entityType');
    }
  }

  Future<void> _handleMaxRetriesReached(SyncHiveModel item) async {
    try {
      final failedBox = await _getFailedSyncBox();
      final syncBox = await _getSyncBox();

      final failedItem = SyncHiveModel(
        id: item.id,
        data: {
          ...item.data,
          'failedAt': DateTime.now().toIso8601String(),
          'reason': 'Max retries reached',
        },
        entityType: item.entityType,
        operation: item.operation,
        createdAt: item.createdAt,
        isSynced: false,
        retryCount: item.retryCount,
      );

      await failedBox.put(item.id, failedItem);
      await syncBox.delete(item.id);

      _logger.warning('Item moved to failed syncs: ${item.id}');
    } catch (e) {
      _logger.severe('Error handling max retries', e);
      throw CacheException('Failed to handle max retries: $e');
    }
  }

  Future<void> retryFailedSyncs() async {
    try {
      final failedBox = await _getFailedSyncBox();
      final syncBox = await _getSyncBox();
      final failedItems = failedBox.values.toList();

      _logger
          .info('Attempting to retry ${failedItems.length} failed sync items');

      for (var item in failedItems) {
        item.retryCount = 0;
        await syncBox.put(item.id, item);
        await failedBox.delete(item.id);
      }

      await syncPendingItems();
    } catch (e) {
      _logger.severe('Error retrying failed syncs', e);
      throw ServerException('Failed to retry syncs: $e');
    }
  }

  void updateAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _logger.info('Authentication token updated');
  }

  Future<void> dispose() async {
    try {
      await _hiveManager.closeBox(_syncBox);
      await _hiveManager.closeBox(_failedSyncsBox);
      _isInitialized = false;
      _logger.info('SyncService disposed successfully');
    } catch (e) {
      _logger.severe('Error disposing SyncService', e);
    }
  }
}
