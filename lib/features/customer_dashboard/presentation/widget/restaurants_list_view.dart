// import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';

// import 'restaurant_card.dart';

// class RestaurantsListView extends StatefulWidget {
//   final List<RestaurantEntity> restaurants;
//   final Function(RestaurantEntity)? onRestaurantTap;

//   const RestaurantsListView(
//       {super.key, required this.restaurants, this.onRestaurantTap});

//   @override
//   State<RestaurantsListView> createState() => _RestaurantsListViewState();
// }

// class _RestaurantsListViewState extends State<RestaurantsListView> {
//   final TextEditingController _searchController = TextEditingController();
//   List<RestaurantEntity> _filteredRestaurants = [];
//   bool _isLoading = true;
//   String _errorMessage = '';

//   static const Color primaryDark = Color(0xFF8E0000);
//   static const Color primaryLight = Color(0xFFFF4444);

//   static const List<String> _categories = [
//     "All",
//     "Appetizer",
//     "Main Course",
//     "Dessert",
//     "Beverage",
//     "Special"
//   ];

//   static const List<String> _bannerTexts = [
//     "🍽️ Feeling hungry? Time to treat yourself!",
//     "🌮 Your cravings deserve the best!",
//     "🔥 Hot and fresh food is just a tap away!",
//     "🍕 Order now and satisfy your taste buds!",
//     "🥗 Eating healthy? We got you covered!",
//     "🍔 Why wait? Your next favorite meal is here!"
//   ];

