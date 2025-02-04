import 'package:flutter/material.dart';

class RestaurantDashboardView extends StatelessWidget {
  const RestaurantDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDashboardCard(
              icon: Icons.restaurant_menu,
              title: 'Manage Menu',
              onTap: () {
                // TODO: Navigate to Menu Management Screen
              },
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              icon: Icons.receipt_long,
              title: 'View Orders',
              onTap: () {
                // TODO: Navigate to Orders Screen
              },
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              icon: Icons.analytics,
              title: 'Analytics & Reports',
              onTap: () {
                // TODO: Navigate to Analytics Screen
              },
            ),
            const SizedBox(height: 16),
            _buildDashboardCard(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                // TODO: Navigate to Settings Screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.orange),
              const SizedBox(width: 16),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
