import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/cart_item_entity.dart';

import '../../domain/entity/menu_item_entity.dart';
import '../../domain/entity/restaurant_entity.dart';
import '../view_model/customer_dashboard/customer_dashboard_bloc.dart';
import '../view_model/customer_dashboard/customer_dashboard_event.dart';
import '../view_model/customer_dashboard/customer_dashboard_state.dart';
import '../widget/cart_section.dart';

class RestaurantDashboardView extends StatefulWidget {
  final RestaurantEntity restaurant;

  const RestaurantDashboardView({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDashboardView> createState() =>
      _RestaurantDashboardViewState();
}

class _RestaurantDashboardViewState extends State<RestaurantDashboardView> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Delay the event dispatch to ensure it's not called repeatedly during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        context.read<CustomerDashboardBloc>().add(
              LoadRestaurantDetailsEvent(restaurantId: widget.restaurant.id),
            );
        _isInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use PopScope instead of WillPopScope (as WillPopScope is deprecated)
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // When popping the route, preserve restaurant data
        if (didPop && !context.read<CustomerDashboardBloc>().isClosed) {
          context.read<CustomerDashboardBloc>().add(
                PreserveRestaurantsEvent(),
              );
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: BlocBuilder<CustomerDashboardBloc, CustomerDashboardState>(
          builder: (context, state) {
            if (state is RestaurantDetailsLoading) {
              return _buildLoadingView();
            }

            if (state is RestaurantDetailsError) {
              return _buildErrorView(context, state.message);
            }

            if (state is RestaurantDetailsLoaded) {
              return _buildMainContent(context, state);
            }

            return _buildLoadingView();
          },
        ),
        floatingActionButton: _buildFAB(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? colorScheme.surface : Colors.white,
      foregroundColor: colorScheme.onSurface,
      centerTitle: false,
      leadingWidth: 40,
      title: Hero(
        tag: 'restaurant_title_${widget.restaurant.id}',
        child: Material(
          color: Colors.transparent,
          child: Text(
            widget.restaurant.restaurantName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      leading: Hero(
        tag: 'back_button_${widget.restaurant.id}',
        child: Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(
              isIOS ? Icons.arrow_back_ios_rounded : Icons.arrow_back_rounded,
              size: 22,
              color: colorScheme.onSurface,
            ),
            tooltip: 'Back to restaurants',
            onPressed: () => Navigator.pop(context),
            splashRadius: 24,
          ),
        ),
      ),
      actions: [
        // Favorites button
        IconButton(
          icon: Icon(
            Icons.favorite_border_rounded,
            color: colorScheme.onSurface,
            size: 24,
          ),
          tooltip: 'Add to favorites',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Added to favorites'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                backgroundColor: colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          splashRadius: 24,
        ),

        // Cart counter with badge
        BlocBuilder<CustomerDashboardBloc, CustomerDashboardState>(
          buildWhen: (previous, current) {
            // Only rebuild when cart items change
            if (previous is RestaurantDetailsLoaded &&
                current is RestaurantDetailsLoaded) {
              return previous.cartItems.length != current.cartItems.length;
            }
            return true;
          },
          builder: (context, state) {
            int cartItemCount = 0;
            if (state is RestaurantDetailsLoaded) {
              cartItemCount = state.cartItems.length;
            }

            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      cartItemCount > 0
                          ? Icons.shopping_cart_rounded
                          : Icons.shopping_cart_outlined,
                      key: ValueKey<bool>(cartItemCount > 0),
                      color: cartItemCount > 0
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                  tooltip: 'View cart',
                  onPressed: () => _showCart(context),
                  splashRadius: 24,
                ),
                if (cartItemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.5, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          cartItemCount > 9 ? '9+' : '$cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        // Share button
        IconButton(
          icon: Icon(
            Icons.share_rounded,
            color: colorScheme.onSurface,
            size: 24,
          ),
          tooltip: 'Share restaurant',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sharing ${widget.restaurant.restaurantName}'),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          splashRadius: 24,
        ),

        const SizedBox(width: 4),
      ],
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading restaurant details...'),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<CustomerDashboardBloc>().add(
                      LoadRestaurantDetailsEvent(
                          restaurantId: widget.restaurant.id),
                    );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, RestaurantDetailsLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildRestaurantHeader(state.restaurant),
        ),
        SliverToBoxAdapter(
          child: _buildMenuSection(state),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < state.menuItems.length) {
                  final menuItem = state.menuItems[index];
                  return _buildMenuItem(context, menuItem);
                }
                return const SizedBox.shrink();
              },
              childCount: state.menuItems.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)), // FAB space
      ],
    );
  }

  Widget _buildRestaurantHeader(RestaurantEntity restaurant) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (restaurant.image != null && restaurant.image!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                restaurant.image!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading restaurant image: $error');
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, size: 64),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Text(
            restaurant.restaurantName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  restaurant.location,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
          if (restaurant.quote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              restaurant.quote,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                restaurant.contactNumber,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          if (restaurant.hours != null && restaurant.hours!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  restaurant.hours!,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuSection(RestaurantDetailsLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Menu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${state.menuItems.length} items',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItemEntity menuItem) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMenuItemDetails(context, menuItem),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (menuItem.image != null && menuItem.image!.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    Image.network(
                      menuItem.image!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading menu item image: $error');
                        return Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant_menu, size: 48),
                        );
                      },
                    ),
                    if (!menuItem.isAvailable)
                      Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.black54,
                        child: const Center(
                          child: Text(
                            'Not Available',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${menuItem.price}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (menuItem.isVegetarian)
                        Icon(
                          Icons.eco,
                          size: 18,
                          color: Colors.green.shade700,
                        ),
                    ],
                  ),
                  if (menuItem.spicyLevel != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.whatshot,
                          size: 16,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          menuItem.spicyLevel!,
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenuItemDetails(BuildContext context, MenuItemEntity menuItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (menuItem.image != null && menuItem.image!.isNotEmpty)
                Stack(
                  children: [
                    Image.network(
                      menuItem.image!,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint(
                            'Error loading menu item detail image: $error');
                        return Container(
                          height: 250,
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant_menu, size: 64),
                        );
                      },
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            menuItem.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: menuItem.isVegetarian
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            menuItem.isVegetarian
                                ? Icons.eco
                                : Icons.restaurant,
                            color: menuItem.isVegetarian
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...[
                      Text(
                        menuItem.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${menuItem.preparationTime} mins',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (menuItem.spicyLevel != null) ...[
                          Icon(
                            Icons.whatshot,
                            size: 20,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            menuItem.spicyLevel!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${menuItem.price}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        if (menuItem.isAvailable)
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<CustomerDashboardBloc>().add(
                                    AddToCartEvent(menuItem: menuItem),
                                  );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to cart'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Add to Cart'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Not Available',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget? _buildFAB(BuildContext context) {
    return BlocBuilder<CustomerDashboardBloc, CustomerDashboardState>(
      builder: (context, state) {
        if (state is RestaurantDetailsLoaded && state.cartItems.isNotEmpty) {
          return FloatingActionButton.extended(
            onPressed: () => _showCart(context),
            backgroundColor: Colors.green,
            label: Row(
              children: [
                const Icon(Icons.shopping_cart),
                const SizedBox(width: 8),
                Text('${state.cartItems.length} items'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '₹${_calculateTotal(state.cartItems)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartSection(restaurantId: widget.restaurant.id),
    );
  }

  double _calculateTotal(List<CartItemEntity> cartItems) {
    return cartItems.fold(
      0.0,
      (total, item) => total + (item.price * item.quantity),
    );
  }
}
