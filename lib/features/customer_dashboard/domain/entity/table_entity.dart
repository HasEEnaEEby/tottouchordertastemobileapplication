import 'package:equatable/equatable.dart';

class TableEntity extends Equatable {
  final String id;
  final int number;
  final int capacity;
  final String restaurantId;
  final String status;
  final Map<String, dynamic>? position;
  final String? currentOrder;
  final DateTime? lastUpdated;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TableEntity({
    required this.id,
    required this.number,
    required this.capacity,
    required this.restaurantId,
    required this.status,
    this.position,
    this.currentOrder,
    this.lastUpdated,
    this.createdAt,
    this.updatedAt,
  });

  factory TableEntity.fromJson(Map<String, dynamic> json) {
    return TableEntity(
      id: json['_id'] ?? '',
      number: json['number'] ?? 0,
      capacity: json['capacity'] ?? 4,
      restaurantId: json['restaurant'] ?? '',
      status: json['status'] ?? 'unavailable',
      position: json['position'] as Map<String, dynamic>?,
      currentOrder: json['currentOrder'] as String?,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'number': number,
      'capacity': capacity,
      'restaurant': restaurantId,
      'status': status,
      'position': position,
      'currentOrder': currentOrder,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create a copyWith method for easy modification
  TableEntity copyWith({
    String? id,
    int? number,
    int? capacity,
    String? restaurantId,
    String? status,
    Map<String, dynamic>? position,
    String? currentOrder,
    DateTime? lastUpdated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TableEntity(
      id: id ?? this.id,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      restaurantId: restaurantId ?? this.restaurantId,
      status: status ?? this.status,
      position: position ?? this.position,
      currentOrder: currentOrder ?? this.currentOrder,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convenience methods for status checking
  bool get isAvailable => status == 'available';
  bool get isOccupied => status == 'occupied';
  bool get isReserved => status == 'reserved';
  bool get isUnavailable => status == 'unavailable';

  @override
  List<Object?> get props => [
        id,
        number,
        capacity,
        restaurantId,
        status,
        position,
        currentOrder,
        lastUpdated,
        createdAt,
        updatedAt,
      ];
}
