import 'package:equatable/equatable.dart';

class RestaurantEntity extends Equatable {
  final String name;
  final String location;
  final String? description;
  final String contactNumber;
  final String? website;
  final bool isVerified;
  final Map<String, dynamic> businessHours;
  final List<String> cuisine;

  const RestaurantEntity({
    required this.name,
    required this.location,
    this.description,
    required this.contactNumber,
    this.website,
    this.isVerified = false,
    this.businessHours = const {},
    this.cuisine = const [],
  });

  @override
  List<Object?> get props => [
        name,
        location,
        description,
        contactNumber,
        website,
        isVerified,
        businessHours,
        cuisine,
      ];

  RestaurantEntity copyWith({
    String? name,
    String? location,
    String? description,
    String? contactNumber,
    String? website,
    bool? isVerified,
    Map<String, dynamic>? businessHours,
    List<String>? cuisine,
  }) {
    return RestaurantEntity(
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      contactNumber: contactNumber ?? this.contactNumber,
      website: website ?? this.website,
      isVerified: isVerified ?? this.isVerified,
      businessHours: businessHours ?? this.businessHours,
      cuisine: cuisine ?? this.cuisine,
    );
  }
}