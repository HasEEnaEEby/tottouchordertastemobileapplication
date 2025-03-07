import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String id;
  final String restaurantId;
  final String tableId;
  final String status;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? specialInstructions;
  final String? customerId;
  final String? customerName;
  final String? customerEmail;

  const OrderEntity({
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
    this.customerName,
    this.customerEmail,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    // Handle customer field (can be a string ID or a map)
    String? customerId;
    if (json['customer'] is String) {
      customerId = json['customer'];
    } else if (json['customer'] is Map ||
        json['customer'] is Map<String, dynamic>) {
      customerId = json['customer']['_id']?.toString();
    }

    // Handle restaurant field (can be a string ID, a map, or null)
    String restaurantId;
    if (json['restaurant'] is String) {
      restaurantId = json['restaurant'];
    } else if (json['restaurant'] is Map ||
        json['restaurant'] is Map<String, dynamic>) {
      restaurantId = json['restaurant']['_id']?.toString() ?? '';
    } else {
      restaurantId = '';
    }

    // Handle table field (can be a string ID or a map)
    String tableId;
    if (json['table'] is String) {
      tableId = json['table'];
    } else if (json['table'] is Map || json['table'] is Map<String, dynamic>) {
      tableId = json['table']['_id']?.toString() ?? '';
    } else {
      tableId = '';
    }

    return OrderEntity(
      id: json['_id'] ?? '',
      restaurantId: restaurantId,
      tableId: tableId,
      status: json['status'] ?? 'pending',
      items: json['items'] != null
          ? List<OrderItemEntity>.from(
              json['items'].map((item) => OrderItemEntity.fromJson(item)))
          : [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      specialInstructions: json['specialInstructions'],
      customerId: customerId,
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
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
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'specialInstructions': specialInstructions,
      'customer': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
    };
  }

  // Method to calculate total number of items
  int get totalItems => items.fold(0, (total, item) => total + item.quantity);

  // Method to check if order is completed
  bool get isCompleted => status.toLowerCase() == 'completed';

  // Method to get estimated total preparation time (example)
  Duration estimatePreparationTime() {
    // Assume each item takes 5 minutes to prepare
    return Duration(minutes: items.length * 5);
  }

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        tableId,
        status,
        items,
        totalAmount,
        createdAt,
        completedAt,
        specialInstructions,
        customerId,
        customerName,
        customerEmail,
      ];
}

class OrderItemEntity extends Equatable {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String? specialInstructions;
  final String? categoryName;

  const OrderItemEntity({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.specialInstructions,
    this.categoryName,
  });

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    // Handle menuItem field (can be a string ID or a map)
    String menuItemId;
    if (json['menuItem'] is String) {
      menuItemId = json['menuItem'];
    } else if (json['menuItem'] is Map ||
        json['menuItem'] is Map<String, dynamic>) {
      menuItemId = json['menuItem']['_id']?.toString() ?? '';
    } else {
      menuItemId = '';
    }

    return OrderItemEntity(
      menuItemId: menuItemId,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      specialInstructions: json['specialInstructions'],
      categoryName: json['categoryName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItem': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'categoryName': categoryName,
    };
  }

  // Calculate total price for this item
  double get totalPrice => price * quantity;

  @override
  List<Object?> get props => [
        menuItemId,
        name,
        price,
        quantity,
        specialInstructions,
        categoryName,
      ];
}

class OrderRequestEntity extends Equatable {
  final String restaurantId;
  final String tableId;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final String? specialInstructions;
  final String? customerName;
  final String? customerEmail;

  const OrderRequestEntity({
    required this.restaurantId,
    required this.tableId,
    required this.items,
    required this.totalAmount,
    this.specialInstructions,
    this.customerName,
    this.customerEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'restaurant': restaurantId,
      'table': tableId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'specialInstructions': specialInstructions,
      'customerName': customerName,
      'customerEmail': customerEmail,
    };
  }

  @override
  List<Object?> get props => [
        restaurantId,
        tableId,
        items,
        totalAmount,
        specialInstructions,
        customerName,
        customerEmail,
      ];
}
