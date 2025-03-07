import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/bill_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/repository/food_order_repository.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_bloc.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_event.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_state.dart';

import 'food_order_bloc_test.mocks.dart';

@GenerateMocks([FoodOrderRepository])
void main() {
  late MockFoodOrderRepository mockRepository;
  late FoodOrderBloc foodOrderBloc;

  // Sample test data
  final testOrderItems = [
    const OrderItemEntity(
      menuItemId: 'item1',
      name: 'Chicken Burger',
      price: 12.99,
      quantity: 2,
    ),
    const OrderItemEntity(
      menuItemId: 'item2',
      name: 'Fries',
      price: 4.99,
      quantity: 1,
    ),
  ];

  final testFoodOrder = FoodOrderEntity(
    id: 'order123',
    restaurantId: 'rest456',
    tableId: 'table789',
    status: 'active',
    items: testOrderItems,
    totalAmount: 30.97,
    createdAt: DateTime.now(),
    customerId: 'user123',
    customerName: 'John Doe',
    customerEmail: 'john@example.com',
    restaurantName: 'Burger Palace',
    chefName: 'Chef Mike',
    estimatedWaitTimeMinutes: 15,
    orderType: 'dine-in',
  );

  final testBill = BillEntity(
    id: 'bill123',
    billNumber: 'B1001',
    orderId: 'order123',
    restaurantId: 'rest456',
    restaurantName: 'Burger Palace',
    tableId: 'table789',
    subtotal: 30.97,
    tax: 1.55,
    serviceCharge: 3.10,
    totalAmount: 35.62,
    isPaid: false,
    generatedAt: DateTime.now(),
    taxPercentage: 5.0,
    serviceChargePercentage: 10.0,
    items: testOrderItems,
  );

  setUp(() {
    // Use the generated MockFoodOrderRepository
    mockRepository = MockFoodOrderRepository();
    foodOrderBloc = FoodOrderBloc(repository: mockRepository);
  });

  tearDown(() {
    foodOrderBloc.close();
  });

  group('FoodOrderBloc Tests', () {
    // Test 1: Get Order Details
    blocTest<FoodOrderBloc, FoodOrderState>(
      'Test 1: Should emit [FoodOrderLoading, OrderDetailsLoaded] when getting order details is successful',
      build: () {
        when(mockRepository.getOrderById('order123'))
            .thenAnswer((_) async => Right(testFoodOrder));
        return foodOrderBloc;
      },
      act: (bloc) => bloc.add(const GetOrderDetailsEvent('order123')),
      expect: () => [
        FoodOrderLoading(),
        OrderDetailsLoaded(order: testFoodOrder),
      ],
      verify: (_) {
        verify(mockRepository.getOrderById('order123')).called(1);
      },
    );

    // Test 2: Place Order
    blocTest<FoodOrderBloc, FoodOrderState>(
      'Test 2: Should emit [FoodOrderLoading, OrderDetailsLoaded] when placing an order is successful',
      build: () {
        when(mockRepository.placeOrder(any))
            .thenAnswer((_) async => Right(testFoodOrder));
        return foodOrderBloc;
      },
      act: (bloc) => bloc.add(PlaceOrderEvent(
        restaurantId: 'rest456',
        tableId: 'table789',
        items: testOrderItems,
        totalAmount: 30.97,
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
        specialInstructions: 'No onions please',
      )),
      expect: () => [
        FoodOrderLoading(),
        OrderDetailsLoaded(order: testFoodOrder),
      ],
      verify: (_) {
        verify(mockRepository.placeOrder(any)).called(1);
      },
    );

    // Test 3: Cancel Order
    blocTest<FoodOrderBloc, FoodOrderState>(
      'Test 3: Should emit [FoodOrderLoading, OrderCancelled] when cancelling an order is successful',
      build: () {
        when(mockRepository.cancelOrder('order123', reason: 'Changed my mind'))
            .thenAnswer((_) async => Right(testFoodOrder));
        return foodOrderBloc;
      },
      act: (bloc) => bloc.add(const CancelOrderEvent(
        orderId: 'order123',
        reason: 'Changed my mind',
      )),
      expect: () => [
        FoodOrderLoading(),
        const OrderCancelled(
          orderId: 'order123',
          message: 'Order cancelled successfully',
        ),
      ],
      verify: (_) {
        verify(mockRepository.cancelOrder('order123',
                reason: 'Changed my mind'))
            .called(1);
      },
    );

    // Test 4: Fetch Order Bill
    blocTest<FoodOrderBloc, FoodOrderState>(
      'Test 4: Should emit [BillLoading, BillLoaded] when fetching order bill is successful',
      build: () {
        when(mockRepository.getOrderBill('order123'))
            .thenAnswer((_) async => Right(testBill));
        return foodOrderBloc;
      },
      act: (bloc) => bloc.add(const FetchOrderBillEvent(orderId: 'order123')),
      expect: () => [
        const BillLoading(orderId: 'order123'),
        BillLoaded(orderId: 'order123', bill: testBill),
      ],
      verify: (_) {
        verify(mockRepository.getOrderBill('order123')).called(1);
      },
    );

// Test 5: Update Payment Status
    blocTest<FoodOrderBloc, FoodOrderState>(
      'Test 5: Should emit [FoodOrderLoading, PaymentUpdated] when payment status is updated successfully',
      build: () {
        when(mockRepository.updatePaymentStatus('order123', 'paid'))
            .thenAnswer((_) async => Right(testFoodOrder));
        return foodOrderBloc;
      },
      act: (bloc) => bloc.add(const UpdatePaymentStatusEvent(
        orderId: 'order123',
        paymentStatus: 'paid',
      )),
      expect: () => [
        FoodOrderLoading(),
        const PaymentUpdated(
          orderId: 'order123',
          paymentStatus: 'paid',
        ),
      ],
      verify: (_) {
        verify(mockRepository.updatePaymentStatus('order123', 'paid'))
            .called(1);
      },
    );
  });
}
