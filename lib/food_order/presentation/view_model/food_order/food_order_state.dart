// lib/food_order/presentation/view_model/food_order/food_order_state.dart

import 'package:equatable/equatable.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/bill_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';

abstract class FoodOrderState extends Equatable {
  const FoodOrderState();

  @override
  List<Object?> get props => [];
}

// Basic states
class FoodOrderInitial extends FoodOrderState {}

class FoodOrderLoading extends FoodOrderState {}

class FoodOrderError extends FoodOrderState {
  final String message;

  const FoodOrderError(this.message);

  @override
  List<Object> get props => [message];
}

// Order loading states
class FoodOrdersLoaded extends FoodOrderState {
  final List<FoodOrderEntity> orders;
  final FoodOrderEntity? selectedOrder;

  // Remove const keyword since orders is a non-constant List
  const FoodOrdersLoaded({
    required this.orders,
    this.selectedOrder,
  });

  @override
  List<Object?> get props => [orders, selectedOrder];
}

class OrderDetailsLoaded extends FoodOrderState {
  final FoodOrderEntity order;

  // Remove const since FoodOrderEntity might not be a const value
  const OrderDetailsLoaded({
    required this.order,
  });

  @override
  List<Object?> get props => [order];
}

// Order action states
class OrderCancelled extends FoodOrderState {
  final String orderId;
  final String message;

  const OrderCancelled({
    required this.orderId,
    required this.message,
  });

  @override
  List<Object?> get props => [orderId, message];
}

// Bill states
class BillLoading extends FoodOrderState {
  final String orderId;

  const BillLoading({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class BillLoaded extends FoodOrderState {
  final String orderId;
  final BillEntity bill;

  // Remove const since BillEntity might not be a const value
  const BillLoaded({
    required this.orderId,
    required this.bill,
  });

  @override
  List<Object?> get props => [orderId, bill];
}

class BillError extends FoodOrderState {
  final String orderId;
  final String message;

  const BillError({
    required this.orderId,
    required this.message,
  });

  @override
  List<Object?> get props => [orderId, message];
}

// Order rating states
class OrderRated extends FoodOrderState {
  final String orderId;
  final int rating;
  final String? feedback;

  const OrderRated({
    required this.orderId,
    required this.rating,
    this.feedback,
  });

  @override
  List<Object?> get props => [orderId, rating, feedback];
}

// Payment states
class PaymentUpdated extends FoodOrderState {
  final String orderId;
  final String paymentStatus;

  const PaymentUpdated({
    required this.orderId,
    required this.paymentStatus,
  });

  @override
  List<Object?> get props => [orderId, paymentStatus];
}
