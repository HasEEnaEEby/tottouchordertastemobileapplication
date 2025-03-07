// lib/food_order/data/data_source/remote_data_source/food_order_remote_datasource.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/app/constants/api_endpoints.dart';
import 'package:tottouchordertastemobileapplication/core/auth/auth_token_manager.dart';
import 'package:tottouchordertastemobileapplication/core/errors/exceptions.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/bill_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';

abstract class FoodOrderRemoteDataSource {
  Future<FoodOrderEntity> createOrder(Map<String, dynamic> orderData);
  Future<FoodOrderEntity> getOrderDetails(String orderId);
  Future<FoodOrderEntity> getOrderById(String orderId);
  Future<FoodOrderEntity> cancelOrder(String orderId, {String? reason});
  Future<List<FoodOrderEntity>> fetchUserOrders();
  Future<BillEntity> getOrderBill(String orderId);
  Future<FoodOrderEntity> placeOrder(OrderRequestEntity orderRequest);
  Future<bool> rateOrder(String orderId, int rating, {String? feedback});
  Future<FoodOrderEntity> requestBill(String orderId);
  Stream<FoodOrderEntity> trackOrderUpdates(String orderId);
  Future<FoodOrderEntity> updatePaymentStatus(
      String orderId, String paymentStatus);
}

class FoodOrderRemoteDataSourceImpl implements FoodOrderRemoteDataSource {
  final Dio dio;
  final AuthTokenManager tokenManager;

  // For real-time tracking
  final Map<String, StreamController<FoodOrderEntity>> _orderStreamControllers =
      {};

