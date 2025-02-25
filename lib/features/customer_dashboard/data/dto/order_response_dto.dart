// lib/features/customer_dashboard/data/dto/order_response_dto.dart

import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';

class OrderResponseDto {
  final String id;
  final String restaurantId;
  final String tableId;
  final String status;
  final List<OrderItemDto> items;
  final double totalAmount;
  final String createdAt;
  final String? completedAt;
  final String? specialInstructions;
  final String? customerId;

  OrderResponseDto({
    required this.id,
    required this.restaurantId,
    required this.tableId,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    this.completedAt,
    this.specialInstructions,
    this.customerId,
  });

  factory OrderResponseDto.fromJson(Map<String, dynamic> json) {
    return OrderResponseDto(
      id: json['_id'] ?? '',
      restaurantId: json['restaurant'] ?? '',
      tableId: json['table'] ?? '',
      status: json['status'] ?? 'pending',
      items: json['items'] != null
          ? List<OrderItemDto>.from((json['items'] as List)
              .map((item) => OrderItemDto.fromJson(item)))
          : [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      completedAt: json['completedAt'],
      specialInstructions: json['specialInstructions'],
      customerId: json['customer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurant': restaurantId,
      'table': tableId,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'specialInstructions': specialInstructions,
      'customer': customerId,
    };
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      restaurantId: restaurantId,
      tableId: tableId,
      status: status,
      items: items.map((dto) => dto.toEntity()).toList(),
      totalAmount: totalAmount,
      createdAt: DateTime.parse(createdAt),
      completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
      specialInstructions: specialInstructions,
      customerId: customerId,
    );
  }
}

class OrderItemDto {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String? specialInstructions;

  OrderItemDto({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.specialInstructions,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDto(
      menuItemId: json['menuItem'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      specialInstructions: json['specialInstructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItem': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'specialInstructions': specialInstructions,
    };
  }

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      menuItemId: menuItemId,
      name: name,
      price: price,
      quantity: quantity,
      specialInstructions: specialInstructions,
    );
  }
}
