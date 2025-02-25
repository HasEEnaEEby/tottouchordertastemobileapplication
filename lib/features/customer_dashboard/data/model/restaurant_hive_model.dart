import 'package:hive/hive.dart';

import '../../domain/entity/restaurant_entity.dart';

part 'restaurant_hive_model.g.dart';

@HiveType(typeId: 10)
class RestaurantHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String username;

  @HiveField(2)
  late String restaurantName;

  @HiveField(3)
  late String location;

  @HiveField(4)
  late String contactNumber;

  @HiveField(5)
  late String quote;

  @HiveField(6)
  late String status;

  @HiveField(7)
  late String? email;

  @HiveField(8)
  late String? category;

  @HiveField(9)
  late DateTime? createdAt;

  @HiveField(10)
  late DateTime? updatedAt;

  @HiveField(11) // ✅ ADD THIS FIELD
  late String? image; // ✅ Now storing image

  // Default constructor required by Hive
  RestaurantHiveModel();

  // Constructor with all fields
  RestaurantHiveModel.create({
    required this.id,
    required this.username,
    required this.restaurantName,
    required this.location,
    required this.contactNumber,
    required this.quote,
    required this.status,
    this.email,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.image, // ✅ Now included
  });

  // Convert from RestaurantEntity to HiveModel
  factory RestaurantHiveModel.fromEntity(RestaurantEntity entity) {
    return RestaurantHiveModel.create(
      id: entity.id,
      username: entity.username,
      restaurantName: entity.restaurantName,
      location: entity.location,
      contactNumber: entity.contactNumber,
      quote: entity.quote,
      status: entity.status,
      email: entity.email ?? '',
      category: entity.category ?? 'Uncategorized',
      createdAt: entity.createdAt ?? DateTime.now(),
      updatedAt: entity.updatedAt ?? DateTime.now(),
      image: entity.image ??
          'https://via.placeholder.com/300x200?text=No+Image', // ✅ Now includes image
    );
  }

  // Convert JSON to Hive Model
  factory RestaurantHiveModel.fromJson(Map<String, dynamic> json) {
    return RestaurantHiveModel.create(
      id: json['_id'] as String,
      username: json['username'] as String? ?? '',
      restaurantName: json['restaurantName'] as String,
      location: json['location'] as String,
      contactNumber: json['contactNumber'] as String,
      quote: json['quote'] as String? ?? '',
      status: json['status'] as String? ?? '',
      email: json['email'] as String? ?? '',
      category: json['category'] as String? ?? 'Uncategorized',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      image: json['image'] != null && json['image'].isNotEmpty
          ? json['image'] as String
          : 'https://via.placeholder.com/300x200?text=No+Image', // ✅ Now includes image
    );
  }

  // Convert to RestaurantEntity (Domain Layer)
  RestaurantEntity toEntity() {
    return RestaurantEntity(
      id: id,
      username: username,
      restaurantName: restaurantName,
      location: location,
      contactNumber: contactNumber,
      quote: quote,
      status: status,
      email: email,
      category: category,
      createdAt: createdAt,
      updatedAt: updatedAt,
      image: image, // ✅ Now included
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'restaurantName': restaurantName,
      'location': location,
      'contactNumber': contactNumber,
      'quote': quote,
      'status': status,
      'email': email,
      'category': category,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'image': image, // ✅ Now included in JSON
    };
  }
}
