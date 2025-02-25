import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../../app/constants/api_endpoints.dart';
import '../../../../../core/auth/auth_token_manager.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../domain/entity/order_entity.dart';
import '../../dto/order_request_dto.dart';

abstract class OrderRemoteDataSource {
  Future<OrderEntity> placeOrder(OrderRequestEntity orderRequest);
  Future<List<OrderEntity>> getCustomerOrders();
  Future<OrderEntity> getOrderById(String orderId);
  Future<String> getOrderStatus(String orderId);
  Future<void> cancelOrder(String orderId);
  Future<OrderEntity> addItemsToOrder(
      String orderId, List<OrderItemEntity> items);
  Future<OrderEntity> requestBill(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;
  final AuthTokenManager tokenManager;

  OrderRemoteDataSourceImpl({
    required this.dio,
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
  Future<OrderEntity> placeOrder(OrderRequestEntity orderRequest) async {
    try {
      debugPrint('RemoteDataSource: Placing order');

      // Convert entity to DTO
      final dto = OrderRequestDto(
        restaurant: orderRequest.restaurantId,
        table: orderRequest.tableId,
        items: orderRequest.items
            .map((item) => OrderItemDto(
                  menuItem: item.menuItemId,
                  name: item.name,
                  price: item.price,
                  quantity: item.quantity,
                  specialInstructions: item.specialInstructions,
                ))
            .toList(),
        totalAmount: orderRequest.totalAmount,
        specialInstructions: orderRequest.specialInstructions,
      );

      final response = await dio.post(
        ApiEndpoints.createOrder,
        options: Options(headers: _getHeaders()),
        data: dto.toJson(),
      );

      if ((response.statusCode == 201 || response.statusCode == 200) &&
          response.data != null) {
        final orderData = response.data['data']['order'];
        return OrderEntity.fromJson(orderData);
      } else {
        throw Exception("Failed to place order");
      }
    } on DioException catch (e) {
      throw ServerException(
          e.message ?? 'Failed to place order', e.response?.statusCode ?? 500);
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
        final List<dynamic> ordersData = response.data['data']['orders'];
        return ordersData.map((json) => OrderEntity.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load orders");
      }
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
        final orderData = response.data['data']['order'];
        return OrderEntity.fromJson(orderData);
      } else {
        throw Exception("Failed to load order details");
      }
    } on DioException catch (e) {
      throw ServerException(
          e.message ?? 'Failed to get order', e.response?.statusCode ?? 500);
    } catch (e) {
      throw Exception("Failed to load order details: $e");
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
      throw ServerException(e.message ?? 'Failed to get order status',
          e.response?.statusCode ?? 500);
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

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("Failed to cancel order");
      }
    } on DioException catch (e) {
      throw ServerException(
          e.message ?? 'Failed to cancel order', e.response?.statusCode ?? 500);
    } catch (e) {
      throw Exception("Failed to cancel order: $e");
    }
  }

  @override
  Future<OrderEntity> addItemsToOrder(
      String orderId, List<OrderItemEntity> items) async {
    try {
      debugPrint('RemoteDataSource: Adding items to order $orderId');

      final itemsDto = items
          .map((item) => OrderItemDto(
                menuItem: item.menuItemId,
                name: item.name,
                price: item.price,
                quantity: item.quantity,
                specialInstructions: item.specialInstructions,
              ))
          .toList();

      final response = await dio.post(
        "${ApiEndpoints.getOrderById(orderId)}/items",
        options: Options(headers: _getHeaders()),
        data: {'items': itemsDto.map((item) => item.toJson()).toList()},
      );

      if (response.statusCode == 200 && response.data != null) {
        final orderData = response.data['data']['order'];
        return OrderEntity.fromJson(orderData);
      } else {
        throw Exception("Failed to add items to order");
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to add items to order',
          e.response?.statusCode ?? 500);
    } catch (e) {
      throw Exception("Failed to add items to order: $e");
    }
  }

  @override
  Future<OrderEntity> requestBill(String orderId) async {
    try {
      debugPrint('RemoteDataSource: Requesting bill for order $orderId');

      final response = await dio.patch(
        "${ApiEndpoints.getOrderById(orderId)}/request-bill",
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final orderData = response.data['data']['order'];
        return OrderEntity.fromJson(orderData);
      } else {
        throw Exception("Failed to request bill");
      }
    } on DioException catch (e) {
      throw ServerException(
          e.message ?? 'Failed to request bill', e.response?.statusCode ?? 500);
    } catch (e) {
      throw Exception("Failed to request bill: $e");
    }
  }
}
