import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? image;
  final bool? isVegetarian;
  final String? specialInstructions;

  const CartItemEntity({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.image,
    this.isVegetarian,
    this.specialInstructions,
  });

  // Factory method to create a CartItemEntity from a MenuItemEntity
  factory CartItemEntity.fromMenuItem(
    String id,
    String name,
    double price,
    String? image,
    bool? isVegetarian,
  ) {
    return CartItemEntity(
      id: id,
      name: name,
      price: price,
      image: image,
      isVegetarian: isVegetarian,
    );
  }

  // Method to create a copy of the entity with optional updates
  CartItemEntity copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? image,
    bool? isVegetarian,
    String? specialInstructions,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, price, quantity, image, isVegetarian, specialInstructions];
}
