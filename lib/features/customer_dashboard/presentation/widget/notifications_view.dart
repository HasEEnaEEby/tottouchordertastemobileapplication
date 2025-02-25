import 'package:flutter/material.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              // Stub: mark all as read
              print('Mark all as read');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 5, // Replace with actual notification count
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
              child: Icon(
                Icons.notifications,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: const Text('New Offer Available'),
            subtitle: Text(
              'Get 20% off on your next order!',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: Text(
              '${index + 1}h ago',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        },
      ),
    );
  }
}
