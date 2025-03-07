import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/menu_item_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view/restaurant_dashboard_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_event.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_state.dart';

// Generate mock class
@GenerateNiceMocks([MockSpec<CustomerDashboardBloc>()])
import 'restaurant_dashboard_view_test.mocks.dart';

void main() {
  late MockCustomerDashboardBloc mockBloc;
  late RestaurantEntity testRestaurant;
  late List<MenuItemEntity> testMenuItems;
  late List<TableEntity> testTables;

  setUp(() {
    mockBloc = MockCustomerDashboardBloc();

    // Create test restaurant
    testRestaurant = const RestaurantEntity(
      id: 'test-restaurant-id',
      username: 'testuser',
      restaurantName: 'Test Restaurant',
      location: 'Test Location',
      contactNumber: '1234567890',
      quote: 'Best test restaurant in town',
      status: 'active',
      image: 'https://example.com/test-image.jpg',
      hours: '9:00 AM - 10:00 PM',
    );

    // Create test menu items
    testMenuItems = [
      const MenuItemEntity(
        id: 'menu-item-1',
        name: 'Test Item 1',
        description: 'A delicious test item',
        price: 199.99,
        category: 'Test Category',
        image: 'https://example.com/test-item-1.jpg',
        isAvailable: true,
        restaurantId: 'test-restaurant-id',
        preparationTime: 15,
        isVegetarian: true,
        spicyLevel: 'Medium',
      ),
      const MenuItemEntity(
        id: 'menu-item-2',
        name: 'Test Item 2',
        description: 'Another delicious test item',
        price: 299.99,
        category: 'Test Category',
        image: 'https://example.com/test-item-2.jpg',
        isAvailable: true,
        restaurantId: 'test-restaurant-id',
        preparationTime: 20,
        isVegetarian: false,
        spicyLevel: 'Hot',
      ),
    ];

    // Create test tables
    testTables = [
      const TableEntity(
        id: 'table-1',
        number: 1,
        capacity: 4,
        restaurantId: 'test-restaurant-id',
        status: 'available',
        position: {'x': 0, 'y': 0},
      ),
      const TableEntity(
        id: 'table-2',
        number: 2,
        capacity: 2,
        restaurantId: 'test-restaurant-id',
        status: 'available',
        position: {'x': 1, 'y': 0},
      ),
    ];
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CustomerDashboardBloc>.value(
        value: mockBloc,
        child: RestaurantDashboardView(restaurant: testRestaurant),
      ),
    );
  }

  group('RestaurantDashboardView', () {
    testWidgets('should display loading state initially',
        (WidgetTester tester) async {
      // Arrange
      when(mockBloc.state).thenReturn(RestaurantDetailsLoading());
      when(mockBloc.isClosed).thenReturn(false);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading restaurant details...'), findsOneWidget);

      // Verify the bloc event was dispatched
      verify(mockBloc
              .add(LoadRestaurantDetailsEvent(restaurantId: testRestaurant.id)))
          .called(1);
    });

    testWidgets('should display error state', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load restaurant details';
      when(mockBloc.state)
          .thenReturn(const RestaurantDetailsError(message: errorMessage));
      when(mockBloc.isClosed).thenReturn(false);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Test retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(mockBloc
              .add(LoadRestaurantDetailsEvent(restaurantId: testRestaurant.id)))
          .called(2);
    });

    testWidgets('should display restaurant details when loaded',
        (WidgetTester tester) async {
      // Arrange
      when(mockBloc.state).thenReturn(RestaurantDetailsLoaded(
        restaurant: testRestaurant,
        menuItems: testMenuItems,
        tables: testTables,
        cartItems: const [],
      ));
      when(mockBloc.isClosed).thenReturn(false);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Wait for animations

      // Assert
      expect(find.text(testRestaurant.restaurantName),
          findsWidgets); // May appear multiple times
      expect(find.text(testRestaurant.location), findsOneWidget);
      expect(find.text(testRestaurant.quote), findsOneWidget);
      expect(find.text(testRestaurant.contactNumber), findsOneWidget);
      expect(find.text(testRestaurant.hours!), findsOneWidget);

      // Menu section
      expect(find.text('Menu'), findsOneWidget);
      expect(find.text('${testMenuItems.length} items'), findsOneWidget);

      // Menu items
      for (final menuItem in testMenuItems) {
        expect(find.text(menuItem.name), findsOneWidget);
        expect(find.text('₹${menuItem.price}'), findsOneWidget);
      }
    });

    testWidgets('should dispatch PreserveRestaurantsEvent when popping',
        (WidgetTester tester) async {
      // Arrange
      when(mockBloc.state).thenReturn(RestaurantDetailsLoaded(
        restaurant: testRestaurant,
        menuItems: testMenuItems,
        tables: testTables,
        cartItems: const [],
      ));
      when(mockBloc.isClosed).thenReturn(false);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap back button
      await tester.tap(find.byTooltip('Back to restaurants'));
      await tester.pumpAndSettle();

      // Verify the event is dispatched
      verify(mockBloc.add(PreserveRestaurantsEvent())).called(1);
    });

    testWidgets('should handle favorites button tap',
        (WidgetTester tester) async {
      // Arrange
      when(mockBloc.state).thenReturn(RestaurantDetailsLoaded(
        restaurant: testRestaurant,
        menuItems: testMenuItems,
        tables: testTables,
        cartItems: const [],
      ));
      when(mockBloc.isClosed).thenReturn(false);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Tap the favorites button
      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      // Assert - check if snackbar appears
      expect(find.text('Added to favorites'), findsOneWidget);
    });

    testWidgets('should handle share button tap', (WidgetTester tester) async {
      // Arrange
      when(mockBloc.state).thenReturn(RestaurantDetailsLoaded(
        restaurant: testRestaurant,
        menuItems: testMenuItems,
        tables: testTables,
        cartItems: const [],
      ));
      when(mockBloc.isClosed).thenReturn(false);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Tap the share button
      await tester.tap(find.byIcon(Icons.share_rounded));
      await tester.pumpAndSettle();

      // Assert - check if snackbar appears
      expect(find.text('Sharing ${testRestaurant.restaurantName}'),
          findsOneWidget);
    });

    testWidgets('should display "Not Available" for unavailable menu items',
        (WidgetTester tester) async {
      // Create a list with an unavailable item
      final menuItemsWithUnavailable = [
        testMenuItems[0],
        testMenuItems[0].copyWith(
          id: 'unavailable-item',
          name: 'Unavailable Item',
          isAvailable: false,
        ),
      ];

      // Arrange
      when(mockBloc.state).thenReturn(RestaurantDetailsLoaded(
        restaurant: testRestaurant,
        menuItems: menuItemsWithUnavailable,
        tables: testTables,
        cartItems: const [],
      ));
      when(mockBloc.isClosed).thenReturn(false);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('Not Available'), findsOneWidget);

      // Tap the unavailable item
      await tester.tap(find.text('Unavailable Item'));
      await tester.pumpAndSettle();

      expect(find.text('Not Available'), findsWidgets);
      expect(find.text('Add to Cart'), findsNothing);
    });
  });
}
