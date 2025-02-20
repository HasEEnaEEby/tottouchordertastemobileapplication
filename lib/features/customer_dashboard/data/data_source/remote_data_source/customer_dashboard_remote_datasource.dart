import 'package:dio/dio.dart';
import 'package:tottouchordertastemobileapplication/app/constants/api_endpoints.dart';
import 'package:tottouchordertastemobileapplication/app/shared_prefs/shared_preferences.dart'; // Import shared preferences
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';

abstract class CustomerDashboardRemoteDataSource {
  Future<List<RestaurantEntity>> getAllRestaurants();
}

class CustomerDashboardRemoteDataSourceImpl
    implements CustomerDashboardRemoteDataSource {
  final Dio dio;
  final SharedPreferencesService _prefs;

  CustomerDashboardRemoteDataSourceImpl({
    required this.dio,
    required SharedPreferencesService prefs,
  }) : _prefs = prefs;

  @override
  Future<List<RestaurantEntity>> getAllRestaurants() async {
    try {
      final String? token = await _prefs.getAuthToken();

      if (token == null || _prefs.isAuthTokenExpired()) {
        await _prefs.removeAuthToken();
        throw Exception("Session expired. Please log in again.");
      }

      // ✅ Send GET request with authentication header
      final response = await dio.get(
        ApiEndpoints.getAllRestaurants,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      // ✅ Check for successful response
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final List<dynamic> data = response.data['data'];
        if (data.isEmpty) {
          throw Exception("No restaurants available.");
        }

        return data
            .map((json) => RestaurantEntity(
                  id: json['_id'] as String,
                  username: json['username'] ?? '',
                  email: json['email'] ?? '',
                  restaurantName: json['restaurantName'] ?? '',
                  location: json['location'] ?? '',
                  contactNumber: json['contactNumber'] ?? '',
                  quote: json['quote'] ?? '',
                  status: json['status'] ?? '',
                  createdAt: DateTime.parse(
                      json['createdAt'] ?? DateTime.now().toString()),
                  updatedAt: DateTime.parse(
                      json['updatedAt'] ?? DateTime.now().toString()),
                ))
            .toList();
      } else {
        throw Exception("Failed to load restaurants: ${response.statusCode}");
      }
    } on DioException catch (e) {
      // ✅ Handle different API errors
      if (e.response?.statusCode == 401) {
        await _prefs.removeAuthToken(); // Clear token if unauthorized
        throw Exception("Unauthorized access. Please log in again.");
      }
      throw Exception(
          "Failed to load restaurants: ${e.response?.statusMessage ?? e.message}");
    } catch (e) {
      throw Exception("Unexpected error: ${e.toString()}");
    }
  }
}
