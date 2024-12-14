import 'package:flutter/material.dart';

class RestaurantProfileScreen extends StatelessWidget {
  const RestaurantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Thakali Thali',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Stack(
              children: [
                // Background Image
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image:
                          AssetImage('assets/images/restaurant_background.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Profile Details
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Row(
                    children: [
                      // Profile Picture
                      ClipOval(
                        child: Image.asset(
                          'assets/images/profile_picture.JPG',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thakali Thali',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Authentic Nepali Cuisine',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildButton(
                      context, 'Follow', Icons.person_add_alt, Colors.orange),
                  _buildButton(context, 'Message', Icons.chat_bubble_outline,
                      Colors.blue),
                  _buildButton(context, 'Call', Icons.phone, Colors.green),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Details Section
            _buildDetailRow('Location', 'Kathmandu, Nepal', Icons.location_on),
            _buildDetailRow(
                'Specialty', 'Thakali Cuisine & Drinks', Icons.restaurant_menu),
            _buildDetailRow('Open Hours', '10 AM - 10 PM', Icons.access_time),

            const Divider(height: 30, thickness: 1),

            // About Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'About Us',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Experience the rich flavors of authentic Nepali Thakali cuisine. '
                'Enjoy our cozy ambiance, friendly staff, and delicious food.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),

            const Divider(height: 30, thickness: 1),

            // Highlights Section
            _buildHighlights(),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 10),
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Highlights',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HighlightCard(
                  label: 'Fresh Ingredients', icon: Icons.local_grocery_store),
              _HighlightCard(label: 'Takeaway', icon: Icons.shopping_bag),
              _HighlightCard(
                  label: 'Family Friendly', icon: Icons.family_restroom),
            ],
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String label;
  final IconData icon;

  const _HighlightCard({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.orange.withOpacity(0.2),
          child: Icon(icon, size: 30, color: Colors.orange),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
