class OrderRequestDto {
  final String restaurant;
  final String table;
  final List<OrderItemDto> items;
  final double totalAmount;
  final String? specialInstructions;

  OrderRequestDto({
    required this.restaurant,
    required this.table,
    required this.items,
    required this.totalAmount,
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'restaurant': restaurant,
      'table': table,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'specialInstructions': specialInstructions,
    };
  }
}

class OrderItemDto {
  final String menuItem;
  final String name;
  final double price;
  final int quantity;
  final String? specialInstructions;

  OrderItemDto({
    required this.menuItem,
    required this.name,
    required this.price,
    required this.quantity,
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'menuItem': menuItem,
      'name': name,
      'price': price,
      'quantity': quantity,
      'specialInstructions': specialInstructions,
    };
  }
}