  FoodOrderRemoteDataSourceImpl({
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
  Future<FoodOrderEntity> createOrder(Map<String, dynamic> orderData) async {
    try {
      debugPrint('FoodOrderRemoteDataSource: Creating order');

      final response = await dio.post(
        ApiEndpoints.createOrder,
        options: Options(headers: _getHeaders()),
        data: orderData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final orderData = response.data['data']['order'];
        return FoodOrderEntity.fromJson(orderData);
      } else {
        throw ServerException(
            'Failed to create order', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw ServerException(
          e.message ?? 'Failed to create order', e.response?.statusCode ?? 500);
    } catch (e) {
      throw ServerException('Failed to create order: $e', 500);
    }
  }

  @override
  Future<FoodOrderEntity> getOrderDetails(String orderId) async {
    try {
      debugPrint(
          'FoodOrderRemoteDataSource: Getting order details for $orderId');

      final response = await dio.get(
        ApiEndpoints.getOrderById(orderId),
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200) {
        final orderData = response.data['data']['order'];
        final order = FoodOrderEntity.fromJson(orderData);

        // If we have a stream for this order, update it
        if (_orderStreamControllers.containsKey(orderId)) {
          _orderStreamControllers[orderId]!.add(order);
        }

        return order;
      } else {
        throw ServerException(
            'Failed to get order details', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to get order details',
          e.response?.statusCode ?? 500);
    } catch (e) {
      throw ServerException('Failed to get order details: $e', 500);
    }
  }

  @override
  Future<FoodOrderEntity> getOrderById(String orderId) async {
    // This implementation is the same as getOrderDetails
    // but kept separate for clarity in the codebase
    return getOrderDetails(orderId);
  }

  @override
  Future<FoodOrderEntity> cancelOrder(String orderId, {String? reason}) async {
    try {
      debugPrint('FoodOrderRemoteDataSource: Cancelling order $orderId');

      // Create request body with reason if provided
      final Map<String, dynamic> requestData = {};
      if (reason != null && reason.isNotEmpty) {
        requestData['reason'] = reason;
      }

      final response = await dio.post(
        '${ApiEndpoints.getOrderById(orderId)}/cancel',
        options: Options(headers: _getHeaders()),
        data: requestData,
      );

      if (response.statusCode == 200) {
        final orderData = response.data['data']['order'];
        final order = FoodOrderEntity.fromJson(orderData);

        // Update stream if available
        if (_orderStreamControllers.containsKey(orderId)) {
          _orderStreamControllers[orderId]!.add(order);
        }

        return order;
      } else {
        throw ServerException(
            'Failed to cancel order', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw ServerException(
          e.message ?? 'Failed to cancel order', e.response?.statusCode ?? 500);
    } catch (e) {
      throw ServerException('Failed to cancel order: $e', 500);
    }
  }

  @override
  Future<List<FoodOrderEntity>> fetchUserOrders() async {
    try {
      debugPrint('FoodOrderRemoteDataSource: Fetching user orders');

      final response = await dio.get(
        ApiEndpoints.getUserOrders,
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> ordersData = response.data['data']['orders'];
        return ordersData
            .map((json) => FoodOrderEntity.fromJson(json))
            .toList();
      } else {
        throw ServerException(
            'Failed to fetch user orders', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch user orders',
          e.response?.statusCode ?? 500);
    } catch (e) {
      throw ServerException('Failed to fetch user orders: $e', 500);
    }
  }

  @override
  Future<BillEntity> getOrderBill(String orderId) async {
    try {
      debugPrint('FoodOrderRemoteDataSource: Getting bill for order $orderId');

      final response = await dio.get(
        '${ApiEndpoints.getOrderById(orderId)}/bill',
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200) {
        final billData = response.data['data']['bill'];
        return BillEntity.fromJson(billData);
      } else {
        throw ServerException(
            'Failed to get order bill', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to get order bill',
          e.response?.statusCode ?? 500);
    } catch (e) {
      throw ServerException('Failed to get order bill: $e', 500);
    }
  }

  @override
  Future<FoodOrderEntity> placeOrder(OrderRequestEntity orderRequest) async {
    try {
      debugPrint('FoodOrderRemoteDataSource: Placing new order');

      final response = await dio.post(
        ApiEndpoints.createOrder,
        options: Options(headers: _getHeaders()),
        data: orderRequest.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final orderData = response.data['data']['order'];
        return FoodOrderEntity.fromJson(orderData);
      } else {
        throw ServerException(
            'Failed to place order', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw ServerException(
          e.message ?? 'Failed to place order', e.response?.statusCode ?? 500);
    } catch (e) {
      throw ServerException('Failed to place order: $e', 500);
    }
  }

  @override
  Future<bool> rateOrder(String orderId, int rating, {String? feedback}) async {
    try {
      debugPrint('FoodOrderRemoteDataSource: Rating order $orderId');

      final Map<String, dynamic> requestData = {
        'rating': rating,
        if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
      };

      final response = await dio.post(
        '${ApiEndpoints.getOrderById(orderId)}/rate',
        options: Options(headers: _getHeaders()),
        data: requestData,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerException(
            'Failed to rate order', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw ServerException(
          e.message ?? 'Failed to rate order', e.response?.statusCode ?? 500);
    } catch (e) {
      throw ServerException('Failed to rate order: $e', 500);
    }
  }

  @override
  Future<FoodOrderEntity> requestBill(String orderId) async {
    try {
      debugPrint(
          'FoodOrderRemoteDataSource: Requesting bill for order $orderId');

      final response = await dio.post(
        '${ApiEndpoints.getOrderById(orderId)}/request-bill',
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200) {
        final orderData = response.data['data']['order'];
        final order = FoodOrderEntity.fromJson(orderData);

        // Update stream if available
        if (_orderStreamControllers.containsKey(orderId)) {
          _orderStreamControllers[orderId]!.add(order);
        }

        return order;
      } else {
        throw ServerException(
            'Failed to request bill', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw ServerException(
          e.message ?? 'Failed to request bill', e.response?.statusCode ?? 500);
    } catch (e) {
      throw ServerException('Failed to request bill: $e', 500);
    }
  }

  @override
  Stream<FoodOrderEntity> trackOrderUpdates(String orderId) {
    if (!_orderStreamControllers.containsKey(orderId)) {
      _orderStreamControllers[orderId] =
          StreamController<FoodOrderEntity>.broadcast();

      // Set up polling for order updates
      _startOrderPolling(orderId);
    }

    return _orderStreamControllers[orderId]!.stream;
  }

  void _startOrderPolling(String orderId) {
    // Poll the order details every 15 seconds
    Timer.periodic(const Duration(seconds: 15), (timer) async {
      try {
        // Check if the stream still has subscribers
        if (_orderStreamControllers[orderId]?.hasListener ?? false) {
          final order = await getOrderDetails(orderId);
          _orderStreamControllers[orderId]?.add(order);

          // If order is completed or cancelled, stop polling
          if (order.status.toLowerCase() == 'completed' ||
              order.status.toLowerCase() == 'cancelled') {
            timer.cancel();
          }
        } else {
          // No subscribers, cancel the timer
          timer.cancel();
          _orderStreamControllers[orderId]?.close();
          _orderStreamControllers.remove(orderId);
        }
      } catch (e) {
        debugPrint('Error polling order $orderId: $e');
      }
    });
  }

  @override
  Future<FoodOrderEntity> updatePaymentStatus(
      String orderId, String paymentStatus) async {
    try {
      debugPrint(
          'FoodOrderRemoteDataSource: Updating payment status for order $orderId');

      final Map<String, dynamic> requestData = {
        'paymentStatus': paymentStatus,
      };

      final response = await dio.patch(
        '${ApiEndpoints.getOrderById(orderId)}/payment',
        options: Options(headers: _getHeaders()),
        data: requestData,
      );

      if (response.statusCode == 200) {
        final orderData = response.data['data']['order'];
        final order = FoodOrderEntity.fromJson(orderData);

        // Update stream if available
        if (_orderStreamControllers.containsKey(orderId)) {
          _orderStreamControllers[orderId]!.add(order);
        }

        return order;
      } else {
        throw ServerException(
            'Failed to update payment status', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to update payment status',
          e.response?.statusCode ?? 500);
    } catch (e) {
      throw ServerException('Failed to update payment status: $e', 500);
    }
  }

  // Clean up resources when done
  void dispose() {
    for (final controller in _orderStreamControllers.values) {
      controller.close();
    }
    _orderStreamControllers.clear();
  }
}
