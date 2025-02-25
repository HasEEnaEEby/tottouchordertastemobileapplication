// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tottouchordertastemobileapplication/app/constants/api_endpoints.dart';
// import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/menu_item_entity.dart';
// import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
// import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
// import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_event.dart';
// import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_state.dart';
// import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/widget/menu_item_card.dart';

// class RestaurantMenuView extends StatefulWidget {
//   final RestaurantEntity restaurant;

//   const RestaurantMenuView({super.key, required this.restaurant});

//   @override
//   State<RestaurantMenuView> createState() => _RestaurantMenuViewState();
// }

// class _RestaurantMenuViewState extends State<RestaurantMenuView> {
//   late final CustomerDashboardBloc _dashboardBloc;
//   List<String> categories = [
//     'All',
//     'Appetizer',
//     'Main Course',
//     'Dessert',
//     'Beverage',
//     'Special'
//   ];
//   String selectedCategory = 'All';

//   @override
//   void initState() {
//     super.initState();
//     _dashboardBloc = context.read<CustomerDashboardBloc>();
//     _loadRestaurantDetails();
//   }

//   void _loadRestaurantDetails() {
//     _dashboardBloc
//         .add(LoadRestaurantDetailsEvent(restaurantId: widget.restaurant.id));
//   }

//   String _getImageUrl(String? imagePath) {
//     if (imagePath == null || imagePath.isEmpty) {
//       return 'https://source.unsplash.com/random/800x400/?restaurant';
//     }

//     if (imagePath.startsWith('http')) {
//       return imagePath;
//     }

//     return '${ApiEndpoints.imageUrl}$imagePath';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: CustomScrollView(
//         slivers: [
//           _buildAppBar(),
//           SliverToBoxAdapter(
//             child: _buildCategorySelector(),
//           ),
//           BlocBuilder<CustomerDashboardBloc, CustomerDashboardState>(
//             builder: (context, state) {
//               if (state is RestaurantDetailsLoading) {
//                 return const SliverFillRemaining(
//                   child: Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
//                     ),
//                   ),
//                 );
//               }

//               if (state is RestaurantDetailsLoaded) {
//                 return _buildMenuGrid(state.menuItems);
//               }

//               if (state is RestaurantDetailsError) {
//                 return SliverFillRemaining(
//                   child: _buildErrorState(state.message),
//                 );
//               }

//               return const SliverFillRemaining(
//                 child: Center(
//                   child: Text('Loading menu...'),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       bottomNavigationBar:
//           BlocBuilder<CustomerDashboardBloc, CustomerDashboardState>(
//         builder: (context, state) {
//           if (state is RestaurantDetailsLoaded && state.cartItems.isNotEmpty) {
//             // Calculate total items and price
//             final totalItems =
//                 state.cartItems.fold(0, (total, item) => total + item.quantity);
//             final totalPrice = state.cartItems.fold(
//                 0.0, (total, item) => total + (item.price * item.quantity));

//             return Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.2),
//                     blurRadius: 8,
//                     offset: const Offset(0, -3),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '$totalItems items',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           '₹${totalPrice.toStringAsFixed(2)}',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: Color(0xFF8E0000),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Navigate to cart page or open cart modal
//                       _showCartModal(context, state);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF8E0000),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text('View Cart'),
//                   ),
//                 ],
//               ),
//             );
//           }
//           return Container(height: 0);
//         },
//       ),
//     );
//   }

