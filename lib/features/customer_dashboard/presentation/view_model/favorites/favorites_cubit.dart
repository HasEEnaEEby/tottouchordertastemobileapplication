import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:tottouchordertastemobileapplication/core/services/favorites_service.dart';

// Define our states
abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<String> favoriteIds;
  FavoritesLoaded(this.favoriteIds);
}

class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesService _favoritesService;
  final Logger _logger = Logger('FavoritesCubit');

  FavoritesCubit({required FavoritesService favoritesService})
      : _favoritesService = favoritesService,
        super(FavoritesInitial()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    emit(FavoritesLoading());
    try {
      final favoriteIds = await _favoritesService.getFavoriteRestaurantIds();
      emit(FavoritesLoaded(favoriteIds));
    } catch (e) {
      _logger.severe('Error loading favorites: $e');
      emit(FavoritesError('Failed to load favorites: $e'));
    }
  }

  Future<void> toggleFavorite(String restaurantId) async {
    try {
      final currentState = state;
      List<String> updatedFavorites = [];

      if (currentState is FavoritesLoaded) {
        updatedFavorites = List.from(currentState.favoriteIds);

        // Update local UI state first for responsiveness
        if (updatedFavorites.contains(restaurantId)) {
          updatedFavorites.remove(restaurantId);
        } else {
          updatedFavorites.add(restaurantId);
        }

        emit(FavoritesLoaded(updatedFavorites));
      }

      // Then update in storage
      await _favoritesService.toggleFavoriteRestaurant(restaurantId);
    } catch (e) {
      _logger.severe('Error toggling favorite: $e');
      emit(FavoritesError('Failed to update favorite: $e'));
    }
  }

  bool isFavorite(String restaurantId) {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      return currentState.favoriteIds.contains(restaurantId);
    }
    return false;
  }

  Future<void> clearAllFavorites() async {
    emit(FavoritesLoading());
    try {
      await _favoritesService.clearAllFavorites();
      emit(FavoritesLoaded([]));
    } catch (e) {
      _logger.severe('Error clearing favorites: $e');
      emit(FavoritesError('Failed to clear favorites: $e'));
    }
  }
}
