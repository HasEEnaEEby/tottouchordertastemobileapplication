// lib/food_order/presentation/view_model/food_order/food_order_bloc.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/repository/food_order_repository.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_event.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_state.dart';

class FoodOrderBloc extends Bloc<FoodOrderEvent, FoodOrderState> {
  final FoodOrderRepository repository;
  StreamSubscription? _orderTrackingSubscription;

  // Add tracking properties to avoid redundant calls
  String? _lastFetchedOrderId;
  DateTime? _lastFetchTime;
  String? _lastFetchedBillOrderId;
  DateTime? _lastBillFetchTime;

  FoodOrderBloc({required this.repository}) : super(FoodOrderInitial()) {
    // Fetch order details
    on<GetOrderDetailsEvent>(_onGetOrderDetails);
    on<FetchOrderDetailsEvent>(_onFetchOrderDetails);

    // Order tracking
    on<TrackOrderEvent>(_onTrackOrder);
    on<StopTrackingOrderEvent>(_onStopTrackingOrder);
    on<StreamOrderUpdateEvent>(_onStreamOrderUpdate);
    on<StreamOrderUpdateErrorEvent>(_onStreamOrderUpdateError);

    // Order actions
    on<CancelOrderEvent>(_onCancelOrder);
    on<RateOrderEvent>(_onRateOrder);
    on<RequestBillEvent>(_onRequestBill);
    on<FetchOrderBillEvent>(_onFetchOrderBill);
    on<FetchUserOrdersEvent>(_onFetchUserOrders);
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<UpdatePaymentStatusEvent>(_onUpdatePaymentStatus);
  }

  // Order details handlers
  Future<void> _onGetOrderDetails(
      GetOrderDetailsEvent event, Emitter<FoodOrderState> emit) async {
    emit(FoodOrderLoading());

    try {
      final result = await repository.getOrderById(event.orderId);

      result.fold(
        (failure) => emit(FoodOrderError(failure.message)),
        (order) => emit(OrderDetailsLoaded(order: order)),
      );
    } catch (e) {
      emit(FoodOrderError(e.toString()));
    }
  }

  Future<void> _onFetchOrderDetails(
      FetchOrderDetailsEvent event, Emitter<FoodOrderState> emit) async {
    // Check if we've recently fetched this order to avoid redundant calls
    final now = DateTime.now();
    if (_lastFetchedOrderId == event.orderId &&
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!).inSeconds < 5) {
      // Skip this fetch if we've already fetched the same order within 5 seconds
      debugPrint('Skipping redundant order details fetch for ${event.orderId}');
      return;
    }

    // Don't show loading state for short refreshes or if already loaded with the same order
    bool shouldShowLoading = true;
    if (state is OrderDetailsLoaded) {
      final loadedState = state as OrderDetailsLoaded;
      if (loadedState.order.id == event.orderId) {
        shouldShowLoading = false;
      }
    }

    if (shouldShowLoading) {
      emit(FoodOrderLoading());
    }