//   void _showCartModal(BuildContext context, RestaurantDetailsLoaded state) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.8,
//           maxChildSize: 0.9,
//           minChildSize: 0.6,
//           expand: false,
//           builder: (context, scrollController) {
//             return Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Your Cart',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.close),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ],
//                   ),
//                   const Divider(),
//                   Expanded(
//                     child: ListView.builder(
//                       controller: scrollController,
//                       itemCount: state.cartItems.length,
//                       itemBuilder: (context, index) {
//                         final item = state.cartItems[index];
//                         return ListTile(
//                           leading: item.image != null
//                               ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: Image.network(
//                                     _getImageUrl(item.image),
//                                     width: 50,
//                                     height: 50,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Container(
//                                         width: 50,
//                                         height: 50,
//                                         color: Colors.grey[300],
//                                         child:
//                                             const Icon(Icons.restaurant_menu),
//                                       );
//                                     },
//                                   ),
//                                 )
//                               : Container(
//                                   width: 50,
//                                   height: 50,
//                                   color: Colors.grey[300],
//                                   child: const Icon(Icons.restaurant_menu),
//                                 ),
//                           title: Text(
//                             item.name,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           subtitle: Text('₹${item.price.toStringAsFixed(2)}'),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.remove_circle_outline),
//                                 onPressed: () {
//                                   _dashboardBloc
//                                       .add(UpdateCartItemQuantityEvent(
//                                     itemId: item.id,
//                                     quantity: item.quantity - 1,
//                                   ));
//                                 },
//                               ),
//                               Text('${item.quantity}'),
//                               IconButton(
//                                 icon: const Icon(Icons.add_circle_outline),
//                                 onPressed: () {
//                                   _dashboardBloc
//                                       .add(UpdateCartItemQuantityEvent(
//                                     itemId: item.id,
//                                     quantity: item.quantity + 1,
//                                   ));
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   const Divider(),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Total:',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         '₹${state.cartItems.fold(0.0, (total, item) => total + (item.price * item.quantity)).toStringAsFixed(2)}',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF8E0000),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // Place order logic
//                         if (state.selectedTable != null) {
//                           _dashboardBloc.add(PlaceOrderEvent(
//                             restaurantId: widget.restaurant.id,
//                             tableId: state.selectedTable!.id,
//                           ));
//                           Navigator.pop(context);
//                         } else {
//                           // Show table selection dialog
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Please select a table first'),
//                             ),
//                           );
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF8E0000),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text(
//                         'Proceed to Checkout',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   SliverAppBar _buildAppBar() {
//     return SliverAppBar(
//       expandedHeight: 200.0,
//       floating: false,
//       pinned: true,
//       backgroundColor: Colors.transparent,
//       leading: IconButton(
//         icon: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.8),
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(Icons.arrow_back, color: Colors.black),
//         ),
//         onPressed: () => Navigator.pop(context),
//       ),
//       flexibleSpace: FlexibleSpaceBar(
//         background: Stack(
//           fit: StackFit.expand,
//           children: [
//             // Restaurant Image
//             Image.network(
//               _getImageUrl(widget.restaurant.image),
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) => Container(
//                 color: Colors.grey[300],
//                 child:
//                     const Icon(Icons.restaurant, size: 80, color: Colors.grey),
//               ),
//             ),
//             // Gradient overlay for better text visibility
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.transparent,
//                     Colors.black.withOpacity(0.7),
//                   ],
//                 ),
//               ),
//             ),
//             // Restaurant Info
//             Positioned(
//               bottom: 16,
//               left: 16,
//               right: 16,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     widget.restaurant.restaurantName,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     widget.restaurant.location,
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.green.shade50,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.star,
//                                 size: 16, color: Colors.orange.shade700),
//                             const SizedBox(width: 4),
//                             Text(
//                               '${widget.restaurant.email}',
//                               style: TextStyle(color: Colors.green.shade800),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.orange.shade50,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           widget.restaurant.category ?? 'General',
//                           style: TextStyle(color: Colors.orange.shade800),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategorySelector() {
//     return Container(
//       height: 50,
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           final category = categories[index];
//           final isSelected = category == selectedCategory;

//           return Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedCategory = category;
//                 });
//               },
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? const Color(0xFF8E0000)
//                       : Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: isSelected ? Colors.white : Colors.black,
//                     fontWeight:
//                         isSelected ? FontWeight.bold : FontWeight.normal,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   SliverPadding _buildMenuGrid(List<MenuItemEntity> menuItems) {
//     // Filter menu items by category if not "All"
//     final filteredItems = selectedCategory == 'All'
//         ? menuItems
//         : menuItems.where((item) => item.category == selectedCategory).toList();

//     // Show message if no items in the selected category
//     if (filteredItems.isEmpty) {
//       return SliverPadding(
//         padding: const EdgeInsets.all(16),
//         sliver: SliverToBoxAdapter(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No items available in $selectedCategory category',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return SliverPadding(
//       padding: const EdgeInsets.all(16),
//       sliver: SliverGrid(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 0.75,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//         ),
//         delegate: SliverChildBuilderDelegate(
//           (context, index) {
//             final menuItem = filteredItems[index];
//             return MenuItemCard(
//               menuItem: menuItem,
//               onAddToCart: () {
//                 _dashboardBloc.add(AddToCartEvent(menuItem: menuItem));
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('${menuItem.name} added to cart'),
//                     duration: const Duration(seconds: 1),
//                     behavior: SnackBarBehavior.floating,
//                   ),
//                 );
//               },
//             );
//           },
//           childCount: filteredItems.length,
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorState(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.error_outline,
//             size: 64,
//             color: Colors.red,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             onPressed: _loadRestaurantDetails,
//             icon: const Icon(Icons.refresh),
//             label: const Text('Retry'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.orange,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
