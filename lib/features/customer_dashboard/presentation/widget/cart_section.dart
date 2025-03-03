import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/cart_item_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/widget/card_item_tile.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/widget/table_grid_view.dart';

import '../view_model/customer_dashboard/customer_dashboard_bloc.dart';
import '../view_model/customer_dashboard/customer_dashboard_event.dart';
import '../view_model/customer_dashboard/customer_dashboard_state.dart';

class CartSection extends StatefulWidget {
  final String? restaurantId;

  const CartSection({super.key, this.restaurantId});

  @override
  _CartSectionState createState() => _CartSectionState();
}

class _CartSectionState extends State<CartSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("🛒 Building CartSection for Restaurant ID: ${widget.restaurantId}");

    if (widget.restaurantId == null || widget.restaurantId!.isEmpty) {
      print("🚨 Error: CartSection received an empty Restaurant ID!");
      return _buildErrorView(context, 'Cart Error',
          'Restaurant information is missing. Please restart or go back and select a restaurant.');
    }

    return BlocBuilder<CustomerDashboardBloc, CustomerDashboardState>(
      builder: (context, state) {
        // More robust state checking
        if (state is! RestaurantDetailsLoaded) {
          // If the state is not loaded, trigger loading
          context.read<CustomerDashboardBloc>().add(
              LoadRestaurantDetailsEvent(restaurantId: widget.restaurantId!));
          return _buildLoadingIndicator();
        }

        // Check if the restaurant matches
        if (state.restaurant.id != widget.restaurantId) {
          context.read<CustomerDashboardBloc>().add(
              LoadRestaurantDetailsEvent(restaurantId: widget.restaurantId!));
          return _buildLoadingIndicator();
        }

        return BlocConsumer<CustomerDashboardBloc, CustomerDashboardState>(
          listener: (context, listenerState) {
            if (listenerState is OrderPlacedSuccessfully) {
              Navigator.pop(context);
              _showSuccessSnackBar(context,
                  'Order #${listenerState.orderId} placed successfully!');
            } else if (listenerState is OrderError) {
              _showErrorSnackBar(context, listenerState.message);
            } else if (listenerState is RestaurantDetailsError) {
              _showErrorSnackBar(context, listenerState.message);
            }
          },
          builder: (context, builderState) {
            return _buildCartContent(context, state);
          },
        );
      },
    );
  }

  Widget _buildCartContent(
      BuildContext context, RestaurantDetailsLoaded state) {
    print("✅ CartSection has Restaurant ID: ${state.restaurant.id}");
    final cartItems = state.cartItems;
    final totalAmount = _calculateTotalAmount(cartItems);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          _buildTabBar(context),
          SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.4, // Constrained height
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderItemsView(context, cartItems),
                _buildTableSelectionView(context, state),
              ],
            ),
          ),
          _buildBottomBar(context, state, totalAmount),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Your Order',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Theme.of(context).primaryColor,
      tabs: const [
        Tab(text: 'Order Items'),
        Tab(text: 'Select Table'),
      ],
    );
  }

  Widget _buildOrderItemsView(
      BuildContext context, List<CartItemEntity> cartItems) {
    return cartItems.isEmpty
        ? _buildEmptyCartView()
        : ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return CartItemTile(
                item: item,
                onIncrement: () => _handleIncrement(context, item),
                onDecrement: () => _handleDecrement(context, item),
                onRemove: () => _handleRemove(context, item),
              );
            },
          );
  }

  Widget _buildEmptyCartView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Add some delicious items to get started!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSelectionView(
      BuildContext context, RestaurantDetailsLoaded state) {
    return Column(
      children: [
        // Selected table information card
        if (state.selectedTableId != null)
          _buildSelectedTableInfo(context, state),

        // Only show the table grid if no table is selected yet
        Expanded(
          child: TableGridView(
            tables: state.tables,
            selectedTableId: state.selectedTableId,
            restaurantId: state.restaurant.id,
          ),
        ),
      ],
    );
  }

// New method to display selected table information
  Widget _buildSelectedTableInfo(
      BuildContext context, RestaurantDetailsLoaded state) {
    // Find the selected table
    final selectedTable = state.tables.firstWhere(
      (table) => table.id == state.selectedTableId,
      orElse: () => TableEntity(
        id: state.selectedTableId ?? '',
        number: 0,
        capacity: 0,
        restaurantId: state.restaurant.id,
        status: 'available',
      ),
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Table ${selectedTable.number} Selected',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Your food will be ready to serve at Table ${selectedTable.number}!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              context.read<CustomerDashboardBloc>().add(
                    UnselectTableEvent(),
                  );
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Choose a different table'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, RestaurantDetailsLoaded state, double totalAmount) {
    final bool isOrderValid =
        state.cartItems.isNotEmpty && state.selectedTableId != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                isOrderValid ? () => _confirmOrder(context, state) : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: isOrderValid ? Colors.green : Colors.grey[300],
              foregroundColor: isOrderValid ? Colors.white : Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Place Order',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          SizedBox(height: 16),
          Text(
            'Loading cart details...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String title, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  void _handleIncrement(BuildContext context, CartItemEntity item) {
    context.read<CustomerDashboardBloc>().add(
          UpdateCartItemQuantityEvent(
            itemId: item.id,
            quantity: item.quantity + 1,
          ),
        );
  }

  void _handleDecrement(BuildContext context, CartItemEntity item) {
    if (item.quantity > 1) {
      context.read<CustomerDashboardBloc>().add(
            UpdateCartItemQuantityEvent(
              itemId: item.id,
              quantity: item.quantity - 1,
            ),
          );
    }
  }

  void _handleRemove(BuildContext context, CartItemEntity item) {
    context.read<CustomerDashboardBloc>().add(
          RemoveFromCartEvent(itemId: item.id),
        );
  }

  void _confirmOrder(BuildContext context, RestaurantDetailsLoaded state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: const Text('Are you sure you want to place this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CustomerDashboardBloc>().add(
                    PlaceOrderEvent(
                      restaurantId: state.restaurant.id,
                      tableId: state.selectedTableId!,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  double _calculateTotalAmount(List<CartItemEntity> cartItems) {
    return cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }
}
