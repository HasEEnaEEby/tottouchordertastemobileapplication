import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/app/constants/api_endpoints.dart';
import 'package:tottouchordertastemobileapplication/app/shared_prefs/shared_preferences.dart';
import 'package:tottouchordertastemobileapplication/core/auth/auth_token_manager.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/dto/order_request_dto.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/menu_item_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';

abstract class CustomerDashboardRemoteDataSource {
  Future<List<RestaurantEntity>> getAllRestaurants();
  Future<RestaurantEntity> getRestaurantDetails(String restaurantId);
  Future<List<MenuItemEntity>> getRestaurantMenu(String restaurantId);
  Future<List<TableEntity>> getRestaurantTables(String restaurantId);
  Future<TableEntity> getTableDetails(String tableId);
  Future<OrderEntity> placeOrder(OrderRequestDto orderRequest);
  Future<List<OrderEntity>> getCustomerOrders();
  Future<OrderEntity> getOrderById(String orderId);
  Future<String> getOrderStatus(String orderId);
  Future<void> cancelOrder(String orderId);
}

class CustomerDashboardRemoteDataSourceImpl
    implements CustomerDashboardRemoteDataSource {
  final Dio dio;
  final SharedPreferencesService prefs;
  final AuthTokenManager tokenManager;

  CustomerDashboardRemoteDataSourceImpl({
    required this.dio,
    required this.prefs,
    required this.tokenManager,
  });

  Map<String, String> _getHeaders() {
    final token = tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<List<RestaurantEntity>> getAllRestaurants() async {
    try {
      debugPrint('RemoteDataSource: Getting all restaurants');

      final response = await dio.get(
        ApiEndpoints.getAllRestaurants,
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => RestaurantEntity.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load restaurants");
      }
    } on DioException catch (e) {
      debugPrint('DioError: ${e.message}');
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception("Session expired. Please log in again.");
      }
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      debugPrint('Error: $e');
      throw Exception("Failed to load restaurants: $e");
    }
  }

  @override
  Future<RestaurantEntity> getRestaurantDetails(String restaurantId) async {
    try {
      debugPrint(
          'RemoteDataSource: Getting restaurant details for $restaurantId');

      final response = await dio.get(
        ApiEndpoints.getRestaurantDetails(restaurantId),
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final json = response.data['data'];
        return RestaurantEntity.fromJson(json);
      } else {
        throw Exception("Failed to load restaurant details");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("Restaurant not found");
      } else if (e.response?.statusCode == 403) {
        throw Exception("Access denied");
      }
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to load restaurant details: $e");
    }
  }

  @override
  Future<List<MenuItemEntity>> getRestaurantMenu(String restaurantId) async {
    try {
      debugPrint('RemoteDataSource: Getting menu for restaurant $restaurantId');

      final response = await dio.get(
        ApiEndpoints.getRestaurantMenu(restaurantId),
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> menuItemsJson = response.data['data'];
        return menuItemsJson
            .map((json) => MenuItemEntity.fromJson(json))
            .toList();
      } else {
        throw Exception("Failed to load menu");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      } else if (e.response?.statusCode == 403) {
        throw Exception("Access denied");
      }
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to load menu: $e");
    }
  }

  @override
  Future<List<TableEntity>> getRestaurantTables(String restaurantId) async {
    try {
      debugPrint(
          'RemoteDataSource: Getting tables for restaurant $restaurantId');

      final response = await dio.get(
        ApiEndpoints.getRestaurantTables(restaurantId),
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> tablesJson = response.data['data'];
        return tablesJson.map((json) => TableEntity.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load tables");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      } else if (e.response?.statusCode == 403) {
        throw Exception("Access denied");
      }
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to load tables: $e");
    }
  }

  @override
  Future<TableEntity> getTableDetails(String tableId) async {
    try {
      debugPrint('RemoteDataSource: Getting details for table $tableId');

      final response = await dio.get(
        ApiEndpoints.getTableById(tableId),
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final json = response.data['data'];
        return TableEntity.fromJson(json);
      } else {
        throw Exception("Failed to load table details");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("Table not found");
      } else if (e.response?.statusCode == 403) {
        throw Exception("Access denied");
      }
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to load table details: $e");
    }
  }

  @override
  Future<OrderEntity> placeOrder(OrderRequestDto orderRequest) async {
    try {
      debugPrint('RemoteDataSource: Placing order');

      final response = await dio.post(
        ApiEndpoints.createOrder,
        options: Options(headers: _getHeaders()),
        data: orderRequest.toJson(),
      );

      if ((response.statusCode == 201 || response.statusCode == 200) &&
          response.data != null) {
        final json = response.data['data'];
        return OrderEntity.fromJson(json);
      } else {
        throw Exception("Failed to place order");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("Access denied");
      }
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to place order: $e");
    }
  }

  @override
  Future<List<OrderEntity>> getCustomerOrders() async {
    try {
      debugPrint('RemoteDataSource: Getting customer orders');

      final response = await dio.get(
        ApiEndpoints.getCustomerOrders,
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> ordersJson = response.data['data'];
        return ordersJson.map((json) => OrderEntity.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load orders");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      } else if (e.response?.statusCode == 403) {
        throw Exception("Access denied");
      }
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to load orders: $e");
    }
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    try {
      debugPrint('RemoteDataSource: Getting order details for $orderId');

      final response = await dio.get(
        ApiEndpoints.getOrderById(orderId),
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final json = response.data['data'];
        return OrderEntity.fromJson(json);
      } else {
        throw Exception("Failed to load order");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("Order not found");
      } else if (e.response?.statusCode == 403) {
        throw Exception("Access denied");
      }
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to load order: $e");
    }
  }

  @override
  Future<String> getOrderStatus(String orderId) async {
    try {
      debugPrint('RemoteDataSource: Getting status for order $orderId');

      final response = await dio.get(
        ApiEndpoints.updateOrderStatus(orderId),
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['data']['status'] ?? 'unknown';
      } else {
        throw Exception("Failed to load order status");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("Order not found");
      } else if (e.response?.statusCode == 403) {
        throw Exception("Access denied");
      }
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to load order status: $e");
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    try {
      debugPrint('RemoteDataSource: Cancelling order $orderId');

      final response = await dio.delete(
        ApiEndpoints.cancelOrder(orderId),
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw Exception("Failed to cancel order");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("Order not found");
      } else if (e.response?.statusCode == 403) {
        throw Exception("Access denied");
      }
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      throw Exception("Failed to cancel order: $e");
    }
  }
}
