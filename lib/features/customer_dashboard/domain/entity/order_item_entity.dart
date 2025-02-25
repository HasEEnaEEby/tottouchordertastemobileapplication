import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String? specialInstructions;

  const OrderItemEntity({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.specialInstructions,
  });

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    return OrderItemEntity(
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
  
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
