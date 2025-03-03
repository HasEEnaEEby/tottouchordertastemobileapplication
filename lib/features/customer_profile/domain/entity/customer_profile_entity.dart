// lib/features/customer_dashboard/domain/entity/customer_profile_entity.dart
import 'package:equatable/equatable.dart';

class CustomerProfileEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerProfileEntity({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.phone,
    this.address,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        fullName,
        phone,
        address,
        imageUrl,
        createdAt,
        updatedAt,
      ];

  CustomerProfileEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? phone,
    String? address,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerProfileEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}