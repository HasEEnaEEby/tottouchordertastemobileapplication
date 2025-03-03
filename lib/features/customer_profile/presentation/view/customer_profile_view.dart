import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tottouchordertastemobileapplication/core/config/app_colors.dart';
import 'package:tottouchordertastemobileapplication/core/config/text_styles.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/sensor_manager.dart';
import 'package:tottouchordertastemobileapplication/core/theme/theme_cubit.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_event.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view/edit_customer_profile_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view_model/customer_profile/customer_profile_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view_model/customer_profile/customer_profile_event.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view_model/customer_profile/customer_profile_state.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/widget/profile_info_card.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/widget/profile_picture_widget.dart';

class CustomerProfileView extends StatefulWidget {
  const CustomerProfileView({super.key});

  @override
  State<CustomerProfileView> createState() => _CustomerProfileViewState();
}

class _CustomerProfileViewState extends State<CustomerProfileView> {
  @override
  void initState() {
    super.initState();
    // Fetch profile data when screen loads
    context.read<CustomerProfileBloc>().add(FetchCustomerProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : AppColors.background,
      body: BlocConsumer<CustomerProfileBloc, CustomerProfileState>(
        listener: (context, state) {
          if (state is CustomerProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color.fromARGB(255, 74, 9, 9),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CustomerProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 74, 10, 10),
              ),
            );
          }

          if (state is CustomerProfileLoaded) {
            final profile = state.profile;
            return CustomScrollView(
              slivers: [
                // Enhanced Profile Header
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildProfileHeader(profile, context),
                  ),
                ),

                // Profile sections
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal Information Section
                        ProfileInfoCard(
                          title: 'Personal Information',
                          icon: Icons.person_outline,
                          items: [
                            if (profile.fullName != null)
                              ProfileInfoItem(
                                icon: Icons.person_outline,
                                title: 'Full Name',
                                value: profile.fullName!,
                              ),
                            ProfileInfoItem(
                              icon: Icons.email_outlined,
                              title: 'Email',
                              value: profile.email,
                            ),
                            if (profile.phone != null)
                              ProfileInfoItem(
                                icon: Icons.phone_outlined,
                                title: 'Phone',
                                value: profile.phone!,
                              ),
                            if (profile.address != null)
                              ProfileInfoItem(
                                icon: Icons.location_on_outlined,
                                title: 'Address',
                                value: profile.address!,
                              ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Loyalty & Rewards Section
                        const ProfileInfoCard(
                          title: 'Loyalty & Rewards',
                          icon: Icons.card_giftcard,
                          items: [
                            ProfileInfoItem(
                              icon: Icons.star_outline,
                              title: 'Loyalty Points',
                              value: '350 pts',
                              trailing: Text(
                                'Silver Member',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Payment Methods Section
                        ProfileInfoCard(
                          title: 'Payment Methods',
                          icon: Icons.payment_outlined,
                          items: [
                            ProfileInfoItem(
                              icon: Icons.add_circle_outline,
                              title: 'Add Payment Method',
                              value: '',
                              onTap: () {
                                // Add new payment method
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Favorite Restaurants Section
                        ProfileInfoCard(
                          title: 'Favorite Restaurants',
                          icon: Icons.favorite_outline,
                          items: [
                            ProfileInfoItem(
                              icon: Icons.restaurant_outlined,
                              title: 'My Favorites',
                              value: '5 Restaurants',
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, themeMode) {
                            final themeCubit = context.read<ThemeCubit>();
                            final preference = themeCubit.preference;

                            return ProfileInfoCard(
                              title: 'Display Settings',
                              icon: Icons.settings_outlined,
                              items: [
                                ProfileInfoItem(
                                  icon: _getThemeIcon(preference),
                                  title: 'Theme Mode',
                                  value: _getThemeModeName(preference),
                                  onTap: () {
                                    _showThemeSelectionDialog(
                                        context, themeCubit, preference);
                                  },
                                ),
                                // Only show the light level if auto theme is enabled
                                if (preference == ThemePreference.auto)
                                  ProfileInfoItem(
                                    icon: Icons.light_mode,
                                    title: 'Current Light Level',
                                    value:
                                        '${GetIt.instance<SensorManager>().lightSensorService.currentLux} lux',
                                  ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // Logout Button
                        ElevatedButton(
                          onPressed: () => _showLogoutDialog(),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.error,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 12),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Default or error state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load profile',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<CustomerProfileBloc>()
                        .add(FetchCustomerProfileEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // New method to build the enhanced profile header
  Widget _buildProfileHeader(dynamic profile, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 101, 4, 4),
            Color.fromARGB(255, 30, 2, 2),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(180),
          bottomRight: Radius.circular(0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture with interactive animation
              GestureDetector(
                onTap: () => _navigateToEditProfile(),
                child: Hero(
                  tag: 'profile_picture',
                  child: ProfilePictureWidget(
                    imageUrl: profile.imageUrl,
                    username: profile.username,
                    size: 120,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Profile Details with interactive elements
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated name with welcome message
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Transform.translate(
                            offset: Offset(opacity * -20, 0),
                            child: Text(
                              'Hello, ${profile.fullName ?? profile.username}!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Membership and Points with interactive badge
// Updated membership and points section
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '350 pts | Silver Member',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8), // Add some spacing
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.edit, color: Colors.white),
                              tooltip: 'Edit Profile',
                              onPressed: () => _navigateToEditProfile(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
// Quick Stats with Animated Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickStat(
                          icon: Icons.local_offer,
                          label: 'Discounts',
                          value: '3 Vouchers',
                          onTap: () {
                            // Navigate to discounts
                          },
                        ),
                        _buildQuickStat(
                          icon: Icons.restaurant,
                          label: 'Favorites',
                          value: '5 Restaurants',
                          onTap: () {
                            // Navigate to favorite restaurants
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Get appropriate icon for the theme mode
  IconData _getThemeIcon(ThemePreference preference) {
    switch (preference) {
      case ThemePreference.light:
        return Icons.light_mode;
      case ThemePreference.dark:
        return Icons.dark_mode;
      case ThemePreference.system:
        return Icons.phone_android;
      case ThemePreference.auto:
        return Icons.brightness_auto;
    }
  }

// Get descriptive name for the theme mode
  String _getThemeModeName(ThemePreference preference) {
    switch (preference) {
      case ThemePreference.light:
        return 'Light Mode';
      case ThemePreference.dark:
        return 'Dark Mode';
      case ThemePreference.system:
        return 'System Mode';
      case ThemePreference.auto:
        return 'Auto (Light Sensor)';
    }
  }

// Show theme selection dialog
  void _showThemeSelectionDialog(BuildContext context, ThemeCubit themeCubit,
      ThemePreference currentPreference) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(context, Icons.light_mode, 'Light Mode',
                  ThemePreference.light, currentPreference, themeCubit),
              _buildThemeOption(context, Icons.dark_mode, 'Dark Mode',
                  ThemePreference.dark, currentPreference, themeCubit),
              _buildThemeOption(context, Icons.phone_android, 'System Mode',
                  ThemePreference.system, currentPreference, themeCubit),
              _buildThemeOption(
                  context,
                  Icons.brightness_auto,
                  'Auto (Light Sensor)',
                  ThemePreference.auto,
                  currentPreference,
                  themeCubit),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

// Build individual theme option for the dialog
  Widget _buildThemeOption(
      BuildContext context,
      IconData icon,
      String title,
      ThemePreference preference,
      ThemePreference currentPreference,
      ThemeCubit themeCubit) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Radio<ThemePreference>(
        value: preference,
        groupValue: currentPreference,
        onChanged: (ThemePreference? value) {
          if (value != null) {
            themeCubit.setThemePreference(value);
            Navigator.of(context).pop();
          }
        },
      ),
      onTap: () {
        themeCubit.setThemePreference(preference);
        Navigator.of(context).pop();
      },
    );
  }

  // Helper method for quick stats
  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditProfile() {
    final state = context.read<CustomerProfileBloc>().state;
    if (state is CustomerProfileLoaded) {
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: context.read<CustomerProfileBloc>(),
            child: EditCustomerProfileView(profile: state.profile),
          ),
        ),
      )
          .then((_) {
        if (mounted) {
          context.read<CustomerProfileBloc>().add(FetchCustomerProfileEvent());
        }
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<LoginBloc>().add(LogoutRequested(context: context));
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
