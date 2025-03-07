import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tottouchordertastemobileapplication/app/constants/api_endpoints.dart';
import 'package:tottouchordertastemobileapplication/core/errors/exceptions.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/model/table_validation_model.dart';

abstract class TableDataSource {
  Future<dynamic> getRestaurantTables(String restaurantId);
  Future<dynamic> getAvailableTables(String restaurantId);
  Future<dynamic> getTableById(String tableId);
  Future<TableValidationModel> validateTableQR(
      String restaurantId, String qrData);
  Future<bool> requestTable(String tableId, String sessionToken);
}

class TableDataSourceImpl implements TableDataSource {
  final http.Client client;

  TableDataSourceImpl({required this.client});

  @override
  Future<dynamic> getRestaurantTables(String restaurantId) async {
    final response = await client.get(
      Uri.parse(ApiEndpoints.getRestaurantTables(restaurantId)),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw const ServerException('Failed to load restaurant tables', 400);
    }
  }

  @override
  Future<dynamic> getAvailableTables(String restaurantId) async {
    final response = await client.get(
      Uri.parse(
          '${ApiEndpoints.baseUrl}/restaurants/tables/restaurant/$restaurantId/available'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw const ServerException('Failed to load available tables', 400);
    }
  }

  @override
  Future<dynamic> getTableById(String tableId) async {
    final response = await client.get(
      Uri.parse(ApiEndpoints.getTableById(tableId)),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw const ServerException('Failed to load table details', 400);
    }
  }

  @override
  Future<TableValidationModel> validateTableQR(
      String restaurantId, String qrData) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.validateTableQR()),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'qrData': qrData,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return TableValidationModel.fromJson(responseData['data']);
    } else {
      final errorMessage =
          json.decode(response.body)['message'] ?? 'Failed to validate QR code';
      throw ServerException(errorMessage, response.statusCode);
    }
  }

  @override
  Future<bool> requestTable(String tableId, String sessionToken) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.requestTable(tableId)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: json.encode({
        'sessionToken': sessionToken,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorMessage =
          json.decode(response.body)['message'] ?? 'Failed to request table';
      throw ServerException(errorMessage, response.statusCode);
    }
  }

  Future<String> getToken() async {
    // Replace with your actual token retrieval logic
    // This might come from SharedPreferences or a secure storage
    // For now, returning a placeholder
    return 'your_auth_token_here';
  }
}
