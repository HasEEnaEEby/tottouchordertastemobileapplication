// lib/features/customer_dashboard/data/dto/restaurant_response_dto.dart

import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';

class RestaurantResponseDto {
  final String id;
  final String restaurantName;
  final String location;
  final String? description;
  final String? image;
  final String? hours;
  final String? phone;
  final String? email;
  final String? website;
  final String? category;
  final double? rating;
  final bool subscriptionPro;
  final String? quote;

  RestaurantResponseDto({
    required this.id,
    required this.restaurantName,
    required this.location,
    this.description,
    this.image,
    this.hours,
    this.phone,
    this.email,
    this.website,
    this.category,
    this.rating,
    required this.subscriptionPro,
    this.quote,
  });

  factory RestaurantResponseDto.fromJson(Map<String, dynamic> json) {
    return RestaurantResponseDto(
      id: json['_id'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      location: json['location'] ?? '',
      description: json['description'],
      image: json['image'],
      hours: json['hours'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      category: json['category'],
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      subscriptionPro: json['subscriptionPro'] ?? false,
      quote: json['quote'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantName': restaurantName,
      'location': location,
      'description': description,
      'image': image,
      'hours': hours,
      'phone': phone,
      'email': email,
      'website': website,
      'category': category,
      'rating': rating,
      'subscriptionPro': subscriptionPro,
      'quote': quote,
    };
  }

  RestaurantEntity toEntity() {
    return RestaurantEntity(
      id: id,
      restaurantName: restaurantName,
      location: location,
      image: image,
      hours: hours,
      email: email,
      category: category,
      subscriptionPro: subscriptionPro,
      username: restaurantName,
      contactNumber: '',
      quote: '',
      status: '',
    );
  }
}
