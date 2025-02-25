import 'package:equatable/equatable.dart';

class MenuItemEntity extends Equatable {
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

  const MenuItemEntity({
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

  MenuItemEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? image,
    bool? isAvailable,
    String? restaurantId,
    int? preparationTime,
    String? spicyLevel,
    bool? isVegetarian,
    List<String>? allergens,
    Map<String, dynamic>? nutritionalInfo,
  }) {
    return MenuItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      image: image ?? this.image,
      isAvailable: isAvailable ?? this.isAvailable,
      restaurantId: restaurantId ?? this.restaurantId,
      preparationTime: preparationTime ?? this.preparationTime,
      spicyLevel: spicyLevel ?? this.spicyLevel,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      allergens: allergens ?? this.allergens,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
    );
  }

  factory MenuItemEntity.fromJson(Map<String, dynamic> json) {
    // Handle price conversion safely
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) {
        try {
          return double.parse(value);
        } catch (_) {
          return 0.0;
        }
      }
      return 0.0;
    }

    // Safely handle allergens array
    List<String>? parseAllergens(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return null;
    }

    // Handle restaurant ID field which might be in different formats
    String parseRestaurantId(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) {
        return value['_id']?.toString() ?? '';
      }
      return '';
    }

    return MenuItemEntity(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: parsePrice(json['price']),
      category: json['category'] ?? '',
      image: json['image'],
      isAvailable: json['isAvailable'] ?? false,
      restaurantId:
          parseRestaurantId(json['restaurantId'] ?? json['restaurant']),
      preparationTime: json['preparationTime'] ?? 30,
      spicyLevel: json['spicyLevel'],
      isVegetarian: json['isVegetarian'] ?? false,
      allergens: parseAllergens(json['allergens']),
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
      'restaurantId': restaurantId,
      'preparationTime': preparationTime,
      'spicyLevel': spicyLevel,
      'isVegetarian': isVegetarian,
      'allergens': allergens,
      'nutritionalInfo': nutritionalInfo,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        category,
        image,
        isAvailable,
        restaurantId,
        preparationTime,
        spicyLevel,
        isVegetarian,
        allergens,
        nutritionalInfo,
      ];
}
