import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tottouchordertastemobileapplication/core/config/app_colors.dart';
import 'package:tottouchordertastemobileapplication/core/theme/theme_helper.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/domain/entity/food_order_entity.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view/bill_detail_view.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_bloc.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_event.dart';
import 'package:tottouchordertastemobileapplication/food_order/presentation/view_model/food_order/food_order_state.dart';

class OrderTrackingView extends StatefulWidget {
  final String orderId;

  const OrderTrackingView({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingView> createState() => _OrderTrackingViewState();
}

class _OrderTrackingViewState extends State<OrderTrackingView>
    with WidgetsBindingObserver {
  late bool _isDarkMode;
  late ThemeColors _themeColors;
  bool _isRefreshing = false;
  Timer? _refreshTimer;
  bool _initialFetchDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isDarkMode = false; // Default value
    _themeColors = ThemeHelper.fromDarkMode(_isDarkMode);

    // Debug print to check the order ID
    debugPrint("OrderTracking initialized with orderId: ${widget.orderId}");

    // Schedule initial fetch after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchOrderDetails();
        _initialFetchDone = true;
      }
    });

    // Set up periodic refresh
    _setupRefreshTimer();
  }

  void _setupRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        // Only refresh if we're not already loading
        final currentState = context.read<FoodOrderBloc>().state;
        if (currentState is! FoodOrderLoading && currentState is! BillLoading) {
          _fetchOrderDetails(showLoading: false);
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchOrderDetails();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    // Stop tracking when leaving the screen
    context.read<FoodOrderBloc>().add(
          StopTrackingOrderEvent(orderId: widget.orderId),
        );
    super.dispose();
  }

  void _updateThemeMode() {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // Only update state if the value has changed
    if (isDark != _isDarkMode) {
      setState(() {
        _isDarkMode = isDark;
        _themeColors = ThemeHelper.fromDarkMode(_isDarkMode);
      });
    }
  }

  void _fetchOrderDetails({bool showLoading = true}) {
    // Always trim the order ID to avoid whitespace issues
    final cleanOrderId = widget.orderId.trim();

    if (showLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isRefreshing = true;
          });
        }
      });
    }

    // This can be called immediately
    context.read<FoodOrderBloc>().add(
          FetchOrderDetailsEvent(orderId: cleanOrderId),
        );

    // Only show loading spinner briefly
    if (showLoading) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isRefreshing = false;
          });
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateThemeMode();
  }

  bool _orderIdMatches(String stateOrderId, String widgetOrderId) {
    // Normalize both IDs by trimming whitespace
    final normalizedStateId = stateOrderId.trim();
    final normalizedWidgetId = widgetOrderId.trim();

    debugPrint(
        "⭐ Comparing order IDs: '$normalizedStateId' vs '$normalizedWidgetId'");

    return normalizedStateId == normalizedWidgetId;
  }

  OrderEntity? _findMatchingOrder(BuildContext context, String orderId) {
    final foodOrderBloc = context.read<FoodOrderBloc>();
    final currentState = foodOrderBloc.state;

    // Case 1: Check OrderDetailsLoaded state
    if (currentState is OrderDetailsLoaded &&
        _orderIdMatches(currentState.order.id, orderId)) {
      return currentState.order;
    }

    // Case 2: Check FoodOrdersLoaded state
    if (currentState is FoodOrdersLoaded && currentState.orders.isNotEmpty) {
      // Find exact matching order using where and first
      final matchingOrders = currentState.orders
          .where((order) => _orderIdMatches(order.id, orderId))
          .toList();

      if (matchingOrders.isNotEmpty) {
        return matchingOrders.first;
      }

      // If no matching order found and there are orders, return the first one
      if (currentState.orders.isNotEmpty) {
        return currentState.orders.first;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "⭐ OrderId from widget: ${widget.orderId} (length: ${widget.orderId.length})");

    return Scaffold(
      backgroundColor: _themeColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _themeColors.headerBackground,
        foregroundColor: _themeColors.textPrimary,
        title: Text(
          'Order Tracking',
          style: TextStyle(
            color: _themeColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Order selector - only show if we have multiple orders
          BlocBuilder<FoodOrderBloc, FoodOrderState>(
            builder: (context, state) {
              if (state is FoodOrdersLoaded && state.orders.length > 1) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildOrderSelector(state.orders),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: _themeColors.iconPrimary,
            ),
            onPressed: _isRefreshing ? null : () => _fetchOrderDetails(),
          ),
        ],
      ),
      body: BlocConsumer<FoodOrderBloc, FoodOrderState>(
        listener: (context, state) {
          // Store current status before it potentially changes
          String? previousStatus;
          OrderEntity? currentOrder =
              _findMatchingOrder(context, widget.orderId);
          if (currentOrder != null) {
            previousStatus = currentOrder.status;
          }

          debugPrint("⭐ BlocConsumer - State: ${state.runtimeType}");

          if (state is FoodOrderError) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }

          // Only fetch bill if order is completed and bill is not already loaded
          if (state is OrderDetailsLoaded &&
              state.order.status.toLowerCase() == 'completed' &&
              _orderIdMatches(state.order.id, widget.orderId) &&
              mounted) {
            final currentState = context.read<FoodOrderBloc>().state;
            if (currentState is! BillLoaded && currentState is! BillLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<FoodOrderBloc>().add(
                        FetchOrderBillEvent(orderId: widget.orderId),
                      );
                }
              });
            }
          }

          // If we get a FoodOrdersLoaded state, automatically fetch the order details
          // for the current orderId if it hasn't been loaded yet
          if (state is FoodOrdersLoaded && mounted && !_initialFetchDone) {
            _initialFetchDone = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _fetchOrderDetails();
              }
            });
          }

          // Check for status changes after state update
          if (previousStatus != null) {
            OrderEntity? updatedOrder =
                _findMatchingOrder(context, widget.orderId);
            if (updatedOrder != null && previousStatus != updatedOrder.status) {
              // Status has changed - notify the user
              _handleStatusChange(updatedOrder, previousStatus);
            }
          }
        },
        builder: (context, state) {
          debugPrint("⭐ BlocBuilder - State: ${state.runtimeType}");

          // Case 1: Loading with refresh indicator
          if (state is FoodOrderLoading && _isRefreshing) {
            return _buildLoadingView();
          }

          // Case 2: Bill Loaded state with matching orderId
          if (state is BillLoaded &&
              _orderIdMatches(state.orderId, widget.orderId)) {
            debugPrint("⭐ BillLoaded state - Order ID: ${state.orderId}");

            // Try to find the order from other states
            OrderEntity? matchingOrder =
                _findMatchingOrder(context, widget.orderId);

            if (matchingOrder != null) {
              return _buildOrderTrackingView(context, matchingOrder);
            }

            // If no matching order found, try to fetch all orders
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<FoodOrderBloc>().add(const FetchUserOrdersEvent());
              }
            });

            return _buildLoadingView();
          }

          // Case 3: Direct order details loaded with matching ID
          if (state is OrderDetailsLoaded &&
              _orderIdMatches(state.order.id, widget.orderId)) {
            debugPrint(
                "⭐ OrderDetailsLoaded state - Order ID: ${state.order.id}");
            return _buildOrderTrackingView(context, state.order);
          }

          // Case 4: Check in food orders loaded state
          if (state is FoodOrdersLoaded && state.orders.isNotEmpty) {
            // Find matching order
            final matchingOrders = state.orders
                .where((order) => _orderIdMatches(order.id, widget.orderId))
                .toList();

            if (matchingOrders.isNotEmpty) {
              debugPrint("⭐ Found matching order: ${matchingOrders[0].id}");
              return _buildOrderTrackingView(context, matchingOrders[0]);
            } else {
              // No exact match, use the first order as fallback and show a notice
              debugPrint("⭐ No matching order found, using first order");
              return _buildOrderTrackingView(context, state.orders[0]);
            }
          }

          // Case 5: Bill error state
          if (state is BillError &&
              _orderIdMatches(state.orderId, widget.orderId)) {
            return _buildBillErrorView(state.message);
          }

          // Final fallback - if we haven't done initial fetch, trigger it
          if (!_initialFetchDone) {
            _initialFetchDone = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<FoodOrderBloc>().add(const FetchUserOrdersEvent());
                _fetchOrderDetails();
              }
            });
          }

          return _buildLoadingView();
        },
      ),
      bottomNavigationBar: BlocBuilder<FoodOrderBloc, FoodOrderState>(
        builder: (context, state) {
          OrderEntity? matchingOrder =
              _findMatchingOrder(context, widget.orderId);

          if (matchingOrder != null) {
            // If OrderEntity is castable to FoodOrderEntity
            if (matchingOrder is FoodOrderEntity) {
              return _buildBottomActions(
                  context, OrderDetailsLoaded(order: matchingOrder));
            } else {
              // Alternative action if they're not compatible
              return _buildSimpleBottomActions(context, matchingOrder);
            }
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAnimatedStatusStep(bool isCompleted, bool isCurrent, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green
            : (isCurrent ? AppColors.primary : Colors.grey.shade300),
        shape: BoxShape.circle,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(100),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _handleStatusChange(OrderEntity order, String previousStatus) {
    // Only show if there was an actual status change
    if (previousStatus != order.status && mounted) {
      // Status has changed - show a notification to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                _getStatusIcon(order.status),
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Status Updated',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Your order is now ${order.status.toUpperCase()}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: _getStatusColor(order.status),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'VIEW',
            textColor: Colors.white,
            onPressed: () {
              _fetchOrderDetails();
            },
          ),
        ),
      );
    }
  }

  Widget _buildSimpleBottomActions(BuildContext context, OrderEntity order) {
    // For completed orders, show simpler actions
    if (order.status.toLowerCase() == 'completed') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _themeColors.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withAlpha(26), // Use withAlpha instead of withOpacity
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () {
              // Use addPostFrameCallback to avoid setState during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<FoodOrderBloc>().add(
                        FetchOrderBillEvent(orderId: widget.orderId),
                      );
                }
              });
            },
            icon: const Icon(Icons.receipt_long),
            label: const Text('View Bill Details'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    // For cancelled orders
    if (order.status.toLowerCase() == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _themeColors.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Orders'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: _themeColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    // For active/preparing/ready orders
    String statusText = '';
    switch (order.status.toLowerCase()) {
      case 'active':
        statusText = 'Order received';
        break;
      case 'preparing':
        statusText = 'Your food is being prepared';
        break;
      case 'ready':
        statusText = 'Your order is ready';
        break;
      default:
        statusText = 'Order status: ${order.status}';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _themeColors.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Icon(
              _getStatusIcon(order.status),
              color: _getStatusColor(order.status),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                statusText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _themeColors.textPrimary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _fetchOrderDetails();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBillErrorView(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.orange, size: 64),
        const SizedBox(height: 16),
        Text(
          'Error loading bill details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _themeColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _themeColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            context.read<FoodOrderBloc>().add(
                  FetchOrderBillEvent(orderId: widget.orderId),
                );
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTrackingView(BuildContext context, OrderEntity? order) {
    if (order == null) {
      return _buildLoadingView();
    }

    final orderDateTime =
        DateFormat('MMM d, yyyy • h:mm a').format(order.createdAt);
    final estimatedDeliveryTime = _calculateEstimatedTime(order);

    return RefreshIndicator(
      onRefresh: () async {
        _fetchOrderDetails();
        // Wait for animation
        await Future.delayed(const Duration(milliseconds: 800));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and restaurant name
            _buildOrderHeader(order, orderDateTime),

            const SizedBox(height: 24),

            // Order status tracking
            _buildOrderStatusTracker(order),

            const SizedBox(height: 16),

            // Estimated time
            if (_isOrderActive(order) && estimatedDeliveryTime != null)
              _buildEstimatedTimeCard(estimatedDeliveryTime),

            // Show bill details section when order is completed
            if (order.status.toLowerCase() == 'completed')
              _buildBillSection(context),

            const SizedBox(height: 24),

            // Order summary title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _themeColors.textPrimary,
                ),
              ),
            ),

            // Order items list
            _buildOrderItemsList(order),

            const SizedBox(height: 24),

            // Help section
            _buildHelpSection(),

            // Extra padding at the bottom
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  bool _isOrderActive(OrderEntity order) {
    return order.status == 'active' ||
        order.status == 'preparing' ||
        order.status == 'ready';
  }

  Widget _buildOrderHeader(OrderEntity order, String orderDateTime) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _getRestaurantName(order),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _themeColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Table ${_getTableNumber(order)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _themeColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Order #${order.id.substring(0, 6)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _themeColors.textSecondary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.access_time,
                size: 14,
                color: _themeColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                orderDateTime,
                style: TextStyle(
                  fontSize: 13,
                  color: _themeColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusTracker(OrderEntity order) {
    // Define the status steps
    final List<String> statusSteps = [
      'active',
      'preparing',
      'ready',
      'completed'
    ];

    // Find the current status index
    final currentStatusIndex = statusSteps.indexOf(order.status.toLowerCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _themeColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
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
            children: [
              // Status indicator
              Row(
                children: List.generate(statusSteps.length, (index) {
                  // Calculate if this step is completed or current
                  final isCompleted = index < currentStatusIndex;
                  final isCurrent = index == currentStatusIndex;

                  return Expanded(
                    child: Row(
                      children: [
                        // Status circle - using animated version
                        _buildAnimatedStatusStep(isCompleted, isCurrent, index),

                        // Connector line (except for the last item)
                        if (index < statusSteps.length - 1)
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: 3,
                              color: isCompleted
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Status labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusLabel('Order\nPlaced', currentStatusIndex >= 0),
                  _buildStatusLabel('Preparing', currentStatusIndex >= 1),
                  _buildStatusLabel('Ready', currentStatusIndex >= 2),
                  _buildStatusLabel('Completed', currentStatusIndex >= 3),
                ],
              ),

              const SizedBox(height: 16),

              // Current status description
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status)
                      .withAlpha(26), // Fixed withOpacity to withAlpha
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(order.status),
                      color: _getStatusColor(order.status),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStatusTitle(order.status),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _themeColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStatusDescription(order.status),
                            style: TextStyle(
                              fontSize: 12,
                              color: _themeColors.textSecondary,
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
      ],
    );
  }

  Widget _buildStatusLabel(String label, bool isActive) {
    return SizedBox(
      width: 70,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? _themeColors.textPrimary : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.blue;
      case 'preparing':
        return Colors.orange;
      case 'ready':
        return Colors.amber;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.receipt_long;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.done_all;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Order Received';
      case 'preparing':
        return 'Food Preparation';
      case 'ready':
        return 'Ready to Serve';
      case 'completed':
        return 'Order Completed';
      case 'cancelled':
        return 'Order Cancelled';
      default:
        return 'Unknown Status';
    }
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Your order has been received and will be prepared soon.';
      case 'preparing':
        return 'The kitchen is preparing your delicious food.';
      case 'ready':
        return 'Your food is ready and will be served shortly.';
      case 'completed':
        return 'Your order has been completed. Enjoy your meal!';
      case 'cancelled':
        return 'Your order has been cancelled.';
      default:
        return 'Status information is not available.';
    }
  }

  Widget _buildEstimatedTimeCard(DateTime estimatedTime) {
    final formattedTime = DateFormat('h:mm a').format(estimatedTime);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _themeColors.containerLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _themeColors.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Time',
                  style: TextStyle(
                    fontSize: 14,
                    color: _themeColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _themeColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.notifications_active,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsList(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // List of items
          ...order.items.map((item) => _buildOrderItemRow(item)),

          const Divider(height: 24),

          // Order totals
          _buildTotalRow(
              'Subtotal',
              NumberFormat.currency(
                symbol: '₹',
                decimalDigits: 2,
              ).format(order.totalAmount)),

          const SizedBox(height: 8),

          _buildTotalRow(
              'Tax (5%)',
              NumberFormat.currency(
                symbol: '₹',
                decimalDigits: 2,
              ).format(order.totalAmount * 0.05)),

          const SizedBox(height: 8),

          _buildTotalRow(
            'Total',
            NumberFormat.currency(
              symbol: '₹',
              decimalDigits: 2,
            ).format(order.totalAmount * 1.05),
            isTotal: true,
          ),

          // Special instructions
          if (order.specialInstructions != null &&
              order.specialInstructions!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _themeColors.containerLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _themeColors.borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Special Instructions:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _themeColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.specialInstructions!,
                    style: TextStyle(
                      fontSize: 14,
                      color: _themeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItemEntity item) {
    final totalPrice = item.price * item.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _themeColors.containerLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${item.quantity}x',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _themeColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _themeColors.textPrimary,
                  ),
                ),
                if (item.specialInstructions != null &&
                    item.specialInstructions!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Note: ${item.specialInstructions}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: _themeColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(
                  symbol: '₹',
                  decimalDigits: 2,
                ).format(totalPrice),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _themeColors.textPrimary,
                ),
              ),
              Text(
                '${item.quantity} x ${NumberFormat.currency(
                  symbol: '₹',
                  decimalDigits: 2,
                ).format(item.price)}',
                style: TextStyle(
                  fontSize: 12,
                  color: _themeColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: _themeColors.textPrimary,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.primary : _themeColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBillSection(BuildContext context) {
    return BlocBuilder<FoodOrderBloc, FoodOrderState>(
      builder: (context, state) {
        if (state is BillLoading) {
          return Container(
            margin: const EdgeInsets.only(top: 24),
            child: const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Fetching bill details...'),
                ],
              ),
            ),
          );
        }

        if (state is BillLoaded &&
            _orderIdMatches(state.orderId, widget.orderId)) {
          return Container(
            margin: const EdgeInsets.only(top: 24),
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bill Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _themeColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildBillDetailRow(
                    'Subtotal', '₹${state.bill.subtotal.toStringAsFixed(2)}'),
                _buildBillDetailRow(
                    'Tax', '₹${state.bill.tax.toStringAsFixed(2)}'),
                _buildBillDetailRow('Service Charge',
                    '₹${state.bill.serviceCharge.toStringAsFixed(2)}'),
                const Divider(height: 16),
                _buildBillDetailRow(
                  'Total Amount',
                  '₹${state.bill.totalAmount.toStringAsFixed(2)}',
                  isTotal: true,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _themeColors.containerLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: state.bill.isPaid
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          state.bill.isPaid
                              ? Icons.check_circle
                              : Icons.pending,
                          color:
                              state.bill.isPaid ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Status',
                              style: TextStyle(
                                fontSize: 14,
                                color: _themeColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.bill.isPaid ? 'Paid' : 'Payment Pending',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: state.bill.isPaid
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!state.bill.isPaid)
                        ElevatedButton.icon(
                          onPressed: () {
                            // Handle pay now action
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Proceeding to payment...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.payment, size: 16),
                          label: const Text('Pay Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to full bill details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BillDetailsView(bill: state.bill),
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt),
                    label: const Text('View Full Bill'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is BillError &&
            _orderIdMatches(state.orderId, widget.orderId)) {
          return Container(
            margin: const EdgeInsets.only(top: 24),
            padding: const EdgeInsets.all(16),
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
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bill Processing',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _themeColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Your bill is being processed. Please try again in a moment.',
                  style: TextStyle(
                    color: _themeColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<FoodOrderBloc>().add(
                          FetchOrderBillEvent(orderId: widget.orderId),
                        );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Default bill processing view
        if (state is OrderDetailsLoaded && state.order.status == 'completed') {
          return Container(
            margin: const EdgeInsets.only(top: 24),
            padding: const EdgeInsets.all(16),
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
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bill Processing',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _themeColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Your bill is being prepared. It will be available shortly.',
                  style: TextStyle(
                    color: _themeColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Use addPostFrameCallback to avoid setState during build
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        context.read<FoodOrderBloc>().add(
                              FetchOrderBillEvent(orderId: widget.orderId),
                            );
                      }
                    });
                  },
                  icon: const Icon(Icons.receipt),
                  label: const Text('Fetch Bill'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

  Widget _buildBillDetailRow(String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: _themeColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primary : _themeColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _themeColors.containerLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _themeColors.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_outline,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Need Help?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _themeColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHelpOption(
            'Call Restaurant',
            Icons.call,
            () {
              _showCallConfirmation();
            },
          ),
          _buildHelpOption(
            'Report an Issue',
            Icons.report_problem_outlined,
            () {
              _showReportIssueDialog();
            },
          ),
          _buildHelpOption(
            'Contact Support',
            Icons.support_agent,
            () {
              _showSupportOptions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHelpOption(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: _themeColors.iconPrimary,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: _themeColors.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: _themeColors.iconSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, FoodOrderState state) {
    if (state is! OrderDetailsLoaded) return const SizedBox.shrink();

    final order = state.order;

    // For completed orders, show rate order and view bill buttons
    if (order.status == 'completed') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _themeColors.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showRateOrderDialog(order);
                  },
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Rate Order'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Use addPostFrameCallback to avoid setState during build
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        context.read<FoodOrderBloc>().add(
                              FetchOrderBillEvent(orderId: widget.orderId),
                            );
                      }
                    });
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('View Bill'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // For cancelled orders, show a simple button to go back
    if (order.status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _themeColors.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Orders'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: _themeColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    // For active orders, show status-specific actions
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _themeColors.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (order.status == 'active')
              ElevatedButton.icon(
                onPressed: () {
                  _showCancelOrderConfirmation();
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Order'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            if (order.status == 'ready')
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notified restaurant that you\'re ready!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('I\'m Ready'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            if (order.status == 'preparing')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.restaurant,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your food is being prepared. It will be ready soon!',
                        style: TextStyle(
                          color: _themeColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
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

  // Helper method to calculate estimated delivery time based on order status
  DateTime? _calculateEstimatedTime(OrderEntity order) {
    final now = DateTime.now();

    switch (order.status.toLowerCase()) {
      case 'active':
        // Estimate 5-10 minutes for order to be received and processed
        return now.add(const Duration(minutes: 10));
      case 'preparing':
        // Estimate 15-20 minutes for food preparation
        return now.add(const Duration(minutes: 15));
      case 'ready':
        // Estimate 5 minutes for food to be served
        return now.add(const Duration(minutes: 5));
      default:
        return null;
    }
  }

  // Helper methods to extract data from order
  String _getRestaurantName(OrderEntity order) {
    return order
        .restaurantId; // Update this to use restaurant name if available
  }

  String _getTableNumber(OrderEntity order) {
    // In a real app, you might need to fetch this from elsewhere
    return order.tableId.substring(0, 4);
  }

  Widget _buildOrderSelector(List<OrderEntity> orders) {
    // Sort orders to prioritize active orders
    final sortedOrders = [...orders];
    sortedOrders.sort((a, b) {
      // Priority: active, preparing, ready, completed, cancelled
      getPriority(OrderEntity order) {
        final status = order.status.toLowerCase();
        if (status == 'active') return 0;
        if (status == 'preparing') return 1;
        if (status == 'ready') return 2;
        if (status == 'completed') return 3;
        return 4; // cancelled or other
      }

      // First sort by status priority
      final priorityComparison = getPriority(a).compareTo(getPriority(b));
      if (priorityComparison != 0) return priorityComparison;

      // Then sort by date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    // Use the first 6 chars of order ID for display
    return DropdownButton<String>(
      value: widget.orderId.trim(),
      onChanged: (value) {
        if (value != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderTrackingView(orderId: value),
            ),
          );
        }
      },
      items: sortedOrders.map((order) {
        // Format label based on order status
        final shortId = "#${order.id.substring(0, 6)}";
        final date = DateFormat('MMM d').format(order.createdAt);
        final status = order.status.toUpperCase();
        String label = "$shortId - $status - $date";

        return DropdownMenuItem<String>(
          value: order.id.trim(),
          child: Text(
            label,
            style: TextStyle(
              color: _getStatusColor(order.status),
              fontWeight: order.status.toLowerCase() == 'active' ||
                      order.status.toLowerCase() == 'preparing' ||
                      order.status.toLowerCase() == 'ready'
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
      dropdownColor: _themeColors.cardColor,
    );
  }

  // Dialog methods
  void _showCancelOrderConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No, Keep Order'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<FoodOrderBloc>().add(
                    CancelOrderEvent(orderId: widget.orderId),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel Order'),
          ),
        ],
      ),
    );
  }

  void _showRateOrderDialog(OrderEntity order) {
    int rating = 5; // Default rating
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Rate Your Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was your experience?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  hintText: 'Share your feedback (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<FoodOrderBloc>().add(
                      RateOrderEvent(
                        orderId: order.id,
                        rating: rating,
                        feedback: feedbackController.text.isNotEmpty
                            ? feedbackController.text
                            : null,
                      ),
                    );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for your feedback!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      }),
    );
  }

  void _showCallConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Restaurant'),
        content: const Text(
          'Would you like to call the restaurant for assistance with your order?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calling restaurant...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _showReportIssueDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report an Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What issue are you experiencing?'),
            const SizedBox(height: 16),
            _buildIssueButton('Incorrect Order'),
            _buildIssueButton('Delayed Order'),
            _buildIssueButton('Food Quality Issue'),
            _buildIssueButton('Other Issue'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueButton(String issue) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reported issue: $issue'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.arrow_right, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              issue,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              'Live Chat',
              Icons.chat_bubble_outline,
              Colors.blue,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Starting live chat...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            _buildSupportOption(
              'Email Support',
              Icons.email_outlined,
              Colors.orange,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening email...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            _buildSupportOption(
              'Customer Service',
              Icons.support_agent,
              Colors.green,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Calling customer service...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }





}
