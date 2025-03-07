import 'package:logging/logging.dart';
import 'package:tottouchordertastemobileapplication/app/constants/hive_table_constants.dart';
import 'package:tottouchordertastemobileapplication/core/network/hive_service.dart';

class FavoritesService {
  final HiveService _hiveService;
  final Logger _logger = Logger('FavoritesService');

  static const String _favoriteRestaurantsKey = 'favorite_restaurants';

  FavoritesService({required HiveService hiveService})
      : _hiveService = hiveService;

  Future<List<String>> getFavoriteRestaurantIds() async {
    try {
      final List<String>? favoriteIds =
          await _hiveService.getData<List<String>>(
        HiveTableConstants.settingsTable,
        _favoriteRestaurantsKey,
      );
      return favoriteIds ?? [];
    } catch (e) {
      _logger.severe('Error fetching favorite restaurant IDs: $e');
      return [];
    }
  }

  Future<bool> isRestaurantFavorite(String restaurantId) async {
    try {
      final favoriteIds = await getFavoriteRestaurantIds();
      return favoriteIds.contains(restaurantId);
    } catch (e) {
      _logger.severe('Error checking if restaurant is favorite: $e');
      return false;
    }
  }

  Future<bool> toggleFavoriteRestaurant(String restaurantId) async {
    try {
      final List<String> favoriteIds = await getFavoriteRestaurantIds();
      final bool isFavorite = favoriteIds.contains(restaurantId);

      if (isFavorite) {
        // Remove from favorites
        favoriteIds.remove(restaurantId);
        await _hiveService.saveData<List<String>>(
          HiveTableConstants.settingsTable,
          _favoriteRestaurantsKey,
          favoriteIds,
        );
        _logger.info('Removed restaurant $restaurantId from favorites');
        return false;
      } else {
        // Add to favorites
        favoriteIds.add(restaurantId);
        await _hiveService.saveData<List<String>>(
          HiveTableConstants.settingsTable,
          _favoriteRestaurantsKey,
          favoriteIds,
        );
        _logger.info('Added restaurant $restaurantId to favorites');
        return true;
      }
    } catch (e) {
      _logger.severe('Error toggling favorite status: $e');
      return false;
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      await _hiveService.saveData<List<String>>(
        HiveTableConstants.settingsTable,
        _favoriteRestaurantsKey,
        [],
      );
      _logger.info('All favorites cleared');
    } catch (e) {
      _logger.severe('Error clearing favorites: $e');
    }
  }
}
