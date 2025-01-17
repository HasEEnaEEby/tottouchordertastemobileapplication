import 'package:flutter/material.dart';

class CustomerDashboard extends StatefulWidget {
  final String userName;

  const CustomerDashboard({super.key, required this.userName});

  @override
  // ignore: library_private_types_in_public_api
  _CustomerDashboardState createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.8);
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildWelcomeSection(),
            const SizedBox(height: 16),
            _buildNavigationMenu(),
            const SizedBox(height: 16),
            _buildFeaturedRestaurants(),
            const SizedBox(height: 16),
            _buildSpecialPromotions(),
            const SizedBox(height: 16),
            _buildFavoriteRestaurants(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipOval(
          child: Image.asset(
            'assets/images/AppLogo.png',
            fit: BoxFit.contain,
            height: 50,
          ),
        ),
      ),
      title: const Text(
        'TOT Taste Order Touch',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontFamily: 'NotoSans',
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 244, 169, 40),
      centerTitle: true,
      elevation: 0.0,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Welcome to TOT, ${widget.userName}!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'NotoSans',
          ),
        ),
        const Row(
          children: [
            Icon(Icons.star, color: Colors.orange),
            Text(
              '100',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  // Navigation Menu
  Widget _buildNavigationMenu() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildNavigationItem(Icons.restaurant, 'Browse Restaurants', () {
            _navigateToPage(const BrowseRestaurantsPage());
          }),
          _buildNavigationItem(Icons.card_giftcard, 'My Rewards', () {
            _navigateToPage(const MyRewardsPage());
          }),
          _buildNavigationItem(Icons.credit_card, 'My Rewards Card', () {
            _navigateToPage(const MyRewardsCardPage());
          }),
        ],
      ),
    );
  }

  // Helper function for navigation
  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  // Featured Restaurants Section
  Widget _buildFeaturedRestaurants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured Restaurants',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: PageView(
            controller: _pageController,
            children: [
              _buildRestaurantCard("Nepali Restaurant"),
              _buildRestaurantCard("Pizza Hut"),
              _buildRestaurantCard("Tandoori Spice"),
              _buildRestaurantCard("Sushi Express"),
              _buildRestaurantCard("Vegan Bites"),
            ],
          ),
        ),
      ],
    );
  }

  // Special Promotions Section with Moving Banner
  Widget _buildSpecialPromotions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Special Promotions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < 5; i++)
                _buildPromoCard("20% Off", Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteRestaurants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Favorite Restaurants',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey, width: 1),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
          },
          children: [
            _buildTableRow('Nepali Restaurant', [
              'Momo',
              'Dal Bhat',
              'Sel Roti',
            ]),
            _buildTableRow('Pizza Hut', [
              'Margherita Pizza',
              'Cheese Burst Pizza',
            ]),
            _buildTableRow('Tandoori Spice', [
              'Chicken Tandoori',
              'Butter Chicken',
            ]),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(String restaurantName, List<String> foodItems) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            restaurantName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: foodItems.map((foodItem) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '- $foodItem',
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
        ),
      ],
      onTap: (index) {},
    );
  }

  // Navigation Item
  Widget _buildNavigationItem(IconData icon, String label, Function() onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.black),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // Restaurant Card
  Widget _buildRestaurantCard(String restaurantName) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: NetworkImage(
                  'https://images.pexels.com/photos/941861/pexels-photo-941861.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Text(
              restaurantName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Promotion Card
  Widget _buildPromoCard(String promoText, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          promoText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: const Center(child: Text("Search Results")),
    );
  }
}

class BrowseRestaurantsPage extends StatelessWidget {
  const BrowseRestaurantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Browse Restaurants",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: const Center(
        child: Text(
          "Browse Restaurants",
          style: TextStyle(
            fontSize: 18,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}

class MyRewardsPage extends StatelessWidget {
  const MyRewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Rewards",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          "My Rewards",
          style: TextStyle(
            fontSize: 18,
            color: Colors.purple,
          ),
        ),
      ),
    );
  }
}

class MyRewardsCardPage extends StatelessWidget {
  const MyRewardsCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Rewards Card",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          "My Rewards Card",
          style: TextStyle(
            fontSize: 18,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
