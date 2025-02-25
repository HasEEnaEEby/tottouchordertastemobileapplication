import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view/restaurant_dashboard_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_event.dart';

class RestaurantCard extends StatefulWidget {
  final RestaurantEntity restaurant;
  final VoidCallback? onTap;

  const RestaurantCard({super.key, required this.restaurant, this.onTap});

  @override
  _RestaurantCardState createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToRestaurantDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRestaurantImage(),
            _buildRestaurantDetails(),
            _buildViewMenuButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantImage() {
    final imageUrl = widget.restaurant.image ??
        'https://via.placeholder.com/400x250.png?text=No+Image';

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 180,
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 180,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.restaurant, size: 50, color: Colors.grey),
              ),
            ),
          ),
        ),

        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withAlpha(180),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Favorite Button
        Positioned(
          top: 12,
          right: 12,
          child: CircleAvatar(
            backgroundColor: Colors.white.withAlpha(200),
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantDetails() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Name
          Text(
            widget.restaurant.restaurantName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Location
          _buildDetailRow(
            icon: Icons.location_on,
            iconColor: Colors.red,
            text: widget.restaurant.location,
          ),

          // Operating Hours
          if (widget.restaurant.hours != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _buildDetailRow(
                icon: Icons.schedule,
                iconColor: Colors.blue,
                text: widget.restaurant.hours!,
              ),
            ),

          const SizedBox(height: 8),

          // Category and Pro Badge
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildCategoryBadge(),
              if (widget.restaurant.subscriptionPro) _buildProBadge(),
            ],
          ),

          const SizedBox(height: 8),

          // Restaurant Quote
          Text(
            '"${widget.restaurant.quote}"',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      {required IconData icon,
      required Color iconColor,
      required String text}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.restaurant.category ?? 'General',
        style: TextStyle(
          fontSize: 12,
          color: Colors.red.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '🌟 PRO',
        style: TextStyle(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildViewMenuButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.shade100.withAlpha(180),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: TextButton.icon(
        onPressed: () => _navigateToRestaurantDetails(context),
        icon: const Icon(Icons.restaurant_menu, color: Colors.red),
        label: const Text(
          "View Menu",
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? 'Added ${widget.restaurant.restaurantName} to favorites'
              : 'Removed ${widget.restaurant.restaurantName} from favorites',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToRestaurantDetails(BuildContext context) {
    // If custom onTap is provided, use it first
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    // Default navigation behavior
    final customerDashboardBloc =
        BlocProvider.of<CustomerDashboardBloc>(context);

    customerDashboardBloc
        .add(LoadRestaurantDetailsEvent(restaurantId: widget.restaurant.id));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: customerDashboardBloc,
          child: RestaurantDashboardView(restaurant: widget.restaurant),
        ),
      ),
    );
  }
}
