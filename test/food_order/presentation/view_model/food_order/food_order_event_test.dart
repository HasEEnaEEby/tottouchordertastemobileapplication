import 'package:flutter_test/flutter_test.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_event.dart';

void main() {
  group('FoodOrderEvent', () {
    // Sample test data
    final testOrderItems = [
      const OrderItemEntity(
        menuItemId: 'item1',
        name: 'Chicken Burger',
        price: 12.99,
        quantity: 2,
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
      restaurantName: 'Burger Palace',
    );

    // Test 1: GetOrderDetailsEvent - Testing a simple event with one property
    group('GetOrderDetailsEvent', () {
      test('equality, props, and different values', () {
        // Equality
        expect(
          const GetOrderDetailsEvent('order123'),
          equals(const GetOrderDetailsEvent('order123')),
        );

        // Props
        expect(
          const GetOrderDetailsEvent('order123').props,
          equals(['order123']),
        );

        // Different values
        expect(
          const GetOrderDetailsEvent('order123'),
          isNot(equals(const GetOrderDetailsEvent('order456'))),
        );
      });
    });

    // Test 2: CancelOrderEvent - Testing an event with optional parameters
    group('CancelOrderEvent', () {
      test('equality, props with all properties, and optional parameters', () {
        // Equality
        expect(
          const CancelOrderEvent(orderId: 'order123', reason: 'Changed mind'),
          equals(const CancelOrderEvent(
              orderId: 'order123', reason: 'Changed mind')),
        );

        // Props with all properties
        expect(
          const CancelOrderEvent(orderId: 'order123', reason: 'Changed mind')
              .props,
          equals(['order123', 'Changed mind']),
        );

        // Optional reason
        expect(
          const CancelOrderEvent(orderId: 'order123').props,
          equals(['order123', null]),
        );

        // Different values
        expect(
          const CancelOrderEvent(orderId: 'order123', reason: 'Changed mind'),
          isNot(equals(const CancelOrderEvent(
              orderId: 'order123', reason: 'Too expensive'))),
        );
      });
    });

    // Test 3: PlaceOrderEvent - Testing a complex event with multiple properties and defaults
    group('PlaceOrderEvent', () {
      test('equality, props with all properties, and default values', () {
        // Equality
        expect(
          PlaceOrderEvent(
            restaurantId: 'rest123',
            tableId: 'table456',
            items: testOrderItems,
            totalAmount: 25.98,
            specialInstructions: 'No onions',
            customerName: 'John',
            customerEmail: 'john@example.com',
          ),
          equals(PlaceOrderEvent(
            restaurantId: 'rest123',
            tableId: 'table456',
            items: testOrderItems,
            totalAmount: 25.98,
            specialInstructions: 'No onions',
            customerName: 'John',
            customerEmail: 'john@example.com',
          )),
        );

        // Props with all properties
        final event = PlaceOrderEvent(
          restaurantId: 'rest123',
          tableId: 'table456',
          items: testOrderItems,
          totalAmount: 25.98,
          specialInstructions: 'No onions',
          customerName: 'John',
          customerEmail: 'john@example.com',
        );

        expect(
          event.props,
          equals([
            'rest123',
            'table456',
            testOrderItems,
            25.98,
            'No onions',
            'John',
            'john@example.com',
          ]),
        );

        // Default values
        const defaultEvent = PlaceOrderEvent(
          restaurantId: 'rest123',
          tableId: 'table456',
        );

        expect(defaultEvent.items, equals(const []));
        expect(defaultEvent.totalAmount, equals(0.0));
        expect(defaultEvent.specialInstructions, isNull);
        expect(defaultEvent.customerName, isNull);
        expect(defaultEvent.customerEmail, isNull);
      });
    });

    // Test 4: RateOrderEvent - Testing an event with multiple parameters including numeric values
    group('RateOrderEvent', () {
      test('equality, props, and different rating values', () {
        // Equality
        expect(
          const RateOrderEvent(
              orderId: 'order123', rating: 5, feedback: 'Great service'),
          equals(const RateOrderEvent(
              orderId: 'order123', rating: 5, feedback: 'Great service')),
        );

        // Props
        expect(
          const RateOrderEvent(
                  orderId: 'order123', rating: 5, feedback: 'Great service')
              .props,
          equals(['order123', 5, 'Great service']),
        );

        // Optional feedback
        expect(
          const RateOrderEvent(orderId: 'order123', rating: 5).props,
          equals(['order123', 5, null]),
        );

        // Different rating
        expect(
          const RateOrderEvent(orderId: 'order123', rating: 5),
          isNot(equals(const RateOrderEvent(orderId: 'order123', rating: 4))),
        );
      });
    });

    // Test 5: FetchUserOrdersEvent - Testing a parameterless event
    group('FetchUserOrdersEvent', () {
      test('equality and empty props list', () {
        // Equality
        expect(
          const FetchUserOrdersEvent(),
          equals(const FetchUserOrdersEvent()),
        );

        // Empty props
        expect(
          const FetchUserOrdersEvent().props,
          equals([]),
        );
      });
    });
  });
}
