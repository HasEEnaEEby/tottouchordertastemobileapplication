import 'package:equatable/equatable.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_item_entity.dart';

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

  // Optional: Add toJson method if needed for API calls
  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'tableId': tableId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'specialInstructions': specialInstructions,
    };
  }

  // Optional: Add fromJson method if needed
  factory OrderRequestEntity.fromJson(Map<String, dynamic> json) {
    return OrderRequestEntity(
      restaurantId: json['restaurantId'] ?? '',
      tableId: json['tableId'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => OrderItemEntity.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      specialInstructions: json['specialInstructions'],
    );
  }
}
