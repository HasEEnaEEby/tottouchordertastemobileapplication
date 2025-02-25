import 'package:equatable/equatable.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';

class OrderRequestEntity extends Equatable {
  final String restaurantId;
  final String tableId;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final String? specialInstructions;

  const OrderRequestEntity({
    required this.restaurantId,
    required this.tableId,
    required this.items,
    required this.totalAmount,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [
        restaurantId,
        tableId,
        items,
        totalAmount,
        specialInstructions,
      ];
}
