import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final TextEditingController _tableController = TextEditingController();

  void _navigateToSignIn(String role) {
    Navigator.pushNamed(context, '/signin',
        arguments: role); // Pass the role to SignInScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFE0B2),
              Color(0xFFFFCC80),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Who are you?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
              ),
            ),
            const SizedBox(height: 30),
            // Role Selection Cards
            RoleCard(
              title: 'I am a Customer',
              description: 'Order your favorite food and enjoy!',
              icon: Icons.person,
              onPressed: () {
                _navigateToSignIn('Customer'); // Pass 'Customer' role
              },
            ),
            const SizedBox(height: 20),
            RoleCard(
              title: 'I am a Restaurant',
              description: 'Manage your restaurant orders efficiently.',
              icon: Icons.restaurant_menu,
              onPressed: () {
                _navigateToSignIn('Restaurant'); // Pass 'Restaurant' role
              },
            ),
            const SizedBox(height: 20),
            RoleCard(
              title: 'I am a Guest',
              description: 'Quickly order without signing in.',
              icon: Icons.fastfood,
              onPressed: () {
                _showTableNumberDialog(); // Show table number input for guest
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the table number input dialog
  void _showTableNumberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Table Number'),
          content: TextField(
            controller: _tableController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Table Number'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                _navigateToSignIn(
                    'Guest'); // Navigate to Guest role after table input
              },
            ),
          ],
        );
      },
    );
  }
}

// Custom Card Widget
class RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;

  const RoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
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
}
