// lib/features/customer_dashboard/data/dto/menu_item_response_dto.dart

import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/menu_item_entity.dart';

class MenuItemResponseDto {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? image;
  final bool isAvailable;
  final String restaurantId;
  final int preparationTime;
  final String? spicyLevel;
  final bool isVegetarian;
  final List<String>? allergens;
  final Map<String, dynamic>? nutritionalInfo;

  MenuItemResponseDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.image,
    required this.isAvailable,
    required this.restaurantId,
    required this.preparationTime,
    this.spicyLevel,
    required this.isVegetarian,
    this.allergens,
    this.nutritionalInfo,
  });

  factory MenuItemResponseDto.fromJson(Map<String, dynamic> json) {
    return MenuItemResponseDto(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      image: json['image'],
      isAvailable: json['isAvailable'] ?? false,
      restaurantId: json['restaurant'] ?? '',
      preparationTime: json['preparationTime'] ?? 30,
      spicyLevel: json['spicyLevel'],
      isVegetarian: json['isVegetarian'] ?? false,
      allergens: json['allergens'] != null
          ? List<String>.from(json['allergens'])
          : null,
      nutritionalInfo: json['nutritionalInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image': image,
      'isAvailable': isAvailable,
      'restaurant': restaurantId,
      'preparationTime': preparationTime,
      'spicyLevel': spicyLevel,
      'isVegetarian': isVegetarian,
      'allergens': allergens,
      'nutritionalInfo': nutritionalInfo,
    };
  }

  MenuItemEntity toEntity() {
    return MenuItemEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      category: category,
      image: image,
      isAvailable: isAvailable,
      restaurantId: restaurantId,
      preparationTime: preparationTime,
      spicyLevel: spicyLevel,
      isVegetarian: isVegetarian,
      allergens: allergens,
      nutritionalInfo: nutritionalInfo,
    );
  }
}
