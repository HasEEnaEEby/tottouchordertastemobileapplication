import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:tottouchordertastemobileapplication/app/constants/api_endpoints.dart';
import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart'
    as network;
import 'package:tottouchordertastemobileapplication/core/errors/exceptions.dart';
import 'package:tottouchordertastemobileapplication/core/network/hive_box_manager.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/sync_hive_model.dart';

class SyncService {
  final network.NetworkInfo _networkInfo;
  final HiveBoxManager _hiveManager;
  final Dio _dio;
  final Logger _logger = Logger('SyncService');

  static const String _syncBox = 'syncBox';
  static const String _failedSyncsBox = 'failedSyncsBox';
  static const int _maxRetries = 3;

  bool _isInitialized = false;
  bool _isSyncing = false;

  SyncService({
    required network.NetworkInfo networkInfo,
    required HiveBoxManager hiveManager,
    required Dio dio,
  })  : _networkInfo = networkInfo,
        _hiveManager = hiveManager,
        _dio = Dio(BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
          },
        )) {
    // Configure Dio interceptors
    _configureDioInterceptors();
  }

  void _configureDioInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.info('Request: ${options.method} ${options.path}');
          _logger.info('Request Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.info('Response: ${response.statusCode}');
          _logger.info('Response Data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          _logger.severe('Dio Error: ${e.type}');
          _logger.severe('Error Message: ${e.message}');
          _logger.severe('Error Response: ${e.response?.data}');
          return handler.next(e);
        },
      ),
    );
  }

  // Update authentication token
  void updateAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _logger.info('Authentication token updated');
  }

  // Queue sync operation
  Future<void> queueSync({
    required String id,
    required Map<String, dynamic> data,
    required String entityType,
    required SyncOperation operation,
  }) async {
    try {
      // Validate input
      _validateSyncParameters(id, data, entityType);

      final box = await _getSyncBox();

      final syncItem = SyncHiveModel(
        id: id,
        data: _normalizeData(data, entityType),
        entityType: entityType,
        operation: operation,
        createdAt: DateTime.now(),
      );

      await box.put(id, syncItem);
      _logger.info(
        'Sync item queued: $id, Type: $entityType, Operation: $operation',
      );

      // Attempt immediate sync if network is available
      await _attemptImmediateSync();
    } catch (e, stackTrace) {
      _logger.severe('Failed to queue sync', e, stackTrace);
      throw CacheException('Failed to queue sync: $e');
    }
  }

  // Normalize and validate data based on entity type
  Map<String, dynamic> _normalizeData(
      Map<String, dynamic> data, String entityType) {
    final normalizedData = Map<String, dynamic>.from(data);

    // Normalize role for authentication
    if (entityType == 'auth') {
      normalizedData['role'] =
          _normalizeRole(normalizedData['role'] ?? 'customer');

      // Validate restaurant-specific data
      if (normalizedData['role'] == 'restaurant') {
        _validateRestaurantData(normalizedData);
      }
    }

    return normalizedData;
  }

  // Normalize role
  String _normalizeRole(String role) {
    switch (role.toLowerCase()) {
      case 'restaurant':
        return 'restaurant';
      case 'admin':
        return 'admin';
      case 'customer':
      default:
        return 'customer';
    }
  }

  // Validate restaurant data
  void _validateRestaurantData(Map<String, dynamic> data) {
    final requiredFields = ['restaurantName', 'location', 'contactNumber'];

    for (var field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        throw ValidationException('Missing required restaurant field: $field');
      }
    }
  }

  // Validate sync parameters
  void _validateSyncParameters(
      String id, Map<String, dynamic> data, String entityType) {
    if (id.isEmpty) {
      throw const ValidationException('Sync ID cannot be empty');
    }
    if (data.isEmpty) {
      throw const ValidationException('Sync data cannot be empty');
    }
    if (entityType.isEmpty) {
      throw const ValidationException('Entity type cannot be empty');
    }
  }

  // Attempt immediate sync
  Future<void> _attemptImmediateSync() async {
    if (await _networkInfo.isConnected && !_isSyncing) {
      try {
        await syncPendingItems();
      } catch (e) {
        _logger.warning('Immediate sync attempt failed', e);
      }
    }
  }

  Future<List<SyncHiveModel>> getPendingSyncs() async {
    try {
      final box = await _getSyncBox();
      return box.values.where((item) => !item.isSynced).toList();
    } catch (e) {
      _logger.severe('Error getting pending syncs', e);
      throw CacheException('Failed to retrieve pending sync items: $e');
    }
  }

  // You might also want to add a method to get failed syncs
  Future<List<SyncHiveModel>> getFailedSyncs() async {
    try {
      final failedBox = await _getFailedSyncBox();
      return failedBox.values.toList();
    } catch (e) {
      _logger.severe('Error getting failed syncs', e);
      throw CacheException('Failed to retrieve failed sync items: $e');
    }
  }

  // Sync pending items
  Future<void> syncPendingItems() async {
    if (_isSyncing) {
      _logger.info('Sync already in progress');
      return;
    }

    if (!await _networkInfo.isConnected) {
      _logger.warning('No network connection. Sync postponed.');
      return;
    }

    _isSyncing = true;

    try {
      final box = await _getSyncBox();
      final pendingItems = box.values.where((item) => !item.isSynced).toList();

      _logger.info('Found ${pendingItems.length} pending sync items');

      for (var item in pendingItems) {
        if (!await _networkInfo.isConnected) {
          _logger.warning('Network connection lost. Suspending sync.');
          break;
        }

        try {
          final syncResult = await _performSync(item);

          if (syncResult) {
            item.isSynced = true;
            await box.put(item.id, item);
            _logger.info('Sync successful for item: ${item.id}');
          }
        } catch (e, stackTrace) {
          _logger.warning(
            'Sync failed for item: ${item.id}',
            e,
            stackTrace,
          );

          item.retryCount++;
          await box.put(item.id, item);

          if (item.retryCount >= _maxRetries) {
            await _handleMaxRetriesReached(item);
          }
        }
      }
    } catch (e, stackTrace) {
      _logger.severe('Comprehensive sync process error', e, stackTrace);
      throw ServerException('Comprehensive sync failed: $e', 500);
    } finally {
      _isSyncing = false;
    }
  }

  // Perform sync for a single item
  Future<bool> _performSync(SyncHiveModel item) async {
    try {
      final endpoint = _getEndpoint(item.entityType);
      final headers = {..._dio.options.headers};

      Response response;
      switch (item.operation) {
        case SyncOperation.create:
          response = await _dio.post(
            endpoint,
            data: item.data,
            options: Options(headers: headers),
          );
          break;
        case SyncOperation.update:
          response = await _dio.put(
            '$endpoint/${item.id}',
            data: item.data,
            options: Options(headers: headers),
          );
          break;
        case SyncOperation.delete:
          response = await _dio.delete(
            '$endpoint/${item.id}',
            options: Options(headers: headers),
          );

        case SyncOperation.read:
          response = await _dio.get(
            '$endpoint/${item.id}',
            options: Options(headers: headers),
          );
          break;
      }

      // Validate successful sync
      return _validateSyncResponse(response);
    } on DioException catch (e) {
      return _handleDioSyncError(e);
    } catch (e, stackTrace) {
      _logger.severe('Unexpected sync error', e, stackTrace);
      throw ServerException('Unexpected sync error: $e', 500);
    }
  }

  // Validate sync response
  bool _validateSyncResponse(Response response) {
    final isSuccessful = response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300;

    if (isSuccessful) {
      _logger.info('Sync successful: ${response.data}');
      return true;
    }

    _logger.warning('Sync failed with status: ${response.statusCode}');
    return false;
  }

  // Handle Dio sync errors
  bool _handleDioSyncError(DioException e) {
    _logger.severe('Detailed Dio sync error', e);

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        throw NetworkException.noConnection();
      case DioExceptionType.receiveTimeout:
        throw NetworkException.timeout();
      case DioExceptionType.badResponse:
        throw ServerException(
          'Server error: ${e.response?.data ?? 'Unknown error'}',
          e.response?.statusCode ?? 500,
        );
      default:
        throw ServerException(
          'Sync failed: ${e.message}',
          e.response?.statusCode ?? 500,
        );
    }
  }

  // Get endpoint based on entity type
  String _getEndpoint(String entityType) {
    switch (entityType) {
      case 'auth':
        return ApiEndpoints.signup;
      case 'profile':
        return ApiEndpoints.updateProfile;
      case 'restaurant':
        return '${ApiEndpoints.baseUrl}restaurants';
      case 'customer':
        return '${ApiEndpoints.baseUrl}customers';
      case 'order':
        return '${ApiEndpoints.baseUrl}orders';
      case 'menu':
        return '${ApiEndpoints.baseUrl}menu-items';
      default:
        throw ValidationException('Invalid entity type: $entityType');
    }
  }

  // Handle max retries reached
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
          'lastError': 'Failed after $_maxRetries attempts',
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
    } catch (e, stackTrace) {
      _logger.severe('Error handling max retries', e, stackTrace);
      throw CacheException('Failed to handle max retries: $e');
    }
  }

  // Helper methods to get Hive Boxes
  Future<Box<SyncHiveModel>> _getSyncBox() async {
    if (!_isInitialized) await initialize();
    return _hiveManager.openBox<SyncHiveModel>(_syncBox);
  }

  Future<Box<SyncHiveModel>> _getFailedSyncBox() async {
    if (!_isInitialized) await initialize();
    return _hiveManager.openBox<SyncHiveModel>(_failedSyncsBox);
  }

  // Initialize service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _hiveManager.openBox<SyncHiveModel>(_syncBox);
      await _hiveManager.openBox<SyncHiveModel>(_failedSyncsBox);
      _isInitialized = true;
      _logger.info('SyncService initialized successfully');
    } catch (e, stackTrace) {
      _logger.severe('Failed to initialize SyncService', e, stackTrace);
      throw CacheException('Failed to initialize sync service: $e');
    }
  }

  // Get sync status
  Future<SyncStatus> getSyncStatus() async {
    final box = await _getSyncBox();
    final failedBox = await _getFailedSyncBox();

    final pendingItems = box.values.where((item) => !item.isSynced).toList();
    final failedItems = failedBox.values.toList();

    return SyncStatus(
      pendingItemsCount: pendingItems.length,
      failedItemsCount: failedItems.length,
      isCurrentlySyncing: _isSyncing,
      lastSyncAttempt: DateTime.now(),
    );
  }

  // Retry failed syncs
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
    } catch (e, stackTrace) {
      _logger.severe('Error retrying failed syncs', e, stackTrace);
      throw ServerException('Failed to retry syncs: $e', 500);
    }
  }

  // Dispose service
  Future<void> dispose() async {
    try {
      await _hiveManager.closeBox(_syncBox);
      await _hiveManager.closeBox(_failedSyncsBox);
      _isInitialized = false;
      _logger.info('SyncService disposed successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error disposing SyncService', e, stackTrace);
    }
  }
}

// Sync Status Class
class SyncStatus {
  final int pendingItemsCount;
  final int failedItemsCount;
  final bool isCurrentlySyncing;
  final DateTime lastSyncAttempt;

  SyncStatus({
    required this.pendingItemsCount,
    required this.failedItemsCount,
    required this.isCurrentlySyncing,
    required this.lastSyncAttempt,
  });

  @override
  String toString() {
    return 'SyncStatus('
        'pendingItems: $pendingItemsCount, '
        'failedItems: $failedItemsCount, '
        'isSyncing: $isCurrentlySyncing, '
        'lastSync: $lastSyncAttempt)';
  }
}
