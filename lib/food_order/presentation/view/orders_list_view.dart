// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:tottouchordertastemobileapplication/core/config/app_colors.dart';
// import 'package:tottouchordertastemobileapplication/core/theme/theme_helper.dart';
// import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
// import 'package:tottouchordertastemobileapplication/food_order/presentation/view/order_tracking_view.dart';
// import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_bloc.dart';
// import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_event.dart';
// import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_state.dart';

// class OrdersListView extends StatefulWidget {
//   const OrdersListView({super.key});

//   @override
//   State<OrdersListView> createState() => _OrdersListViewState();
// }

// class _OrdersListViewState extends State<OrdersListView> {
//   late bool _isDarkMode;
//   late ThemeColors _themeColors;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchOrders();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _updateThemeMode();
//   }

//   void _updateThemeMode() {
//     setState(() {
//       _isDarkMode = Theme.of(context).brightness == Brightness.dark;
//       _themeColors = ThemeHelper.fromDarkMode(_isDarkMode);
//     });
//   }

//   void _fetchOrders() {
//     context.read<FoodOrderBloc>().add(const FetchAllOrdersEvent());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _themeColors.backgroundColor,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: _themeColors.headerBackground,
//         foregroundColor: _themeColors.textPrimary,
//         title: Text(
//           'My Orders',
//           style: TextStyle(
//             color: _themeColors.textPrimary,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(
//               Icons.refresh,
//               color: _themeColors.iconPrimary,
//             ),
//             onPressed: _isLoading ? null : _fetchOrders,
//           ),
//         ],
//       ),
//       body: BlocConsumer<FoodOrderBloc, FoodOrderState>(
//         listener: (context, state) {
//           setState(() {
//             _isLoading = state is FoodOrderLoading;
//           });

//           if (state is FoodOrderError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is FoodOrderLoading) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           if (state is AllOrdersLoaded) {
//             return _buildOrdersList(state.orders);
//           }

//           return _buildEmptyView();
//         },
//       ),
//     );
//   }

//   Widget _buildOrdersList(List<OrderEntity> orders) {
//     if (orders.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.receipt_long,
//               size: 64,
//               color: _themeColors.iconSecondary,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No Orders Yet',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//                 color: _themeColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: Text(
//                 'Your order history will appear here once you place orders.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: _themeColors.textSecondary,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     // Sort orders by date (newest first)
//     final sortedOrders = List<OrderEntity>.from(orders)
//       ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

//     // Group orders by date
//     final groupedOrders = <String, List<OrderEntity>>{};
//     for (final order in sortedOrders) {
//       final dateKey = DateFormat('MMM d, yyyy').format(order.createdAt);
//       if (!groupedOrders.containsKey(dateKey)) {
//         groupedOrders[dateKey] = [];
//       }
//       groupedOrders[dateKey]!.add(order);
//     }

//     return RefreshIndicator(
//       onRefresh: () async {
//         _fetchOrders();
//         await Future.delayed(const Duration(milliseconds: 800));
//       },
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: groupedOrders.length,
//         itemBuilder: (context, index) {
//           final dateKey = groupedOrders.keys.elementAt(index);
//           final dateOrders = groupedOrders[dateKey]!;

//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
//                 child: Text(
//                   dateKey,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: _themeColors.textPrimary,
//                   ),
//                 ),
//               ),
//               ...dateOrders.map((order) => _buildOrderCard(order)),
//               if (index < groupedOrders.length - 1) const SizedBox(height: 16),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildOrderCard(OrderEntity order) {
//     final orderTime = DateFormat('h:mm a').format(order.createdAt);
//     final isActiveOrder = order.status == 'active' ||
//         order.status == 'preparing' ||
//         order.status == 'ready';

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       color: _themeColors.cardColor,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OrderTrackingView(orderId: order.id),
//             ),
//           ).then((_) {
//             // Refresh orders list when returning from tracking view
//             _fetchOrders();
//           });
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Restaurant icon or first letter in circle
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(order.status).withOpacity(0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Center(
//                       child: Icon(
//                         _getStatusIcon(order.status),
//                         color: _getStatusColor(order.status),
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),

//                   // Order details
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _getRestaurantName(order),
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: _themeColors.textPrimary,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Text(
//                               'Order #${order.id.substring(0, 6)}',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: _themeColors.textSecondary,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Icon(
//                               Icons.schedule,
//                               size: 14,
//                               color: _themeColors.iconSecondary,
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               orderTime,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: _themeColors.textSecondary,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'} • ${NumberFormat.currency(
//                             symbol: '₹',
//                             decimalDigits: 2,
//                           ).format(order.totalAmount)}',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: _themeColors.textPrimary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Status badge
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 5,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(order.status).withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Text(
//                       _getStatusText(order.status),
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: _getStatusColor(order.status),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               if (isActiveOrder) ...[
//                 const SizedBox(height: 16),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 8,
//                     horizontal: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.touch_app,
//                         size: 16,
//                         color: AppColors.primary,
//                       ),
//                       SizedBox(width: 8),
//                       Text(
//                         'Tap to track your order',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_outline,
//             size: 64,
//             color: _themeColors.iconSecondary,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Could not load orders',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w500,
//               color: _themeColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: _fetchOrders,
//             icon: const Icon(Icons.refresh),
//             label: const Text('Retry'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getRestaurantName(OrderEntity order) {
//     return order.restaurantName ?? 'Restaurant';
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return Colors.blue;
//       case 'preparing':
//         return Colors.orange;
//       case 'ready':
//         return Colors.amber;
//       case 'completed':
//         return Colors.green;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getStatusIcon(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return Icons.receipt_long;
//       case 'preparing':
//         return Icons.restaurant;
//       case 'ready':
//         return Icons.done_all;
//       case 'completed':
//         return Icons.check_circle;
//       case 'cancelled':
//         return Icons.cancel;
//       default:
//         return Icons.help_outline;
//     }
//   }

//   String _getStatusText(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return 'Active';
//       case 'preparing':
//         return 'Preparing';
//       case 'ready':
//         return 'Ready';
//       case 'completed':
//         return 'Completed';
//       case 'cancelled':
//         return 'Cancelled';
//       default:
//         return status;
//     }
//   }
// }
