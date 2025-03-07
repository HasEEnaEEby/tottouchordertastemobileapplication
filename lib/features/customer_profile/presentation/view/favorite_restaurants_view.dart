// Create a new file favorite_restaurants_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/core/config/app_theme.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view/restaurant_dashboard_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_state.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/favorites/favorites_cubit.dart';

class FavoriteRestaurantsView extends StatelessWidget {
  const FavoriteRestaurantsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Restaurants'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearConfirmation(context),
            tooltip: 'Clear all favorites',
          ),
        ],
      ),
      body: BlocBuilder<CustomerDashboardBloc, CustomerDashboardState>(
        builder: (context, dashboardState) {
          if (dashboardState is RestaurantsLoaded) {
            return BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favoritesState) {
                if (favoritesState is FavoritesLoaded) {
                  final favoriteRestaurants = dashboardState.restaurants
                      .where((restaurant) =>
                          favoritesState.favoriteIds.contains(restaurant.id))
                      .toList();

                  if (favoriteRestaurants.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 80,
                            color: isDark ? Colors.white54 : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No favorite restaurants yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the heart icon on restaurants to add them to favorites',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white60 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoriteRestaurants.length,
                    itemBuilder: (context, index) {
                      return _buildFavoriteRestaurantCard(
                          context, favoriteRestaurants[index]);
                    },
                  );
                }

                if (favoritesState is FavoritesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (favoritesState is FavoritesError) {
                  return Center(child: Text(favoritesState.message));
                }

                return const Center(child: CircularProgressIndicator());
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildFavoriteRestaurantCard(
      BuildContext context, RestaurantEntity restaurant) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to restaurant details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RestaurantDashboardView(restaurant: restaurant),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant image
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                image: restaurant.image != null && restaurant.image!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(restaurant.image!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: isDark ? Colors.grey[800] : Colors.grey[300],
              ),
              child: restaurant.image == null || restaurant.image!.isEmpty
                  ? Icon(
                      Icons.restaurant,
                      color: isDark ? Colors.grey[600] : Colors.grey,
                      size: 60,
                    )
                  : null,
            ),

            // Restaurant info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.restaurantName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      BlocBuilder<FavoritesCubit, FavoritesState>(
                        builder: (context, state) {
                          return IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              context
                                  .read<FavoritesCubit>()
                                  .toggleFavorite(restaurant.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Removed ${restaurant.restaurantName} from favorites',
                                  ),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.location,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (restaurant.quote.isNotEmpty)
                    Text(
                      restaurant.quote,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Favorites'),
        content: const Text('Are you sure you want to remove all favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FavoritesCubit>().clearAllFavorites();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All favorites cleared'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
