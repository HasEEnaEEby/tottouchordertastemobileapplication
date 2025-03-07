// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:tottouchordertastemobileapplication/core/config/app_colors.dart';
// import 'package:tottouchordertastemobileapplication/core/theme/theme_helper.dart';
// import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';
// import 'package:tottouchordertastemobileapplication/food_order/presentation/widget/order_status_indicator.dart';

// class FoodOrderCard extends StatelessWidget {
//   final FoodOrderEntity order;
//   final bool isDarkMode;
//   final ThemeColors themeColors;
//   final VoidCallback onTap;

//   const FoodOrderCard({
//     super.key,
//     required this.order,
//     required this.isDarkMode,
//     required this.themeColors,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Format date and time
//     final formattedDate = DateFormat('MMM d, yyyy').format(order.orderDate);
//     final formattedTime = DateFormat('h:mm a').format(order.orderDate);

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(
//           color: themeColors.borderColor,
//           width: 1,
//         ),
//       ),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       color: themeColors.cardColor,
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Order ID, Date, and Status
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Restaurant logo/placeholder
//                   Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       color: themeColors.containerLight,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Center(
//                       child: Icon(
//                         Icons.restaurant_rounded,
//                         color: Color(order.statusColor),
//                         size: 24,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),

//                   // Order info
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           order.restaurantName,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: themeColors.textPrimary,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Order #${order.id.substring(0, 6)}',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: themeColors.textSecondary,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.access_time,
//                               size: 14,
//                               color: themeColors.textSecondary,
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               '$formattedDate at $formattedTime',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: themeColors.textSecondary,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Status indicator
//                   OrderStatusIndicator(
//                     order: order,
//                     isCompact: true,
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),
//               const Divider(height: 1),
//               const SizedBox(height: 16),

//               // Order summary
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Items count
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Items',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: themeColors.textSecondary,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${order.itemCount}',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: themeColors.textPrimary,
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Table number
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Table',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: themeColors.textSecondary,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${order.tableNumber}',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: themeColors.textPrimary,
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Total amount
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         'Total',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: themeColors.textSecondary,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         order.formattedTotal,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // Bottom action area
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Item preview (first 2 items)
//                   Expanded(
//                     child: Text(
//                       _getItemsPreview(),
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: themeColors.textSecondary,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),

//                   // View details button
//                   Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     size: 16,
//                     color: themeColors.iconSecondary,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper method to get a preview of the items
//   String _getItemsPreview() {
//     if (order.items.isEmpty) {
//       return 'No items';
//     }

//     final firstTwoItems = order.items.take(2).map((item) {
//       return '${item.quantity}x ${item.name}';
//     }).join(', ');

//     if (order.items.length <= 2) {
//       return firstTwoItems;
//     }

//     return '$firstTwoItems, +${order.items.length - 2} more';
//   }
// }
