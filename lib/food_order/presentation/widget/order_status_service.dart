import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderStatusService {
  final String baseUrl;
  final String token;

  // In-memory cache for order status
  final Map<String, String> _orderStatusCache = {};

  // Streams for real-time updates
  final Map<String, StreamController<String>> _statusStreamControllers = {};

  OrderStatusService({
    required this.baseUrl,
    required this.token,
  });

  // Get current status for an order
  Future<String> getOrderStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final status = jsonData['data']['order']['status'];

        // Update cache
        _orderStatusCache[orderId] = status;

        // Update stream if it exists
        if (_statusStreamControllers.containsKey(orderId)) {
          _statusStreamControllers[orderId]!.add(status);
        }

        return status;
      } else {
        throw Exception('Failed to load order status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching order status: $e');

      // Return cached status if available, otherwise rethrow
      if (_orderStatusCache.containsKey(orderId)) {
        return _orderStatusCache[orderId]!;
      }
      rethrow;
    }
  }

  // Get a stream of status updates for an order
  Stream<String> getOrderStatusStream(String orderId) {
    // Create a new stream controller if it doesn't exist
    if (!_statusStreamControllers.containsKey(orderId)) {
      _statusStreamControllers[orderId] = StreamController<String>.broadcast();

      // Initialize with current status if available
      if (_orderStatusCache.containsKey(orderId)) {
        _statusStreamControllers[orderId]!.add(_orderStatusCache[orderId]!);
      } else {
        // Fetch initial status
        getOrderStatus(orderId).then((status) {
          _statusStreamControllers[orderId]!.add(status);
        }).catchError((error) {
          _statusStreamControllers[orderId]!.addError(error);
        });
      }
    }

    return _statusStreamControllers[orderId]!.stream;
  }

  // Start polling for status updates (call this when viewing an active order)
  Timer startStatusPolling(String orderId,
      {Duration pollInterval = const Duration(seconds: 10)}) {
    return Timer.periodic(pollInterval, (_) {
      getOrderStatus(orderId);
    });
  }

  // Stop polling for an order (call this when navigating away)
  void stopStatusPolling(Timer timer) {
    timer.cancel();
  }

  // Close stream when no longer needed
  void closeOrderStream(String orderId) {
    if (_statusStreamControllers.containsKey(orderId)) {
      _statusStreamControllers[orderId]!.close();
      _statusStreamControllers.remove(orderId);
    }
  }

  // Clean up all resources
  void dispose() {
    for (final controller in _statusStreamControllers.values) {
      controller.close();
    }
    _statusStreamControllers.clear();
  }
}
