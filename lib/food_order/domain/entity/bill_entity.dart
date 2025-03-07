import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';

class BillEntity extends Equatable {
  final String id;
  final String billNumber;
  final String orderId;
  final String restaurantId;
  final String restaurantName;
  final String tableId;
  final double subtotal;
  final double tax;
  final double serviceCharge;
  final double totalAmount;
  final bool isPaid;
  final String? paymentMethod;
  final DateTime generatedAt;
  final DateTime? paidAt;
  final String? notes;
  final double taxPercentage;
  final double serviceChargePercentage;
  final List<OrderItemEntity> items;

  const BillEntity({
    required this.id,
    required this.billNumber,
    required this.orderId,
    required this.restaurantId,
    required this.restaurantName,
    required this.tableId,
    required this.subtotal,
    required this.tax,
    required this.serviceCharge,
    required this.totalAmount,
    required this.isPaid,
    required this.generatedAt,
    required this.taxPercentage,
    required this.serviceChargePercentage,
    required this.items,
    this.paymentMethod,
    this.paidAt,
    this.notes,
  });

  factory BillEntity.fromJson(Map<String, dynamic> json) {
    // Extract bill data from the JSON
    Map<String, dynamic> billData = json;

    // If the response has a nested 'bill' object, use that
    if (json.containsKey('bill')) {
      billData = json['bill'];
    } else if (json.containsKey('data') &&
        json['data'] is Map &&
        json['data'].containsKey('bill')) {
      billData = json['data']['bill'];
    }

    // Handle order field (can be a string ID or a map)
    String orderId;
    if (billData['order'] is String) {
      orderId = billData['order'];
    } else if (billData['order'] is Map ||
        billData['order'] is Map<String, dynamic>) {
      orderId = billData['order']['_id']?.toString() ?? '';
    } else {
      orderId = '';
    }

    // Handle restaurant field (can be a string ID, a map, or null)
    String restaurantId;
    if (billData['restaurant'] is String) {
      restaurantId = billData['restaurant'];
    } else if (billData['restaurant'] is Map ||
        billData['restaurant'] is Map<String, dynamic>) {
      restaurantId = billData['restaurant']['_id']?.toString() ?? '';
    } else if (billData['order'] is Map &&
        billData['order']['restaurant'] != null) {
      // Try to get from the order if restaurant is not directly available
      if (billData['order']['restaurant'] is String) {
        restaurantId = billData['order']['restaurant'];
      } else if (billData['order']['restaurant'] is Map) {
        restaurantId = billData['order']['restaurant']['_id']?.toString() ?? '';
      } else {
        restaurantId = '';
      }
    } else {
      restaurantId = '';
    }

    // Handle table field (can be a string ID or a map)
    String tableId;
    if (billData['table'] is String) {
      tableId = billData['table'];
    } else if (billData['table'] is Map ||
        billData['table'] is Map<String, dynamic>) {
      tableId = billData['table']['_id']?.toString() ?? '';
    } else {
      tableId = '';
    }

    // Handle restaurant name (more extensive checks)
    String restaurantName = 'Restaurant';
    if (billData['restaurantName'] != null) {
      restaurantName = billData['restaurantName'];
    } else if (billData['restaurant'] is Map &&
        billData['restaurant']['name'] != null) {
      restaurantName = billData['restaurant']['name'];
    } else if (billData['order'] is Map &&
        billData['order']['restaurant'] is Map &&
        billData['order']['restaurant']['name'] != null) {
      restaurantName = billData['order']['restaurant']['name'];
    }

    // Parse items
    List<OrderItemEntity> billItems = [];
    if (billData['items'] != null) {
      billItems = List<OrderItemEntity>.from(
          billData['items'].map((item) => OrderItemEntity.fromJson(item)));
    }

    // Calculate tax and service charge percentages or use defaults
    double subtotal = (billData['subtotal'] ?? 0).toDouble();
    double tax = (billData['tax'] ?? 0).toDouble();
    double serviceCharge = (billData['serviceCharge'] ?? 0).toDouble();

    double taxPercentage = 5.0; // Default
    if (subtotal > 0 && tax > 0) {
      taxPercentage = (tax / subtotal * 100).round().toDouble();
    }

    double serviceChargePercentage = 10.0; // Default
    if (subtotal > 0 && serviceCharge > 0) {
      serviceChargePercentage =
          (serviceCharge / subtotal * 100).round().toDouble();
    }

    return BillEntity(
      id: billData['_id'] ?? billData['id'] ?? '',
      billNumber: billData['billNumber'] ?? '',
      orderId: orderId,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      tableId: tableId,
      subtotal: subtotal,
      tax: tax,
      serviceCharge: serviceCharge,
      totalAmount: (billData['totalAmount'] ?? 0).toDouble(),
      isPaid: billData['paymentStatus'] == 'paid' || billData['isPaid'] == true,
      generatedAt: billData['createdAt'] != null
          ? DateTime.parse(billData['createdAt'])
          : DateTime.now(),
      paidAt: billData['paidAt'] != null
          ? DateTime.parse(billData['paidAt'])
          : null,
      notes: billData['notes'],
      paymentMethod: billData['paymentMethod'],
      taxPercentage: taxPercentage,
      serviceChargePercentage: serviceChargePercentage,
      items: billItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billNumber': billNumber,
      'order': orderId,
      'restaurant': restaurantId,
      'restaurantName': restaurantName,
      'table': tableId,
      'subtotal': subtotal,
      'tax': tax,
      'serviceCharge': serviceCharge,
      'totalAmount': totalAmount,
      'isPaid': isPaid,
      'generatedAt': generatedAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'notes': notes,
      'paymentMethod': paymentMethod,
      'taxPercentage': taxPercentage,
      'serviceChargePercentage': serviceChargePercentage,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Formatted getters for display
  String get formattedSubtotal => NumberFormat.currency(
        symbol: '₹',
        decimalDigits: 2,
      ).format(subtotal);

  String get formattedTax => NumberFormat.currency(
        symbol: '₹',
        decimalDigits: 2,
      ).format(tax);

  String get formattedServiceCharge => NumberFormat.currency(
        symbol: '₹',
        decimalDigits: 2,
      ).format(serviceCharge);

  String get formattedTotal => NumberFormat.currency(
        symbol: '₹',
        decimalDigits: 2,
      ).format(totalAmount);

  String get displayBillNumber =>
      billNumber.isNotEmpty ? billNumber : id.substring(0, 8).toUpperCase();

  @override
  List<Object?> get props => [
        id,
        billNumber,
        orderId,
        restaurantId,
        restaurantName,
        tableId,
        subtotal,
        tax,
        serviceCharge,
        totalAmount,
        isPaid,
        generatedAt,
        paidAt,
        notes,
        paymentMethod,
        taxPercentage,
        serviceChargePercentage,
        items,
      ];
}
