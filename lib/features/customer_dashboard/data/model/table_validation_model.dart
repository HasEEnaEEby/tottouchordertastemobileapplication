class TableValidationModel {
  final bool validated;
  final TableValidationData table;
  final String sessionToken;

  TableValidationModel({
    required this.validated,
    required this.table,
    required this.sessionToken,
  });

  factory TableValidationModel.fromJson(Map<String, dynamic> json) {
    return TableValidationModel(
      validated: json['validated'] ?? false,
      table: TableValidationData.fromJson(json['table'] ?? {}),
      sessionToken: json['sessionToken'] ?? '',
    );
  }
}

class TableValidationData {
  final String id;
  final int number;
  final int capacity;
  final String restaurantId;
  final String status;

  TableValidationData({
    required this.id,
    required this.number,
    required this.capacity,
    required this.restaurantId,
    required this.status,
  });

  factory TableValidationData.fromJson(Map<String, dynamic> json) {
    return TableValidationData(
      id: json['id'] ?? '',
      number: json['number'] ?? 0,
      capacity: json['capacity'] ?? 0,
      restaurantId: json['restaurantId'] ?? '',
      status: json['status'] ?? 'unavailable',
    );
  }
}
