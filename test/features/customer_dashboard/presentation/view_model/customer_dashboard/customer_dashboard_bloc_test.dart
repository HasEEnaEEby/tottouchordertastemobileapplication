import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tottouchordertastemobileapplication/core/auth/auth_token_manager.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/cart_item_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/menu_item_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/table_repository.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/use_case/customer_dashboard_usecases.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_event.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_state.dart';

@GenerateMocks([
  GetAllRestaurantsUseCase,
  GetRestaurantDetailsUseCase,
  GetRestaurantMenuUseCase,
  GetRestaurantTablesUseCase,
  PlaceOrderUseCase,
  AuthTokenManager,
  TableRepository,
])
import 'customer_dashboard_bloc_test.mocks.dart';

void main() {
  late CustomerDashboardBloc customerDashboardBloc;
  late MockGetAllRestaurantsUseCase mockGetAllRestaurantsUseCase;
  late MockGetRestaurantDetailsUseCase mockGetRestaurantDetailsUseCase;
  late MockGetRestaurantMenuUseCase mockGetRestaurantMenuUseCase;
  late MockGetRestaurantTablesUseCase mockGetRestaurantTablesUseCase;
  late MockPlaceOrderUseCase mockPlaceOrderUseCase;
  late MockAuthTokenManager mockAuthTokenManager;
  late MockTableRepository mockTableRepository;

  // Test data
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

  setUp(() {
    mockGetAllRestaurantsUseCase = MockGetAllRestaurantsUseCase();
    mockGetRestaurantDetailsUseCase = MockGetRestaurantDetailsUseCase();
    mockGetRestaurantMenuUseCase = MockGetRestaurantMenuUseCase();
    mockGetRestaurantTablesUseCase = MockGetRestaurantTablesUseCase();
    mockPlaceOrderUseCase = MockPlaceOrderUseCase();
    mockAuthTokenManager = MockAuthTokenManager();
    mockTableRepository = MockTableRepository();

    // Configure AuthTokenManager mock with default behavior
    when(mockAuthTokenManager.hasValidToken()).thenReturn(true);
    when(mockAuthTokenManager.getUserData()).thenReturn({
      'username': 'testuser',
      'email': 'test@example.com',
      'isEmailVerified': true,
    });
    when(mockAuthTokenManager.getToken()).thenReturn('test_token');
    when(mockAuthTokenManager.getRefreshToken())
        .thenReturn('test_refresh_token');

    customerDashboardBloc = CustomerDashboardBloc(
      getAllRestaurantsUseCase: mockGetAllRestaurantsUseCase,
      getRestaurantDetailsUseCase: mockGetRestaurantDetailsUseCase,
      getRestaurantMenuUseCase: mockGetRestaurantMenuUseCase,
      getRestaurantTablesUseCase: mockGetRestaurantTablesUseCase,
      placeOrderUseCase: mockPlaceOrderUseCase,
      tableRepository: mockTableRepository,
      tokenManager: mockAuthTokenManager,
    );
  });

  tearDown(() {
    customerDashboardBloc.close();
  });

  group('CustomerDashboardBloc', () {
    // Test 1: LoadRestaurantsEvent successfully loads restaurants
    blocTest<CustomerDashboardBloc, CustomerDashboardState>(
      'emits [CustomerDashboardLoading, RestaurantsLoaded] when LoadRestaurantsEvent is added',
      build: () {
        when(mockGetAllRestaurantsUseCase.call())
            .thenAnswer((_) async => Right(testRestaurants));
        return customerDashboardBloc;
      },
      act: (bloc) => bloc.add(LoadRestaurantsEvent()),
      expect: () => [
        isA<CustomerDashboardLoading>(),
        isA<RestaurantsLoaded>().having(
          (state) => state.restaurants,
          'restaurants',
          testRestaurants,
        ),
      ],
      verify: (_) {
        verify(mockGetAllRestaurantsUseCase.call()).called(1);
      },
    );

    // Test 2: LoadRestaurantDetailsEvent successfully loads restaurant details
    blocTest<CustomerDashboardBloc, CustomerDashboardState>(
      'emits [RestaurantDetailsLoading, RestaurantDetailsLoaded] when LoadRestaurantDetailsEvent is added',
      build: () {
        when(mockGetRestaurantDetailsUseCase.call(any))
            .thenAnswer((_) async => Right(testRestaurants.first));
        when(mockGetRestaurantMenuUseCase.call(any))
            .thenAnswer((_) async => Right(testMenuItems));
        when(mockGetRestaurantTablesUseCase.call(any))
            .thenAnswer((_) async => Right(testTables));
        return customerDashboardBloc;
      },
      act: (bloc) => bloc
          .add(const LoadRestaurantDetailsEvent(restaurantId: 'restaurant1')),
      expect: () => [
        isA<RestaurantDetailsLoading>(),
        isA<RestaurantDetailsLoaded>()
            .having((state) => state.restaurant, 'restaurant',
                testRestaurants.first)
            .having((state) => state.menuItems, 'menuItems', testMenuItems)
            .having((state) => state.tables, 'tables', testTables)
            .having((state) => state.cartItems, 'cartItems', []),
      ],
      verify: (_) {
        verify(mockGetRestaurantDetailsUseCase.call('restaurant1')).called(1);
        verify(mockGetRestaurantMenuUseCase.call('restaurant1')).called(1);
        verify(mockGetRestaurantTablesUseCase.call('restaurant1')).called(1);
      },
    );

    // Test 3: Add to cart functionality
    blocTest<CustomerDashboardBloc, CustomerDashboardState>(
      'correctly adds item to cart',
      seed: () => RestaurantDetailsLoaded(
        restaurant: testRestaurants.first,
        menuItems: testMenuItems,
        tables: testTables,
        cartItems: const [],
      ),
      build: () => customerDashboardBloc,
      act: (bloc) => bloc.add(AddToCartEvent(menuItem: testMenuItems.first)),
      expect: () => [
        isA<RestaurantDetailsLoaded>().having(
          (state) => state.cartItems,
          'cartItems',
          [
            isA<CartItemEntity>()
                .having((item) => item.id, 'id', testMenuItems.first.id)
                .having((item) => item.quantity, 'quantity', 1)
          ],
        ),
      ],
    );

    // Test 4: Place order functionality
    blocTest<CustomerDashboardBloc, CustomerDashboardState>(
      'places an order successfully',
      seed: () => RestaurantDetailsLoaded(
        restaurant: testRestaurants.first,
        menuItems: testMenuItems,
        tables: testTables,
        selectedTable: testTables.first,
        selectedTableId: testTables.first.id,
        cartItems: [
          CartItemEntity(
            id: testMenuItems.first.id,
            name: testMenuItems.first.name,
            price: testMenuItems.first.price,
            image: testMenuItems.first.image,
            isVegetarian: testMenuItems.first.isVegetarian,
            quantity: 2,
            specialInstructions: 'No spice',
          ),
        ],
      ),
      build: () {
        // Create OrderResponseEntity correctly based on your current implementation
        final testOrderItems = [
          OrderItemEntity(
            menuItemId: testMenuItems.first.id,
            name: testMenuItems.first.name,
            price: testMenuItems.first.price,
            quantity: 2,
            specialInstructions: 'No spice',
          )
        ];

        final orderResponse = OrderEntity(
          id: 'order1',
          customerId: 'customer1',
          restaurantId: 'restaurant1',
          tableId: 'table1',
          status: 'placed',
          totalAmount: 21.98,
          createdAt: DateTime.now(),
          items: testOrderItems,
        );

        when(mockPlaceOrderUseCase.call(any))
            .thenAnswer((_) async => Right(orderResponse));

        return customerDashboardBloc;
      },
      act: (bloc) => bloc.add(const PlaceOrderEvent(
        restaurantId: 'restaurant1',
        tableId: 'table1',
      )),
      expect: () => [
        isA<OrderPlacedSuccessfully>()
            .having((state) => state.orderId, 'orderId', 'order1')
            .having(
                (state) => state.restaurantName, 'restaurantId', 'restaurant1'),
      ],
      verify: (_) {
        verify(mockPlaceOrderUseCase.call(any)).called(1);
      },
    );

    // Test 5: Auth error handling
    blocTest<CustomerDashboardBloc, CustomerDashboardState>(
      'emits CustomerDashboardAuthError when token is invalid',
      build: () {
        when(mockAuthTokenManager.hasValidToken()).thenReturn(false);
        return customerDashboardBloc;
      },
      act: (bloc) => bloc
          .add(const LoadRestaurantDetailsEvent(restaurantId: 'restaurant1')),
      expect: () => [
        isA<CustomerDashboardAuthError>().having(
          (state) => state.message,
          'message',
          'Session expired. Please log in again.',
        ),
      ],
      verify: (_) {
        // Verify that use cases were not called due to invalid token
        verifyNever(mockGetRestaurantDetailsUseCase.call(any));
      },
    );
  });
}
