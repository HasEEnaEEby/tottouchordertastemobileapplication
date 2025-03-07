// import 'package:dio/dio.dart';
// import 'package:tottouchordertastemobileapplication/app/constants/api_endpoints.dart';
// import 'package:tottouchordertastemobileapplication/core/auth/auth_token_manager.dart';
// import 'package:tottouchordertastemobileapplication/core/errors/exceptions.dart';
// import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
// import 'package:tottouchordertastemobileapplication/food_order/domain/entity/bill_entity.dart';
// import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';

// abstract class FoodOrderRemoteDataSource {
//   /// Fetches all orders for the current user
//   Future<List<FoodOrderEntity>> fetchFoodOrders();

//   /// Fetches details for a specific order
//   Future<FoodOrderEntity> fetchOrderDetails(String orderId);

//   /// Fetches bill for a specific order
//   Future<BillEntity> fetchOrderBill(String orderId);

//   /// Places a new order
//   Future<FoodOrderEntity> placeOrder(OrderRequestEntity orderRequest);
// }

// class FoodOrderRemoteDataSourceImpl implements FoodOrderRemoteDataSource {
//   final Dio dio;
//   final AuthTokenManager tokenManager;

//   FoodOrderRemoteDataSourceImpl({
//     required this.dio,
//     required this.tokenManager,
//   });

//   @override
//   Future<List<FoodOrderEntity>> fetchFoodOrders() async {
//     try {
//       final response = await dio.get(ApiEndpoints.getCustomerOrders);

//       if (response.statusCode == 200) {
//         final List<dynamic> ordersData = response.data['data'];
//         return ordersData
//             .map((orderJson) => FoodOrderEntity.fromJson(orderJson))
//             .toList();
//       } else {
//         throw ServerException(message: 'Failed to fetch orders');
//       }
//     } on DioException catch (e) {
//       throw ServerException(
//         message: e.response?.data['message'] ?? 'Network error',
//       );
//     }
//   }

//   @override
//   Future<FoodOrderEntity> fetchOrderDetails(String orderId) async {
//     try {
//       final response = await dio.get('/api/v1/orders/$orderId');

//       if (response.statusCode == 200) {
//         return FoodOrderEntity.fromJson(response.data['data']);
//       } else {
//         throw ServerException(message: 'Failed to fetch order details');
//       }
//     } on DioException catch (e) {
//       throw ServerException(
//         message: e.response?.data['message'] ?? 'Network error',
//       );
//     }
//   }

//   @override
//   Future<BillEntity> fetchOrderBill(String orderId) async {
//     try {
//       final response = await dio.get('/api/v1/orders/$orderId/bill');

//       if (response.statusCode == 200) {
//         return BillEntity.fromJson(response.data['data']);
//       } else {
//         throw ServerException(message: 'Failed to fetch order bill');
//       }
//     } on DioException catch (e) {
//       throw ServerException(
//         message: e.response?.data['message'] ?? 'Network error',
//       );
//     }
//   }

//   @override
//   Future<FoodOrderEntity> placeOrder(OrderRequestEntity orderRequest) async {
//     try {
//       final response = await dio.post(
//         ApiEndpoints.createOrder,
//         data: orderRequest.toJson(),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return FoodOrderEntity.fromJson(response.data['data']);
//       } else {
//         throw ServerException(message: 'Failed to place order');
//       }
//     } on DioException catch (e) {
//       throw ServerException(
//         message: e.response?.data['message'] ?? 'Network error',
//       );
//     }
//   }
// }
