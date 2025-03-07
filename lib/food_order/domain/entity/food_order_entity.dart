import 'package:equatable/equatable.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';

class FoodOrderEntity extends OrderEntity {
  // Additional properties specific to food orders that might not be in the base OrderEntity
  final String? restaurantName;
  final String? chefName;
  final int? estimatedWaitTimeMinutes;
  final String? orderType; // dine-in, takeout, etc.
  final List<OrderStatusUpdate>? statusHistory;

  const FoodOrderEntity({
    required super.id,
    required super.restaurantId,
    required super.tableId,
    required super.status,
    required super.items,
    required super.totalAmount,
    required super.createdAt,
    super.completedAt,
    super.specialInstructions,
    super.customerId,
    super.customerName,
    super.customerEmail,
    this.restaurantName,
    this.chefName,
    this.estimatedWaitTimeMinutes,
    this.orderType,
    this.statusHistory,
  });

  /// Factory constructor to create FoodOrderEntity from JSON map
  factory FoodOrderEntity.fromJson(Map<String, dynamic> json) {
    // Get base order properties first
    final OrderEntity baseOrder = OrderEntity.fromJson(json);

    // Parse status history if available
    List<OrderStatusUpdate>? statusHistory;
    if (json['statusHistory'] != null) {
      statusHistory = (json['statusHistory'] as List)
          .map((status) => OrderStatusUpdate.fromJson(status))
          .toList();
    }

    // Create extended food order entity
    return FoodOrderEntity(
      id: baseOrder.id,
      restaurantId: baseOrder.restaurantId,
      tableId: baseOrder.tableId,
      status: baseOrder.status,
      items: baseOrder.items,
      totalAmount: baseOrder.totalAmount,
      createdAt: baseOrder.createdAt,
      completedAt: baseOrder.completedAt,
      specialInstructions: baseOrder.specialInstructions,
      customerId: baseOrder.customerId,
      customerName: baseOrder.customerName,
      customerEmail: baseOrder.customerEmail,
      restaurantName: json['restaurantName'],
      chefName: json['chefName'],
      estimatedWaitTimeMinutes: json['estimatedWaitTimeMinutes'],
      orderType: json['orderType'] ?? 'dine-in',
      statusHistory: statusHistory,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json.addAll({
      'restaurantName': restaurantName,
      'chefName': chefName,
      'estimatedWaitTimeMinutes': estimatedWaitTimeMinutes,
      'orderType': orderType,
      'statusHistory': statusHistory?.map((update) => update.toJson()).toList(),
    });
    return json;
  }

  /// Create a copy of the current order with updated fields
  FoodOrderEntity copyWith({
    String? id,
    String? restaurantId,
    String? tableId,
    String? status,
    List<OrderItemEntity>? items,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? completedAt,
    String? specialInstructions,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? restaurantName,
    String? chefName,
    int? estimatedWaitTimeMinutes,
    String? orderType,
    List<OrderStatusUpdate>? statusHistory,
  }) {
    return FoodOrderEntity(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      tableId: tableId ?? this.tableId,
      status: status ?? this.status,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      restaurantName: restaurantName ?? this.restaurantName,
      chefName: chefName ?? this.chefName,
      estimatedWaitTimeMinutes:
          estimatedWaitTimeMinutes ?? this.estimatedWaitTimeMinutes,
      orderType: orderType ?? this.orderType,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }

  /// Helper method to get progress percentage based on order status
  double getProgressPercentage() {
    switch (status.toLowerCase()) {
      case 'active':
        return 0.2;
      case 'preparing':
        return 0.5;
      case 'ready':
        return 0.8;
      case 'completed':
        return 1.0;
      case 'billing':
        return 0.9;
      case 'cancelled':
        return 1.0;
      default:
        return 0.0;
    }
  }

  /// Helper to get user-friendly status text
  String get statusText {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Order Received';
      case 'preparing':
        return 'Preparing Your Food';
      case 'ready':
        return 'Your Food is Ready';
      case 'completed':
        return 'Order Completed';
      case 'billing':
        return 'Billing & Payment';
      case 'cancelled':
        return 'Order Cancelled';
      default:
        return 'Unknown Status';
    }
  }

  /// Calculate expected completion time based on status and creation time
  DateTime? getExpectedCompletionTime() {
    if (status.toLowerCase() == 'completed' && completedAt != null) {
      return completedAt;
    }

    // If we have an estimated wait time, use it
    if (estimatedWaitTimeMinutes != null) {
      return createdAt.add(Duration(minutes: estimatedWaitTimeMinutes!));
    }

    // Otherwise make a rough estimate based on status and number of items
    int estimatedMinutes = 0;

    switch (status.toLowerCase()) {
      case 'active':
        estimatedMinutes = items.length * 3; // Rough estimate
        break;
      case 'preparing':
        estimatedMinutes = items.length * 2; // Less time as already preparing
        break;
      case 'ready':
        estimatedMinutes = 0; // Ready now
        break;
      default:
        estimatedMinutes = items.length * 5; // Conservative default
    }

    return createdAt.add(Duration(minutes: estimatedMinutes));
  }

  /// Check if order is currently being prepared
  bool get isPreparingNow => status.toLowerCase() == 'preparing';

  /// Check if order can be cancelled (only before it's ready)
  bool get canBeCancelled {
    final lowerStatus = status.toLowerCase();
    return lowerStatus == 'active' || lowerStatus == 'preparing';
  }

  @override
  List<Object?> get props => [
        ...super.props,
        restaurantName,
        chefName,
        estimatedWaitTimeMinutes,
        orderType,
        statusHistory,
      ];
}

/// Class to track order status updates
class OrderStatusUpdate extends Equatable {
  final String status;
  final DateTime timestamp;
  final String? message;

  const OrderStatusUpdate({
    required this.status,
    required this.timestamp,
    this.message,
  });

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdate(
      status: json['status'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
    };
  }

  @override
  List<Object?> get props => [status, timestamp, message];
}
