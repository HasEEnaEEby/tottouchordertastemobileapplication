import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tottouchordertastemobileapplication/core/config/app_colors.dart';
import 'package:tottouchordertastemobileapplication/core/config/text_styles.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/motion_sensor_service.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/sensor_manager.dart';
import 'package:tottouchordertastemobileapplication/core/theme/theme_cubit.dart';
import 'package:tottouchordertastemobileapplication/core/theme/theme_helper.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_event.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_state.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/favorites/favorites_cubit.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/widget/notifications_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/widget/qr_code_scanner.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/widget/restaurants_list_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view/customer_profile_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view_model/customer_profile/customer_profile_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view_model/customer_profile/customer_profile_event.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view/order_tracking_view.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_bloc.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_event.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_state.dart';

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

  late final MotionSensorService _motionSensorService;
  late final SensorManager _sensorManager;
  bool _isSensorEnabled = false;

  int _selectedNavIndex = 0;
  bool _isDarkMode = false;
  late ThemeColors _themeColors;
  bool _showFavoritesOnly = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = context.read<CustomerDashboardBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize SensorManager
      _sensorManager = GetIt.instance<SensorManager>();

      // Initialize MotionSensorService
      _motionSensorService = GetIt.instance<MotionSensorService>();

      // Ensure sensors are started with force flag
      _sensorManager.initializeAllSensors(force: true);

      // Add shake listener with more robust logging
      _motionSensorService.addShakeListener(() {
        // Use a safer method to check if the widget is still mounted
        if (mounted) {
          print('🤚 Phone Shake Detected!');
          _onShakeDetected();

          // Attempt to play sound directly
          _motionSensorService.playShakeSound().then((_) {
            print('✅ Shake sound played successfully');
          }).catchError((error) {
            print('❌ Shake sound playback error: $error');
          });
        } else {
          print('🚫 Shake detected, but widget is not mounted');
        }
      });

      // Enable sound for shake detection
      _motionSensorService.enableSound();
      print('Sound enabled: ${_motionSensorService.isSoundEnabled}');

      // Add accelerometer listener for debugging
      _motionSensorService.addAccelerometerListener((event) {
        // print(
        //     'Accelerometer: x=${event.x.toStringAsFixed(2)}, y=${event.y.toStringAsFixed(2)}, z=${event.z.toStringAsFixed(2)}');
      });
    });

    // Initialize other data and UI
    _initializeData();
    _updateThemeMode();
  }

  void _updateThemeMode() {
    final themeCubit = context.read<ThemeCubit>();
    setState(() {
      _isDarkMode = themeCubit.state == ThemeMode.dark;
      _themeColors = ThemeHelper.fromDarkMode(_isDarkMode);
    });
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dashboardBloc.isClosed) {
        final currentState = _dashboardBloc.state;
        if (currentState is! RestaurantsLoaded &&
            currentState is! CustomerDashboardTabChanged) {
          // Check if we need to load restaurants
          _dashboardBloc.add(LoadRestaurantsEvent());
        } else {
          // If restaurants are already loaded, preserve them
          _dashboardBloc.add(PreserveRestaurantsEvent());
        }
      }
    });
  }

  void _testSoundPlayback() {
    debugPrint('🧪 Testing sound playback directly...');
    _motionSensorService.playShakeSound().then((_) {
      debugPrint('✅ Test sound playback completed');
    }).catchError((error) {
      debugPrint('❌ Test sound error: $error');
    });
  }

  Widget _buildDashboardContent(List<RestaurantEntity> restaurants) {
    return RefreshIndicator(
      onRefresh: () async {
        _dashboardBloc.add(LoadRestaurantsEvent());
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.primary,
      backgroundColor: _isDarkMode ? Colors.grey[700] : Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const RestaurantsListView(),
            _buildPromotionBanner(),
            _buildFilterOptions(),
            _buildCuisineExplorer(),
            _buildTableOrderingSection(),
            _buildPopularDishes()
          ],
        ),
      ),
    );
  }

  void _toggleMotionSensor() {
    setState(() {
      _isSensorEnabled = !_isSensorEnabled;

      if (_isSensorEnabled) {
        _motionSensorService.startListening();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Motion sensor activated. Shake to get a random restaurant!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _motionSensorService.stopListening();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Motion sensor deactivated.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  void _onShakeDetected() {
    // Check if the widget is still mounted before showing the dialog
    if (!mounted) return;

    // Get current restaurants from the bloc
    final currentState = _dashboardBloc.state;
    if (currentState is RestaurantsLoaded &&
        currentState.restaurants.isNotEmpty) {
      // Randomly select a restaurant
      final restaurants = currentState.restaurants;
      final randomRestaurant =
          restaurants[DateTime.now().millisecond % restaurants.length];

      // Show recommendation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Shake Recommendation 🍽️'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How about trying'),
              Text(
                randomRestaurant.restaurantName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Text('Located at ${randomRestaurant.location}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _themeColors = ThemeHelper.fromDarkMode(_isDarkMode);

    return BlocProvider(
        create: (context) => GetIt.instance<FavoritesCubit>(),
        child: BlocListener<ThemeCubit, ThemeMode>(
          listener: (context, themeMode) {
            _updateThemeMode();
          },
          child: Scaffold(
            backgroundColor: _themeColors.backgroundColor,
            body: SafeArea(
              child:
                  BlocConsumer<CustomerDashboardBloc, CustomerDashboardState>(
                bloc: _dashboardBloc,
                listener: (context, state) {
                  if (state is CustomerDashboardError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor:
                            _isDarkMode ? Colors.grey[700] : AppColors.error,
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
          ),
        ));
  }

  Widget _buildFilterOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            "Find Your Perfect Restaurant",
            style: AppTextStyles.h4.copyWith(
              color: _themeColors.textPrimary,
            ),
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
              _buildFilterCard(
                title: "Favorites Only",
                icon: Icons.favorite,
                options: ["Show All", "Favorites Only"],
                onTap: () {
                  setState(() {
                    _showFavoritesOnly = !_showFavoritesOnly;
                  });
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
            colors: _themeColors.filterGradient,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _themeColors.shadowColor,
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
              // Title and icon (with theme-aware colors)
              Row(
                children: [
                  Icon(
                    icon,
                    color: _isDarkMode ? Colors.white70 : Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white70 : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Option pills with theme-aware styling
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: options.take(3).map((option) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white70 : Colors.white,
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
                    color: _isDarkMode
                        ? Colors.white54
                        : Colors.white.withOpacity(0.9),
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
        color: _themeColors.headerBackground,
        boxShadow: [
          BoxShadow(
            color: _isDarkMode ? Colors.black38 : Colors.grey.withOpacity(0.05),
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
                  color: _themeColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Hungry Now? ",
                      style: AppTextStyles.h3.copyWith(
                        color: _themeColors.textPrimary,
                      ),
                    ),
                    const TextSpan(
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
                color: _themeColors.borderColor,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.white,
              radius: 24,
              child: IconButton(
                icon: Icon(
                  Icons.person_outline,
                  color: _isDarkMode ? Colors.white70 : AppColors.primary,
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
        style: AppTextStyles.inputText.copyWith(
          color: _themeColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search for food, restaurants...',
          hintStyle: AppTextStyles.inputHint.copyWith(
            color: _themeColors.searchBarHint,
          ),
          prefixIcon: Icon(Icons.search, color: _themeColors.searchBarHint),
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
          fillColor: _themeColors.searchBarBackground,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

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
                  Text(
                    "Featured Restaurants",
                    style: AppTextStyles.h4.copyWith(
                      color: _themeColors.textPrimary,
                    ),
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

  Widget _buildInstagramStylePost(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: _themeColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _themeColors.shadowColor,
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
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
                        child:
                            const Icon(Icons.restaurant, color: Colors.white),
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
                        color: _themeColors.textPrimary,
                      ),
                    ),
                    Text(
                      item['location'],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _themeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.more_vert, color: _themeColors.iconPrimary),
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
                  child: const Icon(Icons.restaurant,
                      size: 50, color: Colors.white),
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
                      icon: Icon(Icons.favorite_border,
                          size: 28, color: _themeColors.iconPrimary),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.chat_bubble_outline,
                          size: 28, color: _themeColors.iconPrimary),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.send,
                          size: 28, color: _themeColors.iconPrimary),
                      onPressed: () {},
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_border,
                      size: 28, color: _themeColors.iconPrimary),
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
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: _themeColors.textPrimary,
              ),
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
                      color: _themeColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: "  ${item['description']}",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _themeColors.textPrimary,
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
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _themeColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "2 hours ago",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _themeColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
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
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            "Explore by Cuisine",
            style: AppTextStyles.h4.copyWith(
              color: _themeColors.textPrimary,
            ),
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
          color: _themeColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _themeColors.shadowColor,
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
                      color: _themeColors.textSecondary,
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
        color: _themeColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _themeColors.shadowColor,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dining In?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _themeColors.textPrimary,
                      ),
                    ),
                    Text(
                      "Order directly from your table",
                      style: TextStyle(
                        fontSize: 14,
                        color: _themeColors.textSecondary,
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
          Text(
            "Quick Access",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _themeColors.textPrimary,
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
    final optionBgColor = _themeColors.getVariant(color);
    final borderColor = _themeColors.getBorderVariant(color);

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
                      restaurantId: restaurantId!,
                      onTableVerified: (tableId) {
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
            color: optionBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      Color.fromRGBO(color.red, color.green, color.blue, 0.2),
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
                style: TextStyle(
                  fontSize: 12,
                  color: _themeColors.textSecondary,
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
    );
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
        color: _themeColors.containerLight,
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _themeColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 11,
                      color: _themeColors.textSecondary,
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
              color: _themeColors.textSecondary,
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
              color: _themeColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "We couldn't load the restaurants. Please try again.",
            style: AppTextStyles.bodyMedium.copyWith(
              color: _themeColors.textSecondary,
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
        color: _themeColors.bottomNavBackground,
        boxShadow: [
          BoxShadow(
            color: _themeColors.shadowColor,
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: _themeColors.bottomNavBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: _themeColors.textSecondary,
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
        _navigateToOrders();
        break;

      case 3: // Notifications
        _navigateToNotifications();
        break;

      case 4: // Cart
        // _navigateToSensorTest();
        break;
    }
  }

  void _navigateToProfile() {
    final customerProfileBloc = GetIt.instance<CustomerProfileBloc>();

    customerProfileBloc.add(FetchCustomerProfileEvent());

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: customerProfileBloc,
          child: CustomerProfileView(
            onMotionSensorToggle: _toggleMotionSensor,
            isSensorEnabled: _isSensorEnabled,
          ),
        ),
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
                  Text(
                    "Most Popular Dishes",
                    style: AppTextStyles.h4.copyWith(
                      color: _themeColors.textPrimary,
                    ),
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
          color: _themeColors.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _themeColors.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    height: 150,
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
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _themeColors.textPrimary,
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

                  const SizedBox(height: 5),

                  // Preparation time and recommended tag
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: _themeColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        preparationTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: _themeColors.textSecondary,
                        ),
                      ),

                      // Show the recommended tag only if space permits
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green,
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              "Recommended",
                              style: TextStyle(
                                fontSize: 9,
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

                  const SizedBox(height: 8),

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
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _themeColors.textPrimary,
                              ),
                            ),
                            if (price.contains('.'))
                              TextSpan(
                                text: ".${price.split('.')[1]}",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _isDarkMode
                                      ? Colors.white.withOpacity(0.7)
                                      : AppColors.textPrimary.withOpacity(0.7),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Add to cart button
                      Material(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.primary,
                        child: InkWell(
                          onTap: onAddToCart,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_shopping_cart,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Add",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
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

  void _navigateToOrders() {
    final foodOrderBloc = GetIt.instance<FoodOrderBloc>();

    // First, load the orders
    foodOrderBloc.add(const FetchUserOrdersEvent());

    // Use stream to wait for orders to be loaded
    foodOrderBloc.stream
        .firstWhere((state) => state is FoodOrdersLoaded)
        .then((state) {
      if (mounted) {
        if (state is FoodOrdersLoaded && state.orders.isNotEmpty) {
          // Sort orders by date (most recent first)
          final sortedOrders = List<FoodOrderEntity>.from(state.orders)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Get the most recent order
          final mostRecentOrder = sortedOrders.first;

          // Add debug prints for order ID
          debugPrint("NavigateToOrders - Order ID: ${mostRecentOrder.id}");
          debugPrint(
              "NavigateToOrders - Order ID Length: ${mostRecentOrder.id.length}");
          debugPrint(
              "NavigateToOrders - Order Status: ${mostRecentOrder.status}");

          // Navigate to the order tracking view
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: foodOrderBloc,
                child: OrderTrackingView(orderId: mostRecentOrder.id),
              ),
            ),
          )
              .then((_) {
            // Reset selected index when returning
            if (mounted) {
              setState(() {
                _selectedNavIndex = 0;
              });
            }
          });
        } else {
          // Show a message if no orders are found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No recent orders found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();

    // Instead of directly stopping and disposing, we'll use a more controlled approach
    try {
      // Remove only the specific listener
      _motionSensorService.removeShakeListener(_onShakeDetected);
    } catch (e) {
      print('Error during motion sensor cleanup: $e');
    }

    super.dispose();
  }
}