    try {
      final result = await repository.getOrderDetails(event.orderId);

      _lastFetchedOrderId = event.orderId;
      _lastFetchTime = now;

      result.fold(
        (failure) => emit(FoodOrderError(failure.message)),
        (order) => emit(OrderDetailsLoaded(order: order)),
      );
    } catch (e) {
      emit(FoodOrderError(e.toString()));
    }
  }

  // Order tracking handlers
  Future<void> _onTrackOrder(
      TrackOrderEvent event, Emitter<FoodOrderState> emit) async {
    try {
      // Cancel existing subscription if any
      await _orderTrackingSubscription?.cancel();

      // Start tracking order updates
      final orderUpdates = repository.trackOrderUpdates(event.orderId);

      _orderTrackingSubscription = orderUpdates.listen(
        (result) {
          result.fold(
            (failure) => add(StreamOrderUpdateErrorEvent(failure.message)),
            (order) => add(StreamOrderUpdateEvent(order)),
          );
        },
        onError: (error) {
          add(StreamOrderUpdateErrorEvent(error.toString()));
        },
      );
    } catch (e) {
      emit(FoodOrderError(e.toString()));
    }
  }

  Future<void> _onStopTrackingOrder(
      StopTrackingOrderEvent event, Emitter<FoodOrderState> emit) async {
    try {
      // Cancel the stream subscription
      await _orderTrackingSubscription?.cancel();
      _orderTrackingSubscription = null;

      // Stop tracking in the repository
      repository.stopTrackingOrder(event.orderId);

      // Clear tracking properties for this order
      if (_lastFetchedOrderId == event.orderId) {
        _lastFetchedOrderId = null;
        _lastFetchTime = null;
      }

      if (_lastFetchedBillOrderId == event.orderId) {
        _lastFetchedBillOrderId = null;
        _lastBillFetchTime = null;
      }
    } catch (e) {
      debugPrint('Error stopping order tracking: $e');
    }
  }

  void _onStreamOrderUpdate(
      StreamOrderUpdateEvent event, Emitter<FoodOrderState> emit) {
    emit(OrderDetailsLoaded(order: event.order));
  }

  void _onStreamOrderUpdateError(
      StreamOrderUpdateErrorEvent event, Emitter<FoodOrderState> emit) {
    emit(FoodOrderError(event.message));
  }

  // Order actions handlers
  Future<void> _onCancelOrder(
      CancelOrderEvent event, Emitter<FoodOrderState> emit) async {
    emit(FoodOrderLoading());

    try {
      final result = await repository.cancelOrder(
        event.orderId,
        reason: event.reason,
      );

      result.fold(
        (failure) => emit(FoodOrderError(failure.message)),
        (order) => emit(OrderCancelled(
          orderId: order.id,
          message: 'Order cancelled successfully',
        )),
      );
    } catch (e) {
      emit(FoodOrderError(e.toString()));
    }
  }

  Future<void> _onRateOrder(
      RateOrderEvent event, Emitter<FoodOrderState> emit) async {
    emit(FoodOrderLoading());

    try {
      final result = await repository.rateOrder(
        event.orderId,
        event.rating,
        feedback: event.feedback,
      );

      result.fold(
        (failure) => emit(FoodOrderError(failure.message)),
        (success) => emit(OrderRated(
          orderId: event.orderId,
          rating: event.rating,
          feedback: event.feedback,
        )),
      );
    } catch (e) {
      emit(FoodOrderError(e.toString()));
    }
  }

  Future<void> _onRequestBill(
      RequestBillEvent event, Emitter<FoodOrderState> emit) async {
    emit(FoodOrderLoading());

    try {
      final result = await repository.requestBill(event.orderId);

      result.fold(
        (failure) => emit(FoodOrderError(failure.message)),
        (order) => emit(OrderDetailsLoaded(order: order)),
      );
    } catch (e) {
      emit(FoodOrderError(e.toString()));
    }
  }

  Future<void> _onFetchOrderBill(
      FetchOrderBillEvent event, Emitter<FoodOrderState> emit) async {
    // Check if we've recently fetched this bill to avoid redundant calls
    final now = DateTime.now();
    if (_lastFetchedBillOrderId == event.orderId &&
        _lastBillFetchTime != null &&
        now.difference(_lastBillFetchTime!).inSeconds < 5) {
      // Skip this fetch if we've already fetched the same bill within 5 seconds
      debugPrint('Skipping redundant bill fetch for ${event.orderId}');
      return;
    }

    emit(BillLoading(orderId: event.orderId));

    try {
      final result = await repository.getOrderBill(event.orderId);

      _lastFetchedBillOrderId = event.orderId;
      _lastBillFetchTime = now;

      result.fold(
        (failure) => emit(BillError(
          orderId: event.orderId,
          message: failure.message,
        )),
        (bill) => emit(BillLoaded(
          orderId: event.orderId,
          bill: bill,
        )),
      );
    } catch (e) {
      emit(BillError(
        orderId: event.orderId,
        message: e.toString(),
      ));
    }
  }

  Future<void> _onFetchUserOrders(
      FetchUserOrdersEvent event, Emitter<FoodOrderState> emit) async {
    emit(FoodOrderLoading());

    try {
      final result = await repository.fetchUserOrders();

      result.fold(
        (failure) => emit(FoodOrderError(failure.message)),
        (orders) {
          // Sort orders by date (newest first)
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Prioritize active orders
          final activeOrders = orders
              .where((order) =>
                  order.status == 'active' ||
                  order.status == 'preparing' ||
                  order.status == 'ready')
              .toList();

          // If there are active orders, move them to the beginning of the list
          if (activeOrders.isNotEmpty) {
            orders.removeWhere((order) => activeOrders.contains(order));
            orders.insertAll(0, activeOrders);
          }

          emit(FoodOrdersLoaded(orders: orders));
        },
      );
    } catch (e) {
      emit(FoodOrderError(e.toString()));
    }
  }

  Future<void> _onPlaceOrder(
      PlaceOrderEvent event, Emitter<FoodOrderState> emit) async {
    emit(FoodOrderLoading());

    try {
      // Convert OrderRequestEntity to FoodOrderEntity
      final orderRequest = OrderRequestEntity(
        restaurantId: event.restaurantId,
        tableId: event.tableId,
        items: event.items,
        totalAmount: event.totalAmount,
        specialInstructions: event.specialInstructions,
        customerName: event.customerName,
        customerEmail: event.customerEmail,
      );

      final result = await repository.placeOrder(orderRequest);

      result.fold(
        (failure) => emit(FoodOrderError(failure.message)),
        (order) => emit(OrderDetailsLoaded(order: order)),
      );
    } catch (e) {
      emit(FoodOrderError(e.toString()));
    }
  }

  Future<void> _onUpdatePaymentStatus(
      UpdatePaymentStatusEvent event, Emitter<FoodOrderState> emit) async {
    emit(FoodOrderLoading());

    try {
      final result = await repository.updatePaymentStatus(
        event.orderId,
        event.paymentStatus,
      );

      result.fold(
        (failure) => emit(FoodOrderError(failure.message)),
        (order) => emit(PaymentUpdated(
          orderId: order.id,
          paymentStatus: event.paymentStatus,
        )),
      );
    } catch (e) {
      emit(FoodOrderError(e.toString()));
    }
  }



  @override
  Future<void> close() {
    _orderTrackingSubscription?.cancel();
    return super.close();
  }
}
