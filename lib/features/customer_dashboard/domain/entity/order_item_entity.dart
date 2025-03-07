import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class OrderItemEntity extends Equatable {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final bool isVegetarian;
  final String? image;
  final String? specialInstructions;
  final String? categoryName;

  const OrderItemEntity({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.isVegetarian = false,
    this.image,
    this.specialInstructions,
    this.categoryName,
  });

  // Calculate total price for this item
  double get totalPrice => price * quantity;

  // Formatted price for display
  String get formattedPrice => NumberFormat.currency(
        symbol: '₹',
        decimalDigits: 2,
      ).format(price);

  // Formatted total price for display
  String get formattedTotalPrice => NumberFormat.currency(
        symbol: '₹',
        decimalDigits: 2,
      ).format(totalPrice);

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    // Handle menuItem field which can be a string ID or an object
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
      isVegetarian: json['isVegetarian'] ?? false,
      image: json['image'],
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
      'isVegetarian': isVegetarian,
      'image': image,
      'specialInstructions': specialInstructions,
      'categoryName': categoryName,
    };
  }

  @override
  List<Object?> get props => [
        menuItemId,
        name,
        price,
        quantity,
        isVegetarian,
        image,
        specialInstructions,
        categoryName,
      ];
}
