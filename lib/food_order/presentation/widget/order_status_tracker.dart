import 'package:flutter/material.dart';

class OrderStatusTracker extends StatefulWidget {
  final String status;
  final String orderId;
  final VoidCallback onRefresh;

  const OrderStatusTracker({
    super.key,
    required this.status,
    required this.orderId,
    required this.onRefresh,
  });

  @override
  State<OrderStatusTracker> createState() => _OrderStatusTrackerState();
}

class _OrderStatusTrackerState extends State<OrderStatusTracker>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Loop the pulse animation
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
    });

    _pulseController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Order Status Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Status',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  // Order ID Display
                  Text(
                    'Order #${widget.orderId.substring(0, 6)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status Tracker
              _buildStatusTracker(),

              const SizedBox(height: 24),

              // Current Status Message
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _buildStatusMessage(),
              ),
            ],
          ),
        ),

        // Show refresh button for in-progress orders
        if (widget.status != 'completed' && widget.status != 'cancelled')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Status'),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusTracker() {
    // Define the order statuses
    final stages = [
      {'status': 'active', 'label': 'Order Placed'},
      {'status': 'preparing', 'label': 'Preparing'},
      {'status': 'ready', 'label': 'Ready'},
      {'status': 'completed', 'label': 'Completed'},
    ];

    // Calculate current step index
    int currentStepIndex = 0;
    for (int i = 0; i < stages.length; i++) {
      if (stages[i]['status'] == widget.status) {
        currentStepIndex = i;
        break;
      }
    }

    return Column(
      children: [
        Row(
          children: List.generate(stages.length * 2 - 1, (index) {
            // Even indices are circles, odd indices are lines
            if (index % 2 == 0) {
              final stageIndex = index ~/ 2;
              final stageInfo = stages[stageIndex];
              final isCurrentStage = stageInfo['status'] == widget.status;
              final isPastStage = stageIndex < currentStepIndex;

              return Expanded(
                child: _buildStatusCircle(
                  isCurrentStage,
                  isPastStage,
                  stageIndex + 1,
                  stageInfo['label'] as String,
                ),
              );
            } else {
              final lineIndex = index ~/ 2;
              final isPastLine = lineIndex < currentStepIndex;

              return Expanded(
                child: Container(
                  height: 3,
                  color: isPastLine ? Colors.green : Colors.grey[300],
                ),
              );
            }
          }),
        ),
      ],
    );
  }

  Widget _buildStatusCircle(
    bool isCurrentStep,
    bool isPastStep,
    int stepNumber,
    String label,
  ) {
    final color = isCurrentStep
        ? Colors.orange
        : isPastStep
            ? Colors.green
            : Colors.grey[300];

    Widget circle = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCurrentStep
            ? const Icon(Icons.timer, color: Colors.white)
            : isPastStep
                ? const Icon(Icons.check, color: Colors.white)
                : Text(
                    '$stepNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
      ),
    );

    // Add pulsing animation for current step
    if (isCurrentStep) {
      circle = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: circle,
      );
    }

    return Column(
      children: [
        circle,
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isCurrentStep ? FontWeight.bold : FontWeight.normal,
            color: isCurrentStep ? Colors.black : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage() {
    // Messages for each status
    final messages = {
      'active':
          'Your order has been received! The kitchen will start preparing it shortly.',
      'preparing': 'Our chefs are working their magic on your delicious food!',
      'ready':
          'Your order is ready! It will be served to your table momentarily.',
      'completed':
          'Enjoy your meal! We hope you have a wonderful dining experience.',
      'cancelled':
          'This order has been cancelled. Please contact restaurant staff if you have any questions.',
      'billing': 'Your order is complete. We are preparing your bill.',
    };

    // Icons for each status
    final icons = {
      'active': Icons.receipt_long,
      'preparing': Icons.restaurant,
      'ready': Icons.room_service,
      'completed': Icons.check_circle,
      'cancelled': Icons.cancel,
      'billing': Icons.receipt,
    };

    // Colors for each status
    final colors = {
      'active': Colors.blue,
      'preparing': Colors.orange,
      'ready': Colors.green,
      'completed': Colors.teal,
      'cancelled': Colors.red,
      'billing': Colors.purple,
    };

    return Container(
      key: ValueKey(widget.status),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors[widget.status] ?? Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icons[widget.status] ?? Icons.help_outline,
            color: colors[widget.status] ?? Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              messages[widget.status] ?? 'Order status: ${widget.status}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
