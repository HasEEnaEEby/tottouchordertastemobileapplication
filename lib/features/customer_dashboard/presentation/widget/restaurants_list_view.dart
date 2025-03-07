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
import 'package:tottouchordertastemobileapplication/core/config/app_theme.dart'
    as app_colors;
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

        return _buildErrorState(context, 'Unable to load restaurant ');
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildRestaurantListItem(
      BuildContext context, RestaurantEntity restaurant) {
    // Check for dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with profile pic and restaurant name
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Profile image (small circular avatar)
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  backgroundImage:
                      restaurant.image != null && restaurant.image!.isNotEmpty
                          ? NetworkImage(restaurant.image!) as ImageProvider
                          : null,
                  child: restaurant.image == null || restaurant.image!.isEmpty
                      ? Icon(
                          Icons.restaurant,
                          color: isDark ? Colors.grey[400] : Colors.grey,
                          size: 20,
                        )
                      : null,
                ),

                const SizedBox(width: 10),

                // Restaurant name and verification badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Wrap the Text in Expanded to handle long names
                          Expanded(
                            child: Text(
                              restaurant.restaurantName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow
                                  .ellipsis, // Add ellipsis for long names
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (restaurant.subscriptionPro)
                            Icon(
                              Icons.verified,
                              size: 14,
                              color:
                                  isDark ? Colors.blue[300] : Colors.blue[600],
                            ),
                        ],
                      ),
                      Text(
                        restaurant.location,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Favorite button
                IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: app_colors.AppColors.primary,
                  ),
                  onPressed: () {
                    // Add restaurant to favorites
                  },
                ),
              ],
            ),
          ),

          // Main restaurant image (full width)
          GestureDetector(
            onTap: () => _navigateToRestaurantDashboard(context, restaurant),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: restaurant.image != null &&
                          restaurant.image!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: restaurant.image!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[300],
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) {
                            debugPrint(
                                '❌ Error loading image for ${restaurant.restaurantName}: $error');
                            return Container(
                              color:
                                  isDark ? Colors.grey[800] : Colors.grey[300],
                              child: Icon(
                                Icons.restaurant,
                                color: isDark ? Colors.grey[600] : Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                          child: Icon(
                            Icons.restaurant,
                            color: isDark ? Colors.grey[600] : Colors.grey,
                            size: 40,
                          ),
                        ),
                ),

                // Restaurant tags/badges
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(isDark ? 0.5 : 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '4.5', // You can replace with actual rating if available
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (restaurant.category != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.grey[850] : Colors.white)!
                            .withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        restaurant.category!,
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Restaurant description and stats
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant name and quote
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: restaurant.restaurantName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' ${restaurant.quote}',
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Restaurant stats/info
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '20-30 min',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.delivery_dining,
                      size: 14,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Enjoy your seamless ordering experience',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[600],
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

          // Order now button
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
            child: ElevatedButton(
              onPressed: () =>
                  _navigateToRestaurantDashboard(context, restaurant),
              style: ElevatedButton.styleFrom(
                backgroundColor: app_colors.AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Place the food you want to have',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullRestaurantImage(
      BuildContext context, RestaurantEntity restaurant) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDark ? Colors.grey[800] : Colors.grey[300];
    final iconColor = isDark ? Colors.grey[600] : Colors.grey;

    if (restaurant.image == null || restaurant.image!.isEmpty) {
      return Container(
        width: double.infinity,
        height: 250,
        color: containerColor,
        child: Icon(Icons.restaurant, color: iconColor, size: 60),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(0), // No rounded corners for Instagram-style
      child: CachedNetworkImage(
        imageUrl: restaurant.image!,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: containerColor,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          debugPrint(
              '❌ Error loading image for ${restaurant.restaurantName}: $error');
          return Container(
            color: containerColor,
            child: Icon(Icons.restaurant, color: iconColor, size: 60),
          );
        },
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
    // Check for dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final textSecondaryColor = isDark ? Colors.white70 : Colors.grey[600];

    return GestureDetector(
      onTap: () => _navigateToRestaurantDashboard(context, restaurant),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:
                  isDark ? Colors.black.withOpacity(0.2) : Colors.grey.shade200,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use dedicated method for recommended item images
            _buildRecommendedItemImage(context, restaurant),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant name
                  Text(
                    restaurant.restaurantName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Restaurant description/quote
                  Text(
                    restaurant.quote,
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Bottom row with location and category
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
                          color: isDark
                              ? Colors.green.shade900
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          restaurant.category ?? 'General',
                          style: TextStyle(
                            color: isDark
                                ? Colors.green.shade100
                                : Colors.green.shade700,
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
                        color: isDark
                            ? Colors.amber.shade900
                            : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 10,
                            color: isDark
                                ? Colors.amber.shade100
                                : Colors.amber.shade700,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'PRO',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.amber.shade100
                                  : Colors.amber.shade700,
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

  Widget _buildRecommendedItemImage(
      BuildContext context, RestaurantEntity restaurant) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDark ? Colors.grey[800] : Colors.grey[300];
    final iconColor = isDark ? Colors.grey[600] : Colors.grey;

    if (restaurant.image == null || restaurant.image!.isEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Container(
          width: 180,
          height: 120,
          color: containerColor,
          child: Icon(Icons.restaurant, color: iconColor, size: 40),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: CachedNetworkImage(
        imageUrl: restaurant.image!,
        width: 180,
        height: 120,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: containerColor,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          debugPrint(
              '❌ Error loading image for ${restaurant.restaurantName}: $error');
          return Container(
            color: containerColor,
            child: Icon(Icons.restaurant, color: iconColor, size: 40),
          );
        },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? Colors.red[300] : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
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