//   String _randomBannerMessage = "";
//   String _selectedCategory = "All";

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   void _initializeData() {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//       _filteredRestaurants = List.from(widget.restaurants);
//       _randomBannerMessage =
//           _bannerTexts[Random().nextInt(_bannerTexts.length)];
//     });

//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     });
//   }

//   void _filterRestaurants(String query) {
//     setState(() {
//       _filteredRestaurants = widget.restaurants.where((restaurant) {
//         final nameMatch = restaurant.restaurantName
//             .toLowerCase()
//             .contains(query.toLowerCase());

//         final categoryMatch = _selectedCategory == "All" ||
//             restaurant.category?.toLowerCase() ==
//                 _selectedCategory.toLowerCase();

//         return nameMatch && categoryMatch;
//       }).toList();
//     });
//   }

//   void _filterByCategory(String category) {
//     setState(() {
//       _selectedCategory = category;
//       _filterRestaurants(_searchController.text);
//     });
//   }

//   void _clearFilters() {
//     _searchController.clear();
//     _filterByCategory("All");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: CustomScrollView(
//         slivers: [
//           SliverToBoxAdapter(child: _buildBannerSection()),
//           SliverToBoxAdapter(child: _buildSearchAndFilterSection()),
//           SliverToBoxAdapter(child: _buildCategoryFilters()),
//           SliverPadding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             sliver: _isLoading
//                 ? SliverToBoxAdapter(child: _buildShimmerLoading())
//                 : _errorMessage.isNotEmpty
//                     ? SliverToBoxAdapter(child: _buildErrorState())
//                     : _buildRestaurantList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBannerSection() {
//     return Container(
//       width: double.infinity,
//       height: 200,
//       margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 8,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: CachedNetworkImage(
//               imageUrl:
//                   'https://images.unsplash.com/photo-1598214886806-c87b84b7078b',
//               width: double.infinity,
//               height: 200,
//               fit: BoxFit.cover,
//               placeholder: (context, url) => Container(
//                 color: Colors.grey[300],
//                 child: const Center(child: CircularProgressIndicator()),
//               ),
//               errorWidget: (context, url, error) => Container(
//                 color: Colors.grey[300],
//                 child: const Center(
//                   child:
//                       Icon(Icons.restaurant_menu, size: 50, color: Colors.grey),
//                 ),
//               ),
//             ),
//           ),
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black.withOpacity(0.2),
//                     Colors.black.withOpacity(0.6),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             left: 20,
//             right: 20,
//             bottom: 20,
//             child: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 800),
//               transitionBuilder: (child, animation) => FadeTransition(
//                 opacity: animation,
//                 child: child,
//               ),
//               child: Text(
//                 _randomBannerMessage,
//                 key: ValueKey(_randomBannerMessage),
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 1.1,
//                   shadows: [
//                     Shadow(
//                       blurRadius: 6,
//                       color: Colors.black,
//                       offset: Offset(2, 2),
//                     ),
//                   ],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchAndFilterSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _searchController,
//               onChanged: _filterRestaurants,
//               decoration: InputDecoration(
//                 hintText: 'Search restaurants...',
//                 prefixIcon: const Icon(Icons.search, color: primaryDark),
//                 suffixIcon: _searchController.text.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           _filterRestaurants('');
//                         },
//                       )
//                     : null,
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: const BorderSide(color: primaryDark, width: 2),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Container(
//             decoration: BoxDecoration(
//               color: primaryDark,
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: IconButton(
//               icon: const Icon(Icons.filter_list, color: Colors.white),
//               onPressed: _showFilterBottomSheet,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showFilterBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Filter Restaurants',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 16),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: _categories.map((category) {
//                 return ChoiceChip(
//                   label: Text(category),
//                   selected: _selectedCategory == category,
//                   onSelected: (_) {
//                     Navigator.pop(context);
//                     _filterByCategory(category);
//                   },
//                   selectedColor: primaryLight,
//                   backgroundColor: Colors.grey[200],
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryFilters() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Row(
//         children: _categories.map((category) {
//           final isSelected = _selectedCategory == category;
//           return Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: ChoiceChip(
//               label: Text(category),
//               selected: isSelected,
//               onSelected: (_) => _filterByCategory(category),
//               selectedColor: primaryDark,
//               labelStyle: TextStyle(
//                 color: isSelected ? Colors.white : primaryDark,
//                 fontWeight: FontWeight.w600,
//               ),
//               backgroundColor: Colors.white,
//               side: const BorderSide(color: primaryDark),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   SliverList _buildRestaurantList() {
//     return SliverList(
//       delegate: SliverChildBuilderDelegate(
//         (context, index) {
//           final restaurant = _filteredRestaurants[index];
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: RestaurantCard(
//               restaurant: restaurant,
//               onTap: () => widget.onRestaurantTap?.call(restaurant),
//             ),
//           );
//         },
//         childCount:
//             _filteredRestaurants.isEmpty ? 1 : _filteredRestaurants.length,
//       ),
//     );
//   }

//   Widget _buildShimmerLoading() {
//     return Column(
//       children: List.generate(3, (index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Container(
//             height: 100,
//             margin: const EdgeInsets.symmetric(vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildErrorState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             _errorMessage,
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _initializeData,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: primaryDark,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text("Try Again"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view/restaurant_dashboard_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_event.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_state.dart';

class RestaurantsListView extends StatelessWidget {
  const RestaurantsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerDashboardBloc, CustomerDashboardState>(
      builder: (context, state) {
        if (state is CustomerDashboardLoading) {
          return _buildLoadingState();
        }

        if (state is RestaurantsLoaded) {
          return _buildRestaurantContent(context, state.restaurants);
        }

        if (state is CustomerDashboardError) {
          return _buildErrorState(context, state.message);
        }

        return _buildErrorState(context, 'Unable to load restaurants');
      },
    );
  }

  Widget _buildRestaurantContent(
      BuildContext context, List<RestaurantEntity> restaurants) {
    // Log the number of restaurants for debugging
    debugPrint('Loaded ${restaurants.length} restaurants');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRecommendedSection(context, restaurants),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'All Restaurants',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildRestaurantListItem(context, restaurant),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRestaurantImage(RestaurantEntity restaurant) {
    debugPrint(
        '🔍 Checking image for ${restaurant.restaurantName}: ${restaurant.image}');

    if (restaurant.image == null || restaurant.image!.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        color: Colors.grey[300],
        child: const Icon(Icons.restaurant, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: CachedNetworkImage(
        imageUrl: restaurant.image!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 120,
          height: 120,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          debugPrint(
              '❌ Error loading image for ${restaurant.restaurantName}: $error');
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[300],
            child: const Icon(Icons.restaurant, color: Colors.grey),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantListItem(
      BuildContext context, RestaurantEntity restaurant) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: InkWell(
        onTap: () => _navigateToRestaurantDashboard(context, restaurant),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRestaurantImage(restaurant),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.restaurantName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restaurant.quote,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurant.location,
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRestaurantDashboard(
      BuildContext context, RestaurantEntity restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDashboardView(restaurant: restaurant),
      ),
    );
  }

  Widget _buildRecommendedSection(
      BuildContext context, List<RestaurantEntity> restaurants) {
    // Shuffle restaurants and take up to 4
    final shuffledRestaurants = List<RestaurantEntity>.from(restaurants)
      ..shuffle(Random());
    final recommendedRestaurants =
        shuffledRestaurants.take(min(4, shuffledRestaurants.length)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended For You',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: recommendedRestaurants.map((restaurant) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _buildRecommendedItem(context, restaurant),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedItem(
      BuildContext context, RestaurantEntity restaurant) {
    return GestureDetector(
      onTap: () => _navigateToRestaurantDashboard(context, restaurant),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRestaurantImage(restaurant),
            // Restaurant details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant name
                  Text(
                    restaurant.restaurantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Restaurant description/quote
                  Text(
                    restaurant.quote,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Bottom row with location and category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Location with ellipsis
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 12, color: Colors.orange.shade700),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                restaurant.location,
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Spacing
                      const SizedBox(width: 4),

                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          restaurant.category ?? 'General',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // PRO badge if applicable
                  if (restaurant.subscriptionPro)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star,
                              size: 10, color: Colors.amber.shade700),
                          const SizedBox(width: 2),
                          Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.amber.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context
                .read<CustomerDashboardBloc>()
                .add(LoadRestaurantsEvent()),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
