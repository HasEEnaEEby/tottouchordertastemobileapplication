import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/core/config/app_colors.dart';

class StatusChangeAnimation extends StatefulWidget {
  final String oldStatus;
  final String newStatus;
  final VoidCallback onComplete;

  const StatusChangeAnimation({
    super.key,
    required this.oldStatus,
    required this.newStatus,
    required this.onComplete,
  });

  @override
  State<StatusChangeAnimation> createState() => _StatusChangeAnimationState();
}

class _StatusChangeAnimationState extends State<StatusChangeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 70,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 60,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'active':
        return 'Order Received';
      case 'preparing':
        return 'Preparing Your Food';
      case 'ready':
        return 'Food Ready to Serve';
      case 'completed':
        return 'Order Completed';
      case 'cancelled':
        return 'Order Cancelled';
      case 'billing':
        return 'Generating Bill';
      default:
        return 'Status Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.receipt_outlined;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.check_circle_outline;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'billing':
        return Icons.receipt_long;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF3498db); // Blue
      case 'preparing':
        return const Color(0xFFf39c12); // Orange
      case 'ready':
        return const Color(0xFF2ecc71); // Green
      case 'completed':
        return const Color(0xFF27ae60); // Dark Green
      case 'cancelled':
        return const Color(0xFFe74c3c); // Red
      case 'billing':
        return const Color(0xFF9b59b6); // Purple
      default:
        return const Color(0xFF7f8c8d); // Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isShowingOldStatus = _opacityAnimation.value < 0.5;
          final status =
              isShowingOldStatus ? widget.oldStatus : widget.newStatus;
          final statusMessage = _getStatusMessage(status);
          final statusIcon = _getStatusIcon(status);
          final statusColor = _getStatusColor(status);

          return Opacity(
            opacity: isShowingOldStatus
                ? 1.0 - (_opacityAnimation.value * 2)
                : (_opacityAnimation.value - 0.5) * 2,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusIcon,
                    size: 48,
                    color: statusColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    statusMessage,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isShowingOldStatus
                        ? 'Updating status...'
                        : 'Status updated!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
