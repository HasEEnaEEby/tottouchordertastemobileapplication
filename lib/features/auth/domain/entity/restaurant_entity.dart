class RestaurantEntity {
  final String id;
  final String username;
  final String restaurantName;
  final String location;
  final String contactNumber;
  final String quote;
  final String status;

  const RestaurantEntity({
    required this.id,
    required this.username,
    required this.restaurantName,
    required this.location,
    required this.contactNumber,
    required this.quote,
    required this.status,
  });

  factory RestaurantEntity.fromJson(Map<String, dynamic> json) {
    return RestaurantEntity(
      id: json['id'] as String,
      username: json['username'] as String,
      restaurantName: json['restaurantName'] as String,
      location: json['location'] as String,
      contactNumber: json['contactNumber'] as String,
      quote: json['quote'] as String? ?? '',
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'restaurantName': restaurantName,
      'location': location,
      'contactNumber': contactNumber,
      'quote': quote,
      'status': status,
    };
  }
}
