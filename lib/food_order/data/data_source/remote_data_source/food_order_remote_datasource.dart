// lib/food_order/data/data_source/remote_data_source/food_order_remote_datasource.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  void stopTrackingOrder(String orderId);
}

class FoodOrderRemoteDataSourceImpl implements FoodOrderRemoteDataSource {
  final Dio dio;
  final AuthTokenManager tokenManager;

  // For real-time tracking
  final Map<String, StreamController<FoodOrderEntity>> _orderStreamControllers =
      {};
  // For tracking active polling Timers
  final Map<String, Timer> _pollingTimers = {};

  FoodOrderRemoteDataSourceImpl({
    required this.dio,
    required this.tokenManager,
  });

  Map<String, String> _getHeaders() {
    final token = tokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    debugPrint('Adding token to request: ${token.substring(0, 15)}...');

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
      debugPrint('DioException creating order: ${e.message}');
      throw ServerException(
          e.message ?? 'Failed to create order', e.response?.statusCode ?? 500);
    } catch (e) {
      debugPrint('Exception creating order: $e');
      throw ServerException('Failed to create order: $e', 500);
    }
  }

  @override
  Future<FoodOrderEntity> getOrderDetails(String orderId) async {
    try {
      debugPrint(
          'FoodOrderRemoteDataSource: Getting order details for $orderId');

      // Add trimming here to ensure consistent ID format
      final cleanOrderId = orderId.trim();

      final response = await dio.get(
        ApiEndpoints.getOrderById(cleanOrderId),
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200) {
        final orderData = response.data['data']['order'];
        final order = FoodOrderEntity.fromJson(orderData);

        debugPrint('Successfully retrieved order: ${order.id}');

        // If we have a stream for this order, update it
        if (_orderStreamControllers.containsKey(cleanOrderId)) {
          _orderStreamControllers[cleanOrderId]!.add(order);
        }

        return order;
      } else {
        throw ServerException(
            'Failed to get order details', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      debugPrint('DioException getting order details: ${e.message}');
      throw ServerException(e.message ?? 'Failed to get order details',
          e.response?.statusCode ?? 500);
    } catch (e) {
      debugPrint('Exception getting order details: $e');
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

      // Clean the order ID first
      final cleanOrderId = orderId.trim();

      // Create request body with reason if provided
      final Map<String, dynamic> requestData = {};
      if (reason != null && reason.isNotEmpty) {
        requestData['reason'] = reason;
      }

      final response = await dio.post(
        '${ApiEndpoints.getOrderById(cleanOrderId)}/cancel',
        options: Options(headers: _getHeaders()),
        data: requestData,
      );

      if (response.statusCode == 200) {
        final orderData = response.data['data']['order'];
        final order = FoodOrderEntity.fromJson(orderData);

        // Update stream if available
        if (_orderStreamControllers.containsKey(cleanOrderId)) {
          _orderStreamControllers[cleanOrderId]!.add(order);
        }

        return order;
      } else {
        throw ServerException(
            'Failed to cancel order', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      debugPrint('DioException cancelling order: ${e.message}');
      throw ServerException(
          e.message ?? 'Failed to cancel order', e.response?.statusCode ?? 500);
    } catch (e) {
      debugPrint('Exception cancelling order: $e');
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
        final orders =
            ordersData.map((json) => FoodOrderEntity.fromJson(json)).toList();

        debugPrint('Successfully retrieved ${orders.length} orders');
        return orders;
      } else {
        throw ServerException(
            'Failed to fetch user orders', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      debugPrint('DioException fetching user orders: ${e.message}');
      throw ServerException(e.message ?? 'Failed to fetch user orders',
          e.response?.statusCode ?? 500);
    } catch (e) {
      debugPrint('Exception fetching user orders: $e');
      throw ServerException('Failed to fetch user orders: $e', 500);
    }
  }

  @override
  Future<BillEntity> getOrderBill(String orderId) async {
    try {
      debugPrint('FoodOrderRemoteDataSource: Getting bill for order $orderId');

      // Clean the order ID first
      final cleanOrderId = orderId.trim();

      final response = await dio.get(
        ApiEndpoints.getBillDetails(cleanOrderId),
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200) {
        final billData = response.data['data']['bill'];
        final bill = BillEntity.fromJson(billData);

        debugPrint('Successfully retrieved bill for order: $cleanOrderId');
        return bill;
      } else {
        throw ServerException(
            'Failed to get order bill', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      debugPrint('DioException getting order bill: ${e.message}');
      throw ServerException(e.message ?? 'Failed to get order bill',
          e.response?.statusCode ?? 500);
    } catch (e) {
      debugPrint('Exception getting order bill: $e');
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
        final order = FoodOrderEntity.fromJson(orderData);

        debugPrint('Successfully placed order: ${order.id}');
        return order;
      } else {
        throw ServerException(
            'Failed to place order', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      debugPrint('DioException placing order: ${e.message}');
      throw ServerException(
          e.message ?? 'Failed to place order', e.response?.statusCode ?? 500);
    } catch (e) {
      debugPrint('Exception placing order: $e');
      throw ServerException('Failed to place order: $e', 500);
    }
  }

  @override
  Future<bool> rateOrder(String orderId, int rating, {String? feedback}) async {
    try {
      debugPrint('FoodOrderRemoteDataSource: Rating order $orderId');

      // Clean the order ID first
      final cleanOrderId = orderId.trim();

      final Map<String, dynamic> requestData = {
        'rating': rating,
        if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
      };

      final response = await dio.post(
        '${ApiEndpoints.getOrderById(cleanOrderId)}/rate',
        options: Options(headers: _getHeaders()),
        data: requestData,
      );

      if (response.statusCode == 200) {
        debugPrint('Successfully rated order: $cleanOrderId');
        return true;
      } else {
        throw ServerException(
            'Failed to rate order', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      debugPrint('DioException rating order: ${e.message}');
      throw ServerException(
          e.message ?? 'Failed to rate order', e.response?.statusCode ?? 500);
    } catch (e) {
      debugPrint('Exception rating order: $e');
      throw ServerException('Failed to rate order: $e', 500);
    }
  }

  @override
  Future<FoodOrderEntity> requestBill(String orderId) async {
    try {
      debugPrint(
          'FoodOrderRemoteDataSource: Requesting bill for order $orderId');

      // Clean the order ID first
      final cleanOrderId = orderId.trim();

      final response = await dio.patch(
        ApiEndpoints.requestBill(cleanOrderId),
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200) {
        final orderData = response.data['data']['order'];
        final order = FoodOrderEntity.fromJson(orderData);

        debugPrint('Successfully requested bill for order: $cleanOrderId');

        // Update stream if available
        if (_orderStreamControllers.containsKey(cleanOrderId)) {
          _orderStreamControllers[cleanOrderId]!.add(order);
        }

        return order;
      } else {
        throw ServerException(
            'Failed to request bill', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      debugPrint('DioException requesting bill: ${e.message}');
      throw ServerException(
          e.message ?? 'Failed to request bill', e.response?.statusCode ?? 500);
    } catch (e) {
      debugPrint('Exception requesting bill: $e');
      throw ServerException('Failed to request bill: $e', 500);
    }
  }

  @override
  Stream<FoodOrderEntity> trackOrderUpdates(String orderId) {
    // Clean the order ID first
    final cleanOrderId = orderId.trim();

    if (!_orderStreamControllers.containsKey(cleanOrderId)) {
      _orderStreamControllers[cleanOrderId] =
          StreamController<FoodOrderEntity>.broadcast();

      // Set up polling for order updates
      _startOrderPolling(cleanOrderId);
    }

    return _orderStreamControllers[cleanOrderId]!.stream;
  }

  void _startOrderPolling(String orderId) {
    // Cancel any existing timer for this order
    _pollingTimers[orderId]?.cancel();

    // Create a new timer with a longer period to avoid excessive API calls
    // Poll the order details every 30 seconds (increased from 15 seconds)
    _pollingTimers[orderId] =
        Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        // Check if the stream still has subscribers
        if (_orderStreamControllers[orderId]?.hasListener ?? false) {
          debugPrint('Polling order $orderId for updates');
          final order = await getOrderDetails(orderId);

          // Only add to the stream if it's not closed
          if (!(_orderStreamControllers[orderId]?.isClosed ?? true)) {
            _orderStreamControllers[orderId]?.add(order);
          }

          // If order is completed or cancelled, stop polling
          if (order.status.toLowerCase() == 'completed' ||
              order.status.toLowerCase() == 'cancelled') {
            debugPrint('Order $orderId is ${order.status}, stopping polling');
            timer.cancel();
            _pollingTimers.remove(orderId);
          }
        } else {
          // No subscribers, cancel the timer
          debugPrint('No subscribers for order $orderId, stopping polling');
          timer.cancel();
          _pollingTimers.remove(orderId);

          if (!(_orderStreamControllers[orderId]?.isClosed ?? true)) {
            _orderStreamControllers[orderId]?.close();
          }
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

      // Clean the order ID first
      final cleanOrderId = orderId.trim();

      final Map<String, dynamic> requestData = {
        'paymentStatus': paymentStatus,
      };

      final response = await dio.patch(
        '${ApiEndpoints.getOrderById(cleanOrderId)}/payment',
        options: Options(headers: _getHeaders()),
        data: requestData,
      );

      if (response.statusCode == 200) {
        final orderData = response.data['data']['order'];
        final order = FoodOrderEntity.fromJson(orderData);

        debugPrint(
            'Successfully updated payment status for order: $cleanOrderId');

        // Update stream if available
        if (_orderStreamControllers.containsKey(cleanOrderId)) {
          _orderStreamControllers[cleanOrderId]!.add(order);
        }

        return order;
      } else {
        throw ServerException(
            'Failed to update payment status', response.statusCode ?? 500);
      }
    } on DioException catch (e) {
      debugPrint('DioException updating payment status: ${e.message}');
      throw ServerException(e.message ?? 'Failed to update payment status',
          e.response?.statusCode ?? 500);
    } catch (e) {
      debugPrint('Exception updating payment status: $e');
      throw ServerException('Failed to update payment status: $e', 500);
    }
  }
  
  // Clean up resources when done
  void dispose() {
    // Cancel all polling timers
    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();

    // Close all stream controllers
    for (final controller in _orderStreamControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _orderStreamControllers.clear();
  }

  @override
  void stopTrackingOrder(String orderId) {
    // Clean the order ID first
    final cleanOrderId = orderId.trim();

    if (_orderStreamControllers.containsKey(cleanOrderId)) {
      debugPrint(
          'FoodOrderRemoteDataSource: Stopping tracking for order $cleanOrderId');

      // Cancel the polling timer if it exists
      _pollingTimers[cleanOrderId]?.cancel();
      _pollingTimers.remove(cleanOrderId);

      // Close the stream controller
      if (!_orderStreamControllers[cleanOrderId]!.isClosed) {
        _orderStreamControllers[cleanOrderId]!.close();
      }
      _orderStreamControllers.remove(cleanOrderId);
    }
  }
}
