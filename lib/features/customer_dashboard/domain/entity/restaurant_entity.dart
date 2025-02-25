class RestaurantEntity {
  final String id;
  final String username;
  final String restaurantName;
  final String location;
  final String contactNumber;
  final String quote;
  final String status;
  final String? email;
  final String? image;
  final String? hours;
  final bool subscriptionPro;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RestaurantEntity({
    required this.id,
    required this.username,
    required this.restaurantName,
    required this.location,
    required this.contactNumber,
    required this.quote,
    required this.status,
    required this.image,
    this.email,
    this.hours,
    this.subscriptionPro = false,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory RestaurantEntity.fromJson(Map<String, dynamic> json) {
    return RestaurantEntity(
      id: json['_id'] as String,
      username: json['username'] as String? ?? '',
      restaurantName: json['restaurantName'] as String,
      location: json['location'] as String,
      contactNumber: json['contactNumber'] as String,
      quote: json['quote'] as String? ?? '',
      status: json['status'] as String? ?? '',
      email: json['email'] as String?,
      image: json.containsKey('image') &&
              json['image'] != null &&
              json['image'].isNotEmpty
          ? json['image'] as String
          : null,
      hours: json['hours'] as String?,
      subscriptionPro: json['subscriptionPro'] as bool? ?? false,
      category: json['category'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

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
      'image': image,
      'category': category,
      'subscriptionPro': subscriptionPro,
      'hours': hours,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
