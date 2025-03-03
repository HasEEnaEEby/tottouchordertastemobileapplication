import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tottouchordertastemobileapplication/core/config/app_colors.dart';
import 'package:tottouchordertastemobileapplication/core/config/text_styles.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/widget/proximity_sensord_demo.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_event.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_state.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/widget/notifications_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/widget/qr_code_scanner.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/widget/restaurants_list_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view/customer_profile_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view_model/customer_profile/customer_profile_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view_model/customer_profile/customer_profile_event.dart';

class CustomerDashboardView extends StatefulWidget {
  final String userName;

  const CustomerDashboardView({super.key, required this.userName});

  @override
  CustomerDashboardViewState createState() => CustomerDashboardViewState();
}

class CustomerDashboardViewState extends State<CustomerDashboardView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late final CustomerDashboardBloc _dashboardBloc;
  final TextEditingController _searchController = TextEditingController();

  int _selectedNavIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = context.read<CustomerDashboardBloc>();
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dashboardBloc.isClosed &&
          _dashboardBloc.state is! RestaurantsLoaded) {
        _dashboardBloc.add(LoadRestaurantsEvent());
      }
    });
  }

  Widget _buildDashboardContent(List<RestaurantEntity> restaurants) {
    return RefreshIndicator(
      onRefresh: () async {
        _dashboardBloc.add(LoadRestaurantsEvent());
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            // _buildFoodCategories(),
            _buildPromotionBanner(),
            _buildFilterOptions(),
            _buildCuisineExplorer(),
            const RestaurantsListView(),
            _buildTableOrderingSection(),
            _buildPopularDishes()
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<CustomerDashboardBloc, CustomerDashboardState>(
          bloc: _dashboardBloc,
          listener: (context, state) {
            if (state is CustomerDashboardError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CustomerDashboardLoading) {
              return _buildLoadingState();
            }

            if (state is RestaurantsLoaded) {
              return _buildDashboardContent(state.restaurants);
            }

            return _buildErrorState('Unable to load restaurants');
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFilterOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            "Find Your Perfect Restaurant",
            style: AppTextStyles.h4,
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              // Cuisine filter
              _buildFilterCard(
                title: "Cuisine Type",
                icon: Icons.restaurant_menu,
                options: [
                  "Japanese",
                  "Italian",
                  "Korean",
                  "Vegetarian",
                  "Nepali",
                  "All"
                ],
                onTap: () {
                  // Handle cuisine filter tap
                },
              ),

              // Distance filter
              _buildFilterCard(
                title: "Distance",
                icon: Icons.location_on,
                options: ["< 1 km", "< 3 km", "< 5 km", "Any"],
                onTap: () {
                  // Handle distance filter tap
                },
              ),

              // Rating filter
              _buildFilterCard(
                title: "Top Rated",
                icon: Icons.star,
                options: ["4.5+", "4.0+", "3.5+", "All"],
                onTap: () {
                  // Handle rating filter tap
                },
              ),

              // Features filter
              _buildFilterCard(
                title: "Features",
                icon: Icons.check_circle,
                options: [
                  "Table Reservation",
                  "Premium",
                  "Fast Service",
                  "Delivery"
                ],
                onTap: () {
                  // Handle features filter tap
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterCard({
    required String title,
    required IconData icon,
    required List<String> options,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.9),
              AppColors.primary.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and icon
              Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Top options with pills
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: options.take(3).map((option) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              // View More text
              Center(
                child: Text(
                  "View More",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, ${widget.userName} 👋",
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Hungry Now? ",
                      style: AppTextStyles.h3,
                    ),
                    TextSpan(
                      text: "🔥",
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 24,
              child: IconButton(
                icon: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
                onPressed: _navigateToProfile,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.inputText,
        decoration: InputDecoration(
          hintText: 'Search for food, restaurants...',
          hintStyle: AppTextStyles.inputHint,
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.tune,
              color: AppColors.primary,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  // Widget _buildFoodCategories() {
  //   final categories = [
  //     {"icon": Icons.lunch_dining, "name": "Burger"},
  //     {"icon": Icons.local_pizza, "name": "Pizza"},
  //     {"icon": Icons.tapas, "name": "Spaghetti"},
  //     {"icon": Icons.rice_bowl, "name": "Fried Rice"},
  //     {"icon": Icons.breakfast_dining, "name": "Tacos"},
  //     {"icon": Icons.coffee, "name": "Coffee"},
  //   ];

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Padding(
  //         padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
  //         child: Text(
  //           "Categories",
  //           style: AppTextStyles.h4,
  //         ),
  //       ),
  //       SizedBox(
  //         height: 100,
  //         child: ListView.builder(
  //           scrollDirection: Axis.horizontal,
  //           padding: const EdgeInsets.symmetric(horizontal: 8),
  //           itemCount: categories.length,
  //           itemBuilder: (context, index) {
  //             final category = categories[index];
  //             return Container(
  //               width: 80,
  //               margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Container(
  //                     height: 56,
  //                     width: 56,
  //                     decoration: BoxDecoration(
  //                       color: AppColors.primary.withOpacity(0.1),
  //                       borderRadius: BorderRadius.circular(16),
  //                     ),
  //                     child: Icon(
  //                       category['icon'] as IconData,
  //                       color: AppColors.primary,
  //                       size: 28,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   Text(
  //                     category['name'] as String,
  //                     style: AppTextStyles.bodySmall.copyWith(
  //                       fontWeight: FontWeight.w500,
  //                       color: AppColors.textPrimary,
  //                     ),
  //                     textAlign: TextAlign.center,
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildPromotionBanner() {
    return BlocBuilder<CustomerDashboardBloc, CustomerDashboardState>(
      builder: (context, state) {
        List<Map<String, dynamic>> featuredItems = [];

        if (state is RestaurantsLoaded ||
            state is CustomerDashboardTabChanged) {
          final List<RestaurantEntity> restaurants = state is RestaurantsLoaded
              ? state.restaurants
              : (state as CustomerDashboardTabChanged).restaurants;

          final premiumRestaurants =
              restaurants.where((r) => r.subscriptionPro == true).toList();

          for (var restaurant in premiumRestaurants) {
            featuredItems.add(_buildFeaturedItem(restaurant, true));
          }

          if (featuredItems.length < 3) {
            final nonPremiumRestaurants = restaurants
                .where((r) => r.subscriptionPro != true)
                .take(3 - featuredItems.length)
                .toList();

            for (var restaurant in nonPremiumRestaurants) {
              featuredItems.add(_buildFeaturedItem(restaurant, false));
            }
          }
        }

        if (featuredItems.isEmpty) {
          featuredItems = _getPlaceholderRestaurants();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Featured Restaurants",
                    style: AppTextStyles.h4,
                  ),
                  TextButton(
                    onPressed: () {}, // Navigate to full restaurant list
                    child: Text(
                      "View All",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: featuredItems.length,
              itemBuilder: (context, index) {
                return _buildInstagramStylePost(featuredItems[index]);
              },
            ),
          ],
        );
      },
    );
  }

// 🏆 Restaurant data helper
  Map<String, dynamic> _buildFeaturedItem(
      RestaurantEntity restaurant, bool isPremium) {
    return {
      'title': restaurant.restaurantName,
      'description': restaurant.quote,
      'image': restaurant.image ??
          'https://www.pngitem.com/pimgs/m/214-2144748_burger-png-transparent-png.png',
      'location': restaurant.location,
      'rating': isPremium ? 4.8 : 4.5,
      'isPremium': isPremium,
      'restaurantId': restaurant.id,
      'logo': restaurant.image ?? // Placeholder logo
          'https://www.pngitem.com/pimgs/m/214-2144748_burger-png-transparent-png.png',
    };
  }

// 🎨 Instagram-style Restaurant Post
  Widget _buildInstagramStylePost(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (Profile avatar & name)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  item['logo'],
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.restaurant, color: Colors.white),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item['location'],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black54),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Restaurant Image
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            item['image'],
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 250,
                color: Colors.grey[300],
                child:
                    const Icon(Icons.restaurant, size: 50, color: Colors.white),
              );
            },
          ),
        ),

        // Action Buttons (Like, Comment, Share, Save)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border, size: 28),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, size: 28),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border, size: 28),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Likes Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "Liked by foodie_lover and others",
            style:
                AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
          ),
        ),

        // Restaurant Caption
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: item['title'],
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: "  ${item['description']}",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Rating and Timestamp
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                "${item['rating']}",
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 10),
              Text(
                "2 hours ago",
                style: AppTextStyles.bodySmall.copyWith(color: Colors.black45),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10), // Space between posts
      ],
    );
  }

  List<Map<String, dynamic>> _getPlaceholderRestaurants() {
    return [
      {
        'title': 'Kitchen Chef',
        'description': 'Delicious food at your fingertips!',
        'image':
            'https://www.pngitem.com/pimgs/m/214-2144748_burger-png-transparent-png.png',
        'location': 'Kathmandu, Nepal',
        'rating': 4.8,
        'isPremium': true,
        'restaurantId': '67b87540368a14e2294e980e',
        'logo':
            'https://www.pngitem.com/pimgs/m/214-2144748_burger-png-transparent-png.png',
      },
      {
        'title': 'Avocado Cafe',
        'description': 'Healthy and fresh meals daily.',
        'image':
            'https://www.pngitem.com/pimgs/m/214-2144748_burger-png-transparent-png.png',
        'location': 'Lalitpur, Nepal',
        'rating': 4.7,
        'isPremium': false,
        'restaurantId': '67bdc50a197e6ac606c4a727',
        'logo':
            'https://www.pngitem.com/pimgs/m/214-2144748_burger-png-transparent-png.png',
      },
    ];
  }

  Widget _buildCuisineExplorer() {
    // Define cuisine types with images and colors
    final cuisines = [
      {
        'name': 'Japanese',
        'image':
            'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'color': const Color(0xFFF44336),
        'description': 'Sushi, Ramen, Tempura and more',
        'count': 3,
      },
      {
        'name': 'Italian',
        'image':
            'https://images.unsplash.com/photo-1595295333158-4742f28fbd85?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'color': const Color(0xFF4CAF50),
        'description': 'Pizza, Pasta, Risotto and more',
        'count': 2,
      },
      {
        'name': 'Korean',
        'image':
            'https://images.unsplash.com/photo-1580651315530-69c8e0026377?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'color': const Color(0xFF2196F3),
        'description': 'BBQ, Bibimbap, Kimchi and more',
        'count': 1,
      },
      {
        'name': 'Vegetarian',
        'image':
            'https://plus.unsplash.com/premium_photo-1669557211332-9328425b6f39?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'color': const Color(0xFF9C27B0),
        'description': 'Healthy, Organic, Plant-based options',
        'count': 4,
      },
      {
        'name': 'Nepali',
        'image':
            'https://images.unsplash.com/photo-1585937421612-70a008356c36?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'color': const Color(0xFFFF9800),
        'description': 'Momos, Dal Bhat, Thali and more',
        'count': 5,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            "Explore by Cuisine",
            style: AppTextStyles.h4,
          ),
        ),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: cuisines.length,
            itemBuilder: (context, index) {
              final cuisine = cuisines[index];
              return _buildCuisineCard(
                name: cuisine['name'] as String,
                image: cuisine['image'] as String,
                color: cuisine['color'] as Color,
                description: cuisine['description'] as String,
                count: cuisine['count'] as int,
                onTap: () {
                  // Filter restaurants by cuisine
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCuisineCard({
    required String name,
    required String image,
    required Color color,
    required String description,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cuisine image with gradient overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    image,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 110,
                        width: double.infinity,
                        color: color.withOpacity(0.3),
                        child: Icon(
                          Icons.restaurant,
                          color: color,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),

                // Gradient overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Cuisine name
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),

                // Restaurant count badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "$count Restaurants",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Description and explore button
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Explore button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Explore",
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: color,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableOrderingSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dining In?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "Order directly from your table",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick order options
          Row(
            children: [
              _buildQuickOrderOption(
                title: "Scan QR",
                description: "Scan QR code on your table",
                icon: Icons.qr_code,
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildQuickOrderOption(
                title: "Enter Code",
                description: "Enter restaurant code",
                icon: Icons.keyboard,
                color: Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Recent/Nearby restaurants for table ordering
          const Text(
            "Quick Access",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 10),

          // Recently ordered or nearby restaurants for table ordering
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickAccessRestaurant(
                  name: "Izakaya Hokkaido",
                  address: "Radisson Hotel Premises",
                  image:
                      "https://www.pngitem.com/pimgs/m/214-2144748_burger-png-transparent-png.png",
                  lastVisited: "2 days ago",
                ),
                _buildQuickAccessRestaurant(
                  name: "Roadhouse Cafe",
                  address: "Boudha Stupa",
                  image:
                      "https://www.pngitem.com/pimgs/m/214-2144748_burger-png-transparent-png.png",
                  lastVisited: "Last week",
                ),
                _buildQuickAccessRestaurant(
                  name: "Soko Korean Grill",
                  address: "Thamel, The Corner",
                  image:
                      "https://www.pngitem.com/pimgs/m/214-2144748_burger-png-transparent-png.png",
                  lastVisited: "Yesterday",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOrderOption({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (title == "Scan QR") {
            final currentState = _dashboardBloc.state;
            String? restaurantId;

            if (currentState is RestaurantsLoaded &&
                currentState.restaurants.isNotEmpty) {
              restaurantId = currentState.restaurants.first.id;

              if (restaurantId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRCodeScannerView(
                      restaurantId:
                          restaurantId!, // Use ! to assert non-nullability
                      onTableVerified: (tableId) {
                        // Handle table verification success
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Table $tableId verified!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Restaurant ID is missing or invalid'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a restaurant first'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromRGBO(color.red, color.green, color.blue,
                0.1), // Updated from withOpacity
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color.fromRGBO(color.red, color.green, color.blue,
                  0.3), // Updated from withOpacity
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(color.red, color.green, color.blue,
                      0.2), // Updated from withOpacity
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Button
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ); // Fixed the extra parenthesis here
  }

  Widget _buildQuickAccessRestaurant({
    required String name,
    required String address,
    required String image,
    required String lastVisited,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Restaurant image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Restaurant info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.history,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lastVisited,
                        style: const TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primary,
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
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            "Loading restaurants...",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "We couldn't load the restaurants. Please try again.",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _initializeData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              textStyle: AppTextStyles.buttonLarge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodySmall,
        currentIndex: _selectedNavIndex,
        elevation: 0,
        onTap: (index) {
          // Handle navigation based on index
          _handleNavigation(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _selectedNavIndex == 0
                  ? Icons.restaurant
                  : Icons.restaurant_outlined,
            ),
            label: 'Restaurants',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedNavIndex == 1 ? Icons.person : Icons.person_outline,
            ),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedNavIndex == 2 ? Icons.receipt : Icons.receipt_outlined,
            ),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(
                  _selectedNavIndex == 3
                      ? Icons.notifications
                      : Icons.notifications_outlined,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedNavIndex == 4
                  ? Icons.shopping_cart
                  : Icons.shopping_cart_outlined,
            ),
            label: 'Cart',
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    // If current index is already selected, do nothing
    if (index == _selectedNavIndex && index != 1) {
      return;
    }

    setState(() {
      _selectedNavIndex = index;
    });

    switch (index) {
      case 0: // Restaurants
        // Already on main dashboard, no navigation needed
        break;

      case 1: // Profile
        _navigateToProfile();
        break;

      case 2: // Orders
        // _navigateToOrders();
        break;

      case 3: // Notifications
        _navigateToNotifications();
        break;

      case 4: // Cart
        _navigateToSensorTest();
        break;
    }
  }

  void _navigateToProfile() {
    // Import the CustomerProfileBloc if it's not already imported
    final customerProfileBloc = GetIt.instance<CustomerProfileBloc>();

    // Trigger fetch profile event
    customerProfileBloc.add(FetchCustomerProfileEvent());

    // Navigate to profile page
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: customerProfileBloc,
          child: const CustomerProfileView(),
        ),
      ),
    )
        .then((_) {
      // When returning from profile, reset the selected index to 0 (Restaurants)
      if (mounted) {
        setState(() {
          _selectedNavIndex = 0;
        });
      }
    });
  }

// void _navigateToOrders() {
//   // Get the order history bloc
//   final customerOrderBloc = GetIt.instance<CustomerOrderBloc>();

//   // Fetch order history data
//   customerOrderBloc.add(FetchOrderHistoryEvent());

//   // Navigate to orders page
//   Navigator.of(context).push(
//     MaterialPageRoute(
//       builder: (context) => BlocProvider.value(
//         value: customerOrderBloc,
//         child: const CustomerOrderHistoryView(),
//       ),
//     ),
//   ).then((_) {
//     // When returning from orders, reset the selected index to 0 (Restaurants)
//     if (mounted) {
//       setState(() {
//         _selectedNavIndex = 0;
//       });
//     }
//   });
// }

  void _navigateToNotifications() {
    // Navigate to notifications page
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const NotificationsView(),
      ),
    )
        .then((_) {
      if (mounted) {
        setState(() {
          _selectedNavIndex = 0;
        });
      }
    });
  }

  void _navigateToSensorTest() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProximitySensorTestScreen(),
      ),
    );
  }

  Widget _buildPopularDishes() {
    // Sample dishes - in a real app, these would come from your API
    final popularDishes = [
      {
        'name': 'Spicy Ramen',
        'restaurant': 'Izakaya Hokkaido',
        'price': 'Rs.450',
        'image':
            'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'rating': 4.8,
        'cuisine': 'Japanese',
        'color': Colors.red.shade700,
        'isTopRated': true,
        'isRecommended': true,
        'preparationTime': '15 min',
      },
      {
        'name': 'Margherita Pizza',
        'restaurant': 'Roadhouse Cafe',
        'price': 'Rs.600',
        'image':
            'https://images.unsplash.com/photo-1513104890138-7c749659a591?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'rating': 4.6,
        'cuisine': 'Italian',
        'color': Colors.green.shade700,
        'isTopRated': false,
        'isRecommended': true,
        'preparationTime': '20 min',
      },
      {
        'name': 'Korean BBQ Platter',
        'restaurant': 'Soko Korean Grill',
        'price': 'Rs.950',
        'image':
            'https://images.unsplash.com/photo-1590330813083-fc22d4b6a48c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'rating': 4.9,
        'cuisine': 'Korean',
        'color': Colors.blue.shade700,
        'isTopRated': true,
        'isRecommended': false,
        'preparationTime': '25 min',
      },
      {
        'name': 'Avocado Salad',
        'restaurant': 'Forest and Plate',
        'price': 'Rs.380',
        'image':
            'https://images.unsplash.com/photo-1551248429-40975aa4de74?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'rating': 4.5,
        'cuisine': 'Vegetarian',
        'color': Colors.purple.shade700,
        'isTopRated': false,
        'isRecommended': true,
        'preparationTime': '10 min',
      },
      {
        'name': 'Momo Platter',
        'restaurant': 'Roadhouse Cafe',
        'price': 'Rs.320',
        'image':
            'https://images.unsplash.com/photo-1626568940331-93b4001a740f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'rating': 4.7,
        'cuisine': 'Nepali',
        'color': Colors.orange.shade700,
        'isTopRated': false,
        'isRecommended': true,
        'preparationTime': '18 min',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and view all button
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    "Most Popular Dishes",
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Top Rated",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "View All",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Dish cards
        SizedBox(
          height: 300, // Increased height to prevent overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: popularDishes.length,
            itemBuilder: (context, index) {
              final dish = popularDishes[index];
              return _buildEnhancedDishCard(
                name: dish['name'] as String,
                restaurant: dish['restaurant'] as String,
                price: dish['price'] as String,
                image: dish['image'] as String,
                rating: dish['rating'] as double,
                cuisine: dish['cuisine'] as String,
                color: dish['color'] as Color,
                isTopRated: dish['isTopRated'] as bool,
                isRecommended: dish['isRecommended'] as bool,
                preparationTime: dish['preparationTime'] as String,
                onTap: () {
                  // Handle dish tap
                },
                onAddToCart: () {
                  // Handle add to cart
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedDishCard({
    required String name,
    required String restaurant,
    required String price,
    required String image,
    required double rating,
    required String cuisine,
    required Color color,
    required bool isTopRated,
    required bool isRecommended,
    required String preparationTime,
    required VoidCallback onTap,
    required VoidCallback onAddToCart,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16, bottom: 12, top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use min to avoid taking extra space
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dish image with rating and cuisine
            Stack(
              children: [
                // Image with rounded corners at top
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    image,
                    height:
                        150, // Slightly reduced from 160 to allow more space for text
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: color.withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            Icons.fastfood,
                            color: color,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Rating badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Cuisine tag
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cuisine,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // "Top Rated" badge if applicable
                if (isTopRated)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 3),
                          Text(
                            "Top Rated",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Dish information - Use padding to control space more precisely
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(12, 10, 12, 10), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 14,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant,
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5), // Reduced spacing

                  // Preparation time and recommended tag in a more compact layout
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        preparationTime,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      // Show the recommended tag only if space permits
                      if (isRecommended) ...[
                        const SizedBox(width: 8), // Reduced spacing
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2), // Smaller padding
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(8), // Smaller radius
                              border: Border.all(
                                color: Colors.green,
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              "Recommended",
                              style: TextStyle(
                                fontSize: 9, // Smaller text
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8), // Reduced spacing

                  // Price and order button row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price with currency symbol
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: price.split('.')[0],
                              style: const TextStyle(
                                fontSize: 15, // Reduced size
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (price.contains('.'))
                              TextSpan(
                                text: ".${price.split('.')[1]}",
                                style: TextStyle(
                                  fontSize: 13, // Reduced size
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary.withOpacity(0.7),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Add to cart button - more compact
                      Material(
                        borderRadius:
                            BorderRadius.circular(10), // Smaller radius
                        color: AppColors.primary,
                        child: InkWell(
                          onTap: onAddToCart,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5), // Smaller padding
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_shopping_cart,
                                  color: Colors.white,
                                  size: 12, // Smaller icon
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Add",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11, // Smaller text
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
