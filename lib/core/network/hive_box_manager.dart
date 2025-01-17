import 'package:hive/hive.dart';
import 'package:logging/logging.dart';

class HiveBoxManager {
  static final HiveBoxManager _instance = HiveBoxManager._internal();
  final Logger _logger = Logger('HiveBoxManager');
  final Map<String, Box> _boxes = {};

  factory HiveBoxManager() {
    return _instance;
  }

  HiveBoxManager._internal();

  Future<Box<T>> openBox<T>(String boxName) async {
    try {
      if (_boxes.containsKey(boxName)) {
        final box = _boxes[boxName];
        if (box is Box<T>) {
          return box;
        } else {
          await box?.close();
          _boxes.remove(boxName);
        }
      }

      final box = await Hive.openBox<T>(boxName);
      _boxes[boxName] = box;
      _logger.info('Opened box: $boxName');
      return box;
    } catch (e) {
      _logger.severe('Failed to open box: $boxName', e);
      rethrow;
    }
  }

  Future<void> closeBox(String boxName) async {
    try {
      final box = _boxes[boxName];
      if (box != null) {
        await box.close();
        _boxes.remove(boxName);
        _logger.info('Closed box: $boxName');
      }
    } catch (e) {
      _logger.severe('Failed to close box: $boxName', e);
      rethrow;
    }
  }

  Future<void> closeAllBoxes() async {
    try {
      for (var boxName in _boxes.keys.toList()) {
        await closeBox(boxName);
      }
      _logger.info('Closed all boxes');
    } catch (e) {
      _logger.severe('Failed to close all boxes', e);
      rethrow;
    }
  }
}
