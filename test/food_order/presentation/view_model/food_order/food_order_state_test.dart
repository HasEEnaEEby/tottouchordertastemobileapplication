import 'package:flutter_test/flutter_test.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/bill_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_state.dart';

void main() {
  group('FoodOrderState', () {
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

    group('FoodOrderInitial', () {
      test('supports value equality', () {
        expect(
          FoodOrderInitial(),
          equals(FoodOrderInitial()),
        );
      });

      test('props is empty list', () {
        expect(
          FoodOrderInitial().props,
          equals([]),
        );
      });
    });

    group('FoodOrderLoading', () {
      test('supports value equality', () {
        expect(
          FoodOrderLoading(),
          equals(FoodOrderLoading()),
        );
      });

      test('props is empty list', () {
        expect(
          FoodOrderLoading().props,
          equals([]),
        );
      });
    });

    group('FoodOrderError', () {
      test('supports value equality', () {
        expect(
          const FoodOrderError('Error message'),
          equals(const FoodOrderError('Error message')),
        );
      });

      test('props contains all properties', () {
        expect(
          const FoodOrderError('Error message').props,
          equals(['Error message']),
        );
      });

      test('different message creates different object', () {
        expect(
          const FoodOrderError('Error message'),
          isNot(equals(const FoodOrderError('Another error'))),
        );
      });
    });

    group('FoodOrdersLoaded', () {
      test('supports value equality', () {
        // Create two separate but equal lists
        final orders1 = [testFoodOrder];
        final orders2 = [testFoodOrder];

        expect(
          FoodOrdersLoaded(orders: orders1),
          equals(FoodOrdersLoaded(orders: orders2)),
        );
      });

      test('props contains all properties', () {
        final orders = [testFoodOrder];

        expect(
          FoodOrdersLoaded(orders: orders).props,
          equals([orders, null]),
        );
      });

      test('different orders list creates different object', () {
        final orders1 = [testFoodOrder];
        final orders2 = [
          testFoodOrder,
          FoodOrderEntity(
            id: 'order456',
            restaurantId: 'rest456',
            tableId: 'table789',
            status: 'completed',
            items: testOrderItems,
            totalAmount: 25.98,
            createdAt: DateTime.now(),
            customerId: 'user123',
            restaurantName: 'Other Restaurant',
          ),
        ];

        expect(
          FoodOrdersLoaded(orders: orders1),
          isNot(equals(FoodOrdersLoaded(orders: orders2))),
        );
      });

      test('with selected order works correctly', () {
        final orders = [testFoodOrder];

        expect(
          FoodOrdersLoaded(orders: orders, selectedOrder: testFoodOrder).props,
          equals([orders, testFoodOrder]),
        );
      });
    });

    group('OrderDetailsLoaded', () {
      test('supports value equality', () {
        expect(
          OrderDetailsLoaded(order: testFoodOrder),
          equals(OrderDetailsLoaded(order: testFoodOrder)),
        );
      });

      test('props contains all properties', () {
        expect(
          OrderDetailsLoaded(order: testFoodOrder).props,
          equals([testFoodOrder]),
        );
      });

      test('different order creates different object', () {
        final anotherOrder = FoodOrderEntity(
          id: 'order456',
          restaurantId: 'rest456',
          tableId: 'table789',
          status: 'completed',
          items: testOrderItems,
          totalAmount: 25.98,
          createdAt: DateTime.now(),
          customerId: 'user123',
          restaurantName: 'Other Restaurant',
        );

        expect(
          OrderDetailsLoaded(order: testFoodOrder),
          isNot(equals(OrderDetailsLoaded(order: anotherOrder))),
        );
      });
    });

    group('OrderCancelled', () {
      test('supports value equality', () {
        expect(
          const OrderCancelled(
            orderId: 'order123',
            message: 'Order cancelled successfully',
          ),
          equals(const OrderCancelled(
            orderId: 'order123',
            message: 'Order cancelled successfully',
          )),
        );
      });

      test('props contains all properties', () {
        expect(
          const OrderCancelled(
            orderId: 'order123',
            message: 'Order cancelled successfully',
          ).props,
          equals(['order123', 'Order cancelled successfully']),
        );
      });

      test('different orderId creates different object', () {
        expect(
          const OrderCancelled(
            orderId: 'order123',
            message: 'Order cancelled successfully',
          ),
          isNot(equals(const OrderCancelled(
            orderId: 'order456',
            message: 'Order cancelled successfully',
          ))),
        );
      });

      test('different message creates different object', () {
        expect(
          const OrderCancelled(
            orderId: 'order123',
            message: 'Order cancelled successfully',
          ),
          isNot(equals(const OrderCancelled(
            orderId: 'order123',
            message: 'Cancellation complete',
          ))),
        );
      });
    });

    group('BillLoading', () {
      test('supports value equality', () {
        expect(
          const BillLoading(orderId: 'order123'),
          equals(const BillLoading(orderId: 'order123')),
        );
      });

      test('props contains all properties', () {
        expect(
          const BillLoading(orderId: 'order123').props,
          equals(['order123']),
        );
      });

      test('different orderId creates different object', () {
        expect(
          const BillLoading(orderId: 'order123'),
          isNot(equals(const BillLoading(orderId: 'order456'))),
        );
      });
    });

    group('BillLoaded', () {
      test('supports value equality', () {
        expect(
          BillLoaded(orderId: 'order123', bill: testBill),
          equals(BillLoaded(orderId: 'order123', bill: testBill)),
        );
      });

      test('props contains all properties', () {
        expect(
          BillLoaded(orderId: 'order123', bill: testBill).props,
          equals(['order123', testBill]),
        );
      });

      test('different orderId creates different object', () {
        expect(
          BillLoaded(orderId: 'order123', bill: testBill),
          isNot(equals(BillLoaded(orderId: 'order456', bill: testBill))),
        );
      });

      test('different bill creates different object', () {
        final anotherBill = BillEntity(
          id: 'bill456',
          billNumber: 'B1002',
          orderId: 'order123',
          restaurantId: 'rest456',
          restaurantName: 'Burger Palace',
          tableId: 'table789',
          subtotal: 45.99,
          tax: 2.30,
          serviceCharge: 4.60,
          totalAmount: 52.89,
          isPaid: true,
          generatedAt: DateTime.now(),
          taxPercentage: 5.0,
          serviceChargePercentage: 10.0,
          items: testOrderItems,
        );

        expect(
          BillLoaded(orderId: 'order123', bill: testBill),
          isNot(equals(BillLoaded(orderId: 'order123', bill: anotherBill))),
        );
      });
    });

    group('BillError', () {
      test('supports value equality', () {
        expect(
          const BillError(
            orderId: 'order123',
            message: 'Failed to load bill',
          ),
          equals(const BillError(
            orderId: 'order123',
            message: 'Failed to load bill',
          )),
        );
      });

      test('props contains all properties', () {
        expect(
          const BillError(
            orderId: 'order123',
            message: 'Failed to load bill',
          ).props,
          equals(['order123', 'Failed to load bill']),
        );
      });

      test('different orderId creates different object', () {
        expect(
          const BillError(
            orderId: 'order123',
            message: 'Failed to load bill',
          ),
          isNot(equals(const BillError(
            orderId: 'order456',
            message: 'Failed to load bill',
          ))),
        );
      });

      test('different message creates different object', () {
        expect(
          const BillError(
            orderId: 'order123',
            message: 'Failed to load bill',
          ),
          isNot(equals(const BillError(
            orderId: 'order123',
            message: 'Server error',
          ))),
        );
      });
    });

    group('OrderRated', () {
      test('supports value equality', () {
        expect(
          const OrderRated(
            orderId: 'order123',
            rating: 5,
            feedback: 'Great service',
          ),
          equals(const OrderRated(
            orderId: 'order123',
            rating: 5,
            feedback: 'Great service',
          )),
        );
      });

      test('props contains all properties', () {
        expect(
          const OrderRated(
            orderId: 'order123',
            rating: 5,
            feedback: 'Great service',
          ).props,
          equals(['order123', 5, 'Great service']),
        );
      });

      test('optional feedback can be null', () {
        expect(
          const OrderRated(
            orderId: 'order123',
            rating: 5,
          ).props,
          equals(['order123', 5, null]),
        );
      });

      test('different rating creates different object', () {
        expect(
          const OrderRated(
            orderId: 'order123',
            rating: 5,
          ),
          isNot(equals(const OrderRated(
            orderId: 'order123',
            rating: 4,
          ))),
        );
      });
    });

    group('PaymentUpdated', () {
      test('supports value equality', () {
        expect(
          const PaymentUpdated(
            orderId: 'order123',
            paymentStatus: 'paid',
          ),
          equals(const PaymentUpdated(
            orderId: 'order123',
            paymentStatus: 'paid',
          )),
        );
      });

      test('props contains all properties', () {
        expect(
          const PaymentUpdated(
            orderId: 'order123',
            paymentStatus: 'paid',
          ).props,
          equals(['order123', 'paid']),
        );
      });

      test('different status creates different object', () {
        expect(
          const PaymentUpdated(
            orderId: 'order123',
            paymentStatus: 'paid',
          ),
          isNot(equals(const PaymentUpdated(
            orderId: 'order123',
            paymentStatus: 'pending',
          ))),
        );
      });
    });
  });
}
