import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/order_repository.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/use_case/order_usecases.dart';

// Generate mocks for repository
@GenerateMocks([OrderRepository])
import 'order_usecases_test.mocks.dart';

void main() {
  late MockOrderRepository mockOrderRepository;
  late PlaceOrderUseCase placeOrderUseCase;
  late GetCustomerOrdersUseCase getCustomerOrdersUseCase;
  late GetOrderByIdUseCase getOrderByIdUseCase;
  late RequestBillUseCase requestBillUseCase;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    placeOrderUseCase = PlaceOrderUseCase(mockOrderRepository);
    getCustomerOrdersUseCase = GetCustomerOrdersUseCase(mockOrderRepository);
    getOrderByIdUseCase = GetOrderByIdUseCase(mockOrderRepository);
    requestBillUseCase = RequestBillUseCase(mockOrderRepository);
  });

  // Test data
  const testOrderId = 'test-order-id';

  final testOrderItems = [
    const OrderItemEntity(
      menuItemId: 'menu-item-1',
      name: 'Pizza Margherita',
      price: 10.99,
      quantity: 2,
    ),
    const OrderItemEntity(
      menuItemId: 'menu-item-2',
      name: 'Sprite',
      price: 2.50,
      quantity: 1,
    ),
  ];

  final testOrderRequest = OrderRequestEntity(
    restaurantId: 'restaurant-id',
    tableId: 'table-id',
    items: testOrderItems,
    totalAmount: 24.48,
    specialInstructions: 'No onions on the pizza',
  );

  final testOrder = OrderEntity(
    id: testOrderId,
    restaurantId: 'restaurant-id',
    tableId: 'table-id',
    status: 'pending',
    items: testOrderItems,
    totalAmount: 24.48,
    createdAt: DateTime.now(),
    specialInstructions: 'No onions on the pizza',
  );

  final testOrders = [
    OrderEntity(
      id: 'order-1',
      restaurantId: 'restaurant-id-1',
      tableId: 'table-id-1',
      status: 'completed',
      items: [testOrderItems[0]],
      totalAmount: 21.98,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    OrderEntity(
      id: 'order-2',
      restaurantId: 'restaurant-id-2',
      tableId: 'table-id-2',
      status: 'pending',
      items: [testOrderItems[1]],
      totalAmount: 2.50,
      createdAt: DateTime.now(),
    ),
  ];

  group('Use Case Tests', () {
    // Test 1: PlaceOrderUseCase success
    test('PlaceOrderUseCase should place order when repository call succeeds',
        () async {
      // Arrange
      when(mockOrderRepository.placeOrder(testOrderRequest))
          .thenAnswer((_) async => Right(testOrder));

      // Act
      final result = await placeOrderUseCase(testOrderRequest);

      // Assert
      expect(result, Right(testOrder));
      verify(mockOrderRepository.placeOrder(testOrderRequest));
      verifyNoMoreInteractions(mockOrderRepository);
    });

    // Test 2: PlaceOrderUseCase failure
    test(
        'PlaceOrderUseCase should return server failure when repository call fails',
        () async {
      // Arrange
      when(mockOrderRepository.placeOrder(testOrderRequest))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await placeOrderUseCase(testOrderRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message,
              contains('Failed to place order'));
        },
        (_) => fail('Expected Left with ServerFailure'),
      );
      verify(mockOrderRepository.placeOrder(testOrderRequest));
      verifyNoMoreInteractions(mockOrderRepository);
    });

    // Test 3: GetCustomerOrdersUseCase success
    test(
        'GetCustomerOrdersUseCase should return list of orders when repository call succeeds',
        () async {
      // Arrange
      when(mockOrderRepository.getCustomerOrders())
          .thenAnswer((_) async => Right(testOrders));

      // Act
      final result = await getCustomerOrdersUseCase();

      // Assert
      expect(result, Right(testOrders));
      verify(mockOrderRepository.getCustomerOrders());
      verifyNoMoreInteractions(mockOrderRepository);
    });

    // Test 4: GetOrderByIdUseCase success
    test(
        'GetOrderByIdUseCase should return order details when repository call succeeds',
        () async {
      // Arrange
      when(mockOrderRepository.getOrderById(testOrderId))
          .thenAnswer((_) async => Right(testOrder));

      // Act
      final result = await getOrderByIdUseCase(testOrderId);

      // Assert
      expect(result, Right(testOrder));
      verify(mockOrderRepository.getOrderById(testOrderId));
      verifyNoMoreInteractions(mockOrderRepository);
    });

    // Test 5: RequestBillUseCase success
    test('RequestBillUseCase should request bill when repository call succeeds',
        () async {
      // Arrange
      final updatedOrder = OrderEntity(
        id: testOrderId,
        restaurantId: 'restaurant-id',
        tableId: 'table-id',
        status: 'bill_requested',
        items: testOrderItems,
        totalAmount: 24.48,
        createdAt: DateTime.now(),
        specialInstructions: 'No onions on the pizza',
      );

      when(mockOrderRepository.requestBill(testOrderId))
          .thenAnswer((_) async => Right(updatedOrder));

      // Act
      final result = await requestBillUseCase(testOrderId);

      // Assert
      expect(result, Right(updatedOrder));
      verify(mockOrderRepository.requestBill(testOrderId));
      verifyNoMoreInteractions(mockOrderRepository);
    });
  });

  group('Entity Tests', () {
    // Test 6: Order Entity total items
    test('Order Entity totalItems getter should calculate correctly', () {
      // Verify the total items getter works correctly
      final orderWithItems = OrderEntity(
        id: 'test-id',
        restaurantId: 'restaurant-id',
        tableId: 'table-id',
        status: 'pending',
        items: const [
          OrderItemEntity(
            menuItemId: 'item1',
            name: 'Pizza',
            price: 10.0,
            quantity: 2,
          ),
          OrderItemEntity(
            menuItemId: 'item2',
            name: 'Salad',
            price: 5.0,
            quantity: 1,
          ),
        ],
        totalAmount: 25.0,
        createdAt: DateTime.now(),
      );

      // Total items should be 2 + 1 = 3
      expect(orderWithItems.totalItems, 3);
    });

    // Test 7: Order Entity isCompleted
    test('Order Entity isCompleted getter should work correctly', () {
      // Verify the isCompleted getter works correctly
      final pendingOrder = OrderEntity(
        id: 'test-id',
        restaurantId: 'restaurant-id',
        tableId: 'table-id',
        status: 'pending',
        items: const [],
        totalAmount: 0,
        createdAt: DateTime.now(),
      );

      final completedOrder = OrderEntity(
        id: 'test-id',
        restaurantId: 'restaurant-id',
        tableId: 'table-id',
        status: 'completed',
        items: const [],
        totalAmount: 0,
        createdAt: DateTime.now(),
      );

      expect(pendingOrder.isCompleted, false);
      expect(completedOrder.isCompleted, true);
    });

    // Test 8: Order Entity estimatePreparationTime
    test(
        'Order Entity estimatePreparationTime method should calculate correctly',
        () {
      // Verify the estimatePreparationTime method works correctly
      final orderWithItems = OrderEntity(
        id: 'test-id',
        restaurantId: 'restaurant-id',
        tableId: 'table-id',
        status: 'pending',
        items: const [
          OrderItemEntity(
            menuItemId: 'item1',
            name: 'Pizza',
            price: 10.0,
            quantity: 2,
          ),
          OrderItemEntity(
            menuItemId: 'item2',
            name: 'Salad',
            price: 5.0,
            quantity: 1,
          ),
        ],
        totalAmount: 25.0,
        createdAt: DateTime.now(),
      );

      // 2 items * 5 minutes = 10 minutes
      expect(orderWithItems.estimatePreparationTime(),
          const Duration(minutes: 10));
    });

    // Test 9: OrderItemEntity totalPrice
    test('OrderItemEntity totalPrice getter should calculate correctly', () {
      // Verify the totalPrice getter works correctly
      const orderItem = OrderItemEntity(
        menuItemId: 'item1',
        name: 'Pizza',
        price: 10.0,
        quantity: 3,
      );

      // 10.0 * 3 = 30.0
      expect(orderItem.totalPrice, 30.0);
    });

    // Test 10: RequestBillUseCase failure
    test(
        'RequestBillUseCase should return server failure when repository call fails',
        () async {
      // Arrange
      when(mockOrderRepository.requestBill(testOrderId))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await requestBillUseCase(testOrderId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message,
              contains('Failed to request bill'));
        },
        (_) => fail('Expected Left with ServerFailure'),
      );
      verify(mockOrderRepository.requestBill(testOrderId));
      verifyNoMoreInteractions(mockOrderRepository);
    });
  });
}
