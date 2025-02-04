import 'package:equatable/equatable.dart';

class CustomerProfile extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? profileImage;
  final String role;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional profile information
  final Map<String, dynamic> additionalInfo;

  const CustomerProfile({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.profileImage,
    required this.role,
    this.isEmailVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.additionalInfo = const {},
  });

  // Convenience getters
  String get name => displayName ?? username;

  int get loyaltyPoints => additionalInfo['loyaltyPoints'] is int
      ? additionalInfo['loyaltyPoints']
      : 0;

  List<String> get favoriteRestaurants =>
      additionalInfo['favoriteRestaurants'] is List<String>
          ? additionalInfo['favoriteRestaurants']
          : [];

  // Factory method to create from database document
  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      phoneNumber: json['contactNumber'],
      profileImage: json['profileImage'],
      role: json['role'] ?? 'customer',
      isEmailVerified: json['isEmailVerified'] ?? false,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : json['createdAt'] ?? DateTime.now(),
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'])
          : json['updatedAt'] ?? DateTime.now(),
      additionalInfo: {
        'loyaltyPoints': json['loyaltyPoints'] ?? 0,
        'favoriteRestaurants': json['favoriteRestaurants'] ?? [],
        'restaurantDetails': json['role'] == 'restaurant'
            ? {
                'restaurantName': json['restaurantName'],
                'location': json['location'],
                'contactNumber': json['contactNumber'],
                'quote': json['quote'],
                'status': json['status'],
              }
            : {},
      },
    );
  }

  // Convert to JSON for API/storage
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'contactNumber': phoneNumber,
      'profileImage': profileImage,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'loyaltyPoints': loyaltyPoints,
      'favoriteRestaurants': favoriteRestaurants,
      ...additionalInfo,
    };
  }

  // Create an empty profile
  factory CustomerProfile.empty() => CustomerProfile(
        id: '',
        username: '',
        email: '',
        role: 'customer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  // Create a copy with optional updates
  CustomerProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? profileImage,
    String? role,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalInfo,
  }) {
    return CustomerProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        displayName,
        phoneNumber,
        profileImage,
        role,
        isEmailVerified,
        createdAt,
        updatedAt,
        additionalInfo,
      ];
}
