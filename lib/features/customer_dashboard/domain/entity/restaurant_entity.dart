class RestaurantEntity {
  final String id;
  final String username;
  final String email;
  final String restaurantName;
  final String location;
  final String contactNumber;
  final String quote;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  RestaurantEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.restaurantName,
    required this.location,
    required this.contactNumber,
    required this.quote,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}
