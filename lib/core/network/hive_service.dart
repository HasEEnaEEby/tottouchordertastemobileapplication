import 'package:logging/logging.dart';

import 'hive_box_manager.dart';

class HiveService {
  final HiveBoxManager _boxManager;
  final Logger _logger = Logger('HiveService');

  HiveService({required HiveBoxManager hiveManager}) : _boxManager = HiveBoxManager();

  Future<void> init() async {
    try {
      _logger.info('HiveService initialized');
    } catch (e) {
      _logger.severe('Failed to initialize HiveService', e);
      rethrow;
    }
  }

  Future<void> saveData<T>(String boxName, String key, T value) async {
    try {
      final box = await _boxManager.openBox<T>(boxName);
      await box.put(key, value);
      _logger.info('Saved data to $boxName with key: $key');
    } catch (e) {
      _logger.severe('Failed to save data to $boxName', e);
      rethrow;
    }
  }

  Future<T?> getData<T>(String boxName, String key) async {
    try {
      final box = await _boxManager.openBox<T>(boxName);
      return box.get(key);
    } catch (e) {
      _logger.severe('Failed to get data from $boxName', e);
      rethrow;
    }
  }

  Future<List<T>> getAllData<T>(String boxName) async {
    try {
      final box = await _boxManager.openBox<T>(boxName);
      return box.values.toList();
    } catch (e) {
      _logger.severe('Failed to get all data from $boxName', e);
      rethrow;
    }
  }

  Future<void> deleteData(String boxName, String key) async {
    try {
      final box = await _boxManager.openBox(boxName);
      await box.delete(key);
      _logger.info('Deleted data from $boxName with key: $key');
    } catch (e) {
      _logger.severe('Failed to delete data from $boxName', e);
      rethrow;
    }
  }

  Future<void> clearBox(String boxName) async {
    try {
      final box = await _boxManager.openBox(boxName);
      await box.clear();
      _logger.info('Cleared box: $boxName');
    } catch (e) {
      _logger.severe('Failed to clear box: $boxName', e);
      rethrow;
    }
  }

  Future<void> closeBox(String boxName) async {
    await _boxManager.closeBox(boxName);
  }

  Future<void> closeAllBoxes() async {
    await _boxManager.closeAllBoxes();
  }
}
