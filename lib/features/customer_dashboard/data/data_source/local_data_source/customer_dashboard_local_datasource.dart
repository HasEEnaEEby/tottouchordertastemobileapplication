// lib/features/customer_dashboard/data/data_source/local_data_source/customer_dashboard_local_datasource.dart
import 'package:hive/hive.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/model/restaurant_hive_model.dart';


class CustomerDashboardLocalDataSource {
  static const String _restaurantBoxName = 'restaurants';

  Future<void> cacheRestaurants(List<RestaurantHiveModel> restaurants) async {
    final box = await Hive.openBox<RestaurantHiveModel>(_restaurantBoxName);

    // Clear existing data and add new restaurants
    await box.clear();
    await box.addAll(restaurants);
  }

  Future<List<RestaurantHiveModel>> getCachedRestaurants() async {
    final box = await Hive.openBox<RestaurantHiveModel>(_restaurantBoxName);
    return box.values.toList();
  }

  Future<bool> hasCachedRestaurants() async {
    final box = await Hive.openBox<RestaurantHiveModel>(_restaurantBoxName);
    return box.isNotEmpty;
  }
}
