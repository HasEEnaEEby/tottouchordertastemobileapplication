// lib/food_order/presentation/view_model/food_order/food_order_event.dart
import 'package:equatable/equatable.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';

abstract class FoodOrderEvent extends Equatable {
  const FoodOrderEvent();

  @override
  List<Object?> get props => [];
}

// Fetch order details
class GetOrderDetailsEvent extends FoodOrderEvent {
  final String orderId;

  const GetOrderDetailsEvent(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class FetchOrderDetailsEvent extends FoodOrderEvent {
  final String orderId;

  const FetchOrderDetailsEvent({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

// Order tracking
class TrackOrderEvent extends FoodOrderEvent {
  final String orderId;

  const TrackOrderEvent(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class StopTrackingOrderEvent extends FoodOrderEvent {
  final String orderId;

  const StopTrackingOrderEvent({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class StreamOrderUpdateEvent extends FoodOrderEvent {
  final FoodOrderEntity order;

  const StreamOrderUpdateEvent(this.order);

  @override
  List<Object> get props => [order];
}

class StreamOrderUpdateErrorEvent extends FoodOrderEvent {
  final String message;

  const StreamOrderUpdateErrorEvent(this.message);

  @override
  List<Object> get props => [message];
}

// Order actions
class CancelOrderEvent extends FoodOrderEvent {
  final String orderId;
  final String? reason;

  const CancelOrderEvent({
    required this.orderId,
    this.reason,
  });

  @override
  List<Object?> get props => [orderId, reason];
}

class RateOrderEvent extends FoodOrderEvent {
  final String orderId;
  final int rating;
  final String? feedback;

  const RateOrderEvent({
    required this.orderId,
    required this.rating,
    this.feedback,
  });

  @override
  List<Object?> get props => [orderId, rating, feedback];
}

class RequestBillEvent extends FoodOrderEvent {
  final String orderId;

  const RequestBillEvent({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class FetchOrderBillEvent extends FoodOrderEvent {
  final String orderId;

  const FetchOrderBillEvent({required this.orderId});

  @override
  List<Object> get props => [orderId];
}

class FetchUserOrdersEvent extends FoodOrderEvent {
  const FetchUserOrdersEvent();
}

class PlaceOrderEvent extends FoodOrderEvent {
  final String restaurantId;
  final String tableId;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final String? specialInstructions;
  final String? customerName;
  final String? customerEmail;

  const PlaceOrderEvent({
    required this.restaurantId,
    required this.tableId,
    this.items = const [],
    this.totalAmount = 0.0,
    this.specialInstructions,
    this.customerName,
    this.customerEmail,
  });

  @override
  List<Object?> get props => [
        restaurantId,
        tableId,
        items,
        totalAmount,
        specialInstructions,
        customerName,
        customerEmail,
      ];
}


class UpdatePaymentStatusEvent extends FoodOrderEvent {
  final String orderId;
  final String paymentStatus;

  const UpdatePaymentStatusEvent({
    required this.orderId,
    required this.paymentStatus,
  });

  

  @override
  List<Object> get props => [orderId, paymentStatus];
}
