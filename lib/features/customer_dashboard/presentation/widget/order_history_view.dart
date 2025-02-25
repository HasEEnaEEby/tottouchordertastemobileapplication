import 'package:flutter/material.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with real order history data when available.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // Replace with actual order count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                'Order #${1000 + index}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text('Restaurant Name'),
                  const SizedBox(height: 4),
                  Text(
                    'Delivered on April ${10 + index}, 2024',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              trailing: Text(
                '\$${25 + index}.99',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
