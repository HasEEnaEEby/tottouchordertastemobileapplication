// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:tottouchordertastemobileapplication/core/config/app_colors.dart';
// import 'package:tottouchordertastemobileapplication/core/theme/theme_helper.dart';
// import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';

// class OrderSummaryCard extends StatelessWidget {
//   final FoodOrderEntity order;
//   final bool isDarkMode;
//   final ThemeColors themeColors;
//   final bool isDetailed;

//   const OrderSummaryCard({
//     super.key,
//     required this.order,
//     required this.isDarkMode,
//     required this.themeColors,
//     this.isDetailed = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: themeColors.cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: themeColors.shadowColor,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with restaurant and table info
//           _buildHeader(),

//           // Divider
//           Divider(color: themeColors.borderColor),

//           // Order items
//           isDetailed ? _buildDetailedItemsList() : _buildCompactItemsList(),

//           // Divider
//           Divider(color: themeColors.borderColor),

//           // Order totals
//           _buildTotals(),

//           // Payment status if completed
//           if (order.status == 'completed' || order.status == 'billing')
//             _buildPaymentStatus(),

//           // Special instructions if any
//           if (order.specialInstructions != null &&
//               order.specialInstructions!.isNotEmpty)
//             _buildSpecialInstructions(),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     final formattedDate =
//         DateFormat('MMM d, yyyy • h:mm a').format(order.orderDate);

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       order.restaurantName,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: themeColors.textPrimary,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Order #${order.id.substring(0, 6)}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: themeColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: themeColors.containerLight,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: themeColors.borderColor,
//                     width: 1,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.table_restaurant,
//                       size: 16,
//                       color: themeColors.iconPrimary,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       'Table ${order.tableNumber}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: themeColors.textPrimary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Icon(
//                 Icons.access_time,
//                 size: 14,
//                 color: themeColors.textSecondary,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 formattedDate,
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: themeColors.textSecondary,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactItemsList() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Order Items',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: themeColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           // Show first 3 items and a "+X more" if there are more
//           ...order.items.take(3).map((item) => Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4),
//                 child: Row(
//                   children: [
//                     Text(
//                       '${item.quantity}x',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: themeColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         item.name,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: themeColors.textPrimary,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     Text(
//                       item.formattedTotalPrice,
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: themeColors.textPrimary,
//                       ),
//                     ),
//                   ],
//                 ),
//               )),

//           // Show "+X more" if there are more than 3 items
//           if (order.items.length > 3)
//             Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: Text(
//                 '+${order.items.length - 3} more items',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontStyle: FontStyle.italic,
//                   color: themeColors.textSecondary,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailedItemsList() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Order Items',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: themeColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 12),

//           // Show all items with more details
//           ...order.items.map((item) => Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Quantity
//                     Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: BoxDecoration(
//                         color: themeColors.containerLight,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         '${item.quantity}x',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: themeColors.textPrimary,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),

//                     // Item details
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             item.name,
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w500,
//                               color: themeColors.textPrimary,
//                             ),
//                           ),

//                           // Show special instructions if any
//                           if (item.specialInstructions != null &&
//                               item.specialInstructions!.isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 4),
//                               child: Text(
//                                 item.specialInstructions!,
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontStyle: FontStyle.italic,
//                                   color: themeColors.textSecondary,
//                                 ),
//                               ),
//                             ),

//                           // Show vegetarian indicator
//                           if (item.isVegetarian)
//                             const Padding(
//                               padding: EdgeInsets.only(top: 4),
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.eco,
//                                     size: 14,
//                                     color: Colors.green,
//                                   ),
//                                   SizedBox(width: 4),
//                                   Text(
//                                     'Vegetarian',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.green,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),

//                     // Price
//                     Padding(
//                       padding: const EdgeInsets.only(top: 2),
//                       child: Text(
//                         item.formattedTotalPrice,
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w500,
//                           color: themeColors.textPrimary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               )),
//         ],
//       ),
//     );
//   }

//   Widget _buildTotals() {
//     // Calculate tax and total
//     final tax = order.totalAmount * 0.05; // Assuming 5% tax
//     final totalWithTax = order.totalAmount + tax;

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Totals',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: themeColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),

//           // Subtotal
//           _buildTotalRow(
//             'Subtotal',
//             order.formattedTotal,
//           ),

//           // Tax
//           _buildTotalRow(
//             'Tax (5%)',
//             '₹${tax.toStringAsFixed(2)}',
//           ),

//           // Divider
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Divider(
//               color: themeColors.borderColor,
//               height: 1,
//             ),
//           ),

//           // Total
//           _buildTotalRow(
//             'Total',
//             '₹${totalWithTax.toStringAsFixed(2)}',
//             isTotal: true,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTotalRow(String label, String amount, {bool isTotal = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: isTotal ? 16 : 14,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//               color: themeColors.textPrimary,
//             ),
//           ),
//           Text(
//             amount,
//             style: TextStyle(
//               fontSize: isTotal ? 16 : 14,
//               fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//               color: isTotal ? AppColors.primary : themeColors.textPrimary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaymentStatus() {
//     final isPaid = order.paymentStatus == 'paid';

//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: isPaid
//             ? Colors.green.withOpacity(0.1)
//             : Colors.orange.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: isPaid
//               ? Colors.green.withOpacity(0.3)
//               : Colors.orange.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             isPaid ? Icons.check_circle : Icons.pending,
//             color: isPaid ? Colors.green : Colors.orange,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isPaid ? 'Payment Completed' : 'Payment Pending',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: isPaid ? Colors.green : Colors.orange,
//                   ),
//                 ),
//                 if (order.paymentMethod != null)
//                   Text(
//                     'Method: ${order.paymentMethod}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: themeColors.textSecondary,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSpecialInstructions() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: themeColors.containerLight,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: themeColors.borderColor,
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Special Instructions:',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: themeColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             order.specialInstructions!,
//             style: TextStyle(
//               fontSize: 14,
//               color: themeColors.textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
