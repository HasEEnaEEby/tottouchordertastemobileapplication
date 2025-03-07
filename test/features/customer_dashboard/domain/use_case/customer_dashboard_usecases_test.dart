import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/menu_item_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/repository.mocks.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/use_case/customer_dashboard_usecases.dart';

void main() {
  const testRestaurantId = 'restaurant1';

  final testRestaurants = [
    const RestaurantEntity(
      id: 'restaurant1',
      username: 'testrestaurant1',
      restaurantName: 'Test Restaurant 1',
      location: 'Test Location',
      contactNumber: '1234567890',
      quote: 'Test Quote',
      status: 'active',
      image: 'test_image.jpg',
    ),
    const RestaurantEntity(
      id: 'restaurant2',
      username: 'testrestaurant2',
      restaurantName: 'Test Restaurant 2',
      location: 'Another Location',
      contactNumber: '9876543210',
      quote: 'Another Quote',
      status: 'active',
      image: 'another_image.jpg',
    ),
  ];

  final testMenuItems = [
    const MenuItemEntity(
      id: 'item1',
      name: 'Test Item 1',
      description: 'Test Description',
      price: 10.99,
      category: 'Starters',
      image: 'item1.jpg',
      isVegetarian: true,
      isAvailable: true,
      restaurantId: 'restaurant1',
      preparationTime: 15,
    ),
    const MenuItemEntity(
      id: 'item2',
      name: 'Test Item 2',
      description: 'Another Test Description',
      price: 15.99,
      category: 'Main Course',
      image: 'item2.jpg',
      isVegetarian: false,
      isAvailable: true,
      restaurantId: 'restaurant1',
      preparationTime: 25,
    ),
  ];

  final testTables = [
    const TableEntity(
      id: 'table1',
      number: 1,
      capacity: 4,
      restaurantId: 'restaurant1',
      status: 'available',
      position: {'x': 10, 'y': 20},
    ),
    const TableEntity(
      id: 'table2',
      number: 2,
      capacity: 2,
      restaurantId: 'restaurant1',
      status: 'occupied',
      position: {'x': 30, 'y': 40},
    ),
  ];

  final testOrderItems = [
    const OrderItemEntity(
      menuItemId: 'item1',
      name: 'Test Item 1',
      price: 10.99,
      quantity: 2,
      specialInstructions: 'No spice',
    )
  ];

  final testOrderRequest = OrderRequestEntity(
    restaurantId: 'restaurant1',
    tableId: 'table1',
    items: testOrderItems,
    totalAmount: 21.98,
  );

  final testOrder = OrderEntity(
    id: 'order1',
    customerId: 'customer1',
    restaurantId: 'restaurant1',
    tableId: 'table1',
    status: 'placed',
    totalAmount: 21.98,
    createdAt: DateTime.now(),
    items: testOrderItems,
  );

  group('GetAllRestaurantsUseCase', () {
    late MockCustomerDashboardRepository repository;
    late GetAllRestaurantsUseCase useCase;

    setUp(() {
      repository = MockCustomerDashboardRepository();
      useCase = GetAllRestaurantsUseCase(repository);
    });

    test(
        'Should call [CustomerDashboardRepository.getAllRestaurants] and return list of restaurants',
        () async {
      // Arrange
      when(() => repository.getAllRestaurants())
          .thenAnswer((_) async => Right(testRestaurants));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Right(testRestaurants));
      verify(() => repository.getAllRestaurants()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('Should return a ServerFailure when repository call fails', () async {
      // Arrange
      const failure = ServerFailure('Failed to fetch restaurants');
      when(() => repository.getAllRestaurants())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left(failure));
      verify(() => repository.getAllRestaurants()).called(1);
      verifyNoMoreInteractions(repository);
    });

    tearDown(() {
      reset(repository);
    });
  });

  group('GetRestaurantDetailsUseCase', () {
    late MockCustomerDashboardRepository repository;
    late GetRestaurantDetailsUseCase useCase;

    setUp(() {
      repository = MockCustomerDashboardRepository();
      useCase = GetRestaurantDetailsUseCase(repository);
    });

    test(
        'Should call [CustomerDashboardRepository.getRestaurantDetails] with correct restaurant ID',
        () async {
      // Arrange
      when(() => repository.getRestaurantDetails(testRestaurantId))
          .thenAnswer((_) async => Right(testRestaurants.first));

      // Act
      final result = await useCase(testRestaurantId);

      // Assert
      expect(result, Right(testRestaurants.first));
      verify(() => repository.getRestaurantDetails(testRestaurantId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('Should return a ServerFailure when repository call fails', () async {
      // Arrange
      const failure = ServerFailure('Failed to fetch restaurant details');
      when(() => repository.getRestaurantDetails(testRestaurantId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testRestaurantId);

      // Assert
      expect(result, const Left(failure));
      verify(() => repository.getRestaurantDetails(testRestaurantId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('Should handle exceptions and return a ServerFailure', () async {
      // Arrange
      when(() => repository.getRestaurantDetails(testRestaurantId))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase(testRestaurantId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left with ServerFailure'),
      );
      verify(() => repository.getRestaurantDetails(testRestaurantId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test(
        'Should return an AuthFailure when exception contains "Session expired"',
        () async {
      // Arrange
      when(() => repository.getRestaurantDetails(testRestaurantId))
          .thenThrow(Exception('Session expired'));

      // Act
      final result = await useCase(testRestaurantId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left with AuthFailure'),
      );
      verify(() => repository.getRestaurantDetails(testRestaurantId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    tearDown(() {
      reset(repository);
    });
  });

  group('GetRestaurantMenuUseCase', () {
    late MockCustomerDashboardRepository repository;
    late GetRestaurantMenuUseCase useCase;

    setUp(() {
      repository = MockCustomerDashboardRepository();
      useCase = GetRestaurantMenuUseCase(repository);
    });

    test(
        'Should call [CustomerDashboardRepository.getRestaurantMenu] with correct restaurant ID',
        () async {
      // Arrange
      when(() => repository.getRestaurantMenu(testRestaurantId))
          .thenAnswer((_) async => Right(testMenuItems));

      // Act
      final result = await useCase(testRestaurantId);

      // Assert
      expect(result, Right(testMenuItems));
      verify(() => repository.getRestaurantMenu(testRestaurantId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('Should return a ServerFailure when repository call fails', () async {
      // Arrange
      const failure = ServerFailure('Failed to fetch restaurant menu');
      when(() => repository.getRestaurantMenu(testRestaurantId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testRestaurantId);

      // Assert
      expect(result, const Left(failure));
      verify(() => repository.getRestaurantMenu(testRestaurantId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('Should handle exceptions and return a ServerFailure', () async {
      // Arrange
      when(() => repository.getRestaurantMenu(testRestaurantId))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase(testRestaurantId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left with ServerFailure'),
      );
      verify(() => repository.getRestaurantMenu(testRestaurantId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test(
        'Should return an AuthFailure when exception contains "Session expired"',
        () async {
      // Arrange
      when(() => repository.getRestaurantMenu(testRestaurantId))
          .thenThrow(Exception('Session expired'));

      // Act
      final result = await useCase(testRestaurantId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left with AuthFailure'),
      );
      verify(() => repository.getRestaurantMenu(testRestaurantId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    tearDown(() {
      reset(repository);
    });
  });

  group('GetRestaurantTablesUseCase', () {
    late MockCustomerDashboardRepository repository;
    late GetRestaurantTablesUseCase useCase;

    setUp(() {
      repository = MockCustomerDashboardRepository();
      useCase = GetRestaurantTablesUseCase(repository);
    });

    test(
        'Should call [CustomerDashboardRepository.getRestaurantTables] with correct restaurant ID',
        () async {
      // Arrange
      when(() => repository.getRestaurantTables(testRestaurantId))
          .thenAnswer((_) async => Right(testTables));

      // Act
      final result = await useCase(testRestaurantId);

      // Assert
      expect(result, Right(testTables));
      verify(() => repository.getRestaurantTables(testRestaurantId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('Should return a ServerFailure when repository call fails', () async {
      // Arrange
      const failure = ServerFailure('Failed to fetch restaurant tables');
      when(() => repository.getRestaurantTables(testRestaurantId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testRestaurantId);

      // Assert
      expect(result, const Left(failure));
      verify(() => repository.getRestaurantTables(testRestaurantId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('Should handle exceptions and return a ServerFailure', () async {
      // Arrange
      when(() => repository.getRestaurantTables(testRestaurantId))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase(testRestaurantId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left with ServerFailure'),
      );
      verify(() => repository.getRestaurantTables(testRestaurantId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test(
        'Should return an AuthFailure when exception contains "Session expired"',
        () async {
      // Arrange
      when(() => repository.getRestaurantTables(testRestaurantId))
          .thenThrow(Exception('Session expired'));

      // Act
      final result = await useCase(testRestaurantId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left with AuthFailure'),
      );
      verify(() => repository.getRestaurantTables(testRestaurantId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    tearDown(() {
      reset(repository);
    });
  });

  group('PlaceOrderUseCase', () {
    late MockOrderRepository repository;
    late PlaceOrderUseCase useCase;

    setUp(() {
      repository = MockOrderRepository();
      useCase = PlaceOrderUseCase(repository);
    });

    test('Should call [OrderRepository.placeOrder] with correct order request',
        () async {
      // Arrange
      when(() => repository.placeOrder(testOrderRequest))
          .thenAnswer((_) async => Right(testOrder));

      // Act
      final result = await useCase(testOrderRequest);

      // Assert
      expect(result, Right(testOrder));
      verify(() => repository.placeOrder(testOrderRequest)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('Should return a ServerFailure when repository call fails', () async {
      // Arrange
      const failure = ServerFailure('Failed to place order');
      when(() => repository.placeOrder(testOrderRequest))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testOrderRequest);

      // Assert
      expect(result, const Left(failure));
      verify(() => repository.placeOrder(testOrderRequest)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('Should handle exceptions and return a ServerFailure', () async {
      // Arrange
      when(() => repository.placeOrder(testOrderRequest))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase(testOrderRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left with ServerFailure'),
      );
      verify(() => repository.placeOrder(testOrderRequest)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test(
        'Should return an AuthFailure when exception contains "Session expired"',
        () async {
      // Arrange
      when(() => repository.placeOrder(testOrderRequest))
          .thenThrow(Exception('Session expired'));

      // Act
      final result = await useCase(testOrderRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected Left with AuthFailure'),
      );
      verify(() => repository.placeOrder(testOrderRequest)).called(1);
      verifyNoMoreInteractions(repository);
    });

    tearDown(() {
      reset(repository);
    });
  });
}
