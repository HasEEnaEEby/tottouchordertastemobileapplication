import 'package:flutter/material.dart';

// Role Selection Screen
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  // Controller for PageView
  final PageController _pageController = PageController(viewportFraction: 0.8);

  // Current Page Index
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.pink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Main Content
          Column(
            children: [
              const SizedBox(height: 80),

              // Header Title
              const Text(
                "Who Are You Today?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Subtitle
              const Text(
                "Swipe to choose your role",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Role Swiper
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final role = roles[index];
                    return AnimatedScale(
                      scale: _currentPage == index ? 1.0 : 0.9,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: HoverableRoleCard(
                        title: role.title,
                        description: role.description,
                        color: role.color,
                        icon: role.icon,
                        onTap: () {
                          // Navigate to SignInScreen with role argument
                          Navigator.pushNamed(
                            context,
                            '/signin',
                            arguments: role.title,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // Page Indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    roles.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white70,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // Footer Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: Colors.orangeAccent,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Back",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Role Card with Hover Effect
class HoverableRoleCard extends StatefulWidget {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const HoverableRoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  State<HoverableRoleCard> createState() => _HoverableRoleCardState();
}

class _HoverableRoleCardState extends State<HoverableRoleCard>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
          _controller.forward();
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
          _controller.reverse();
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          color: widget.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: isHovered ? 10 : 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Icon Rotation
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _controller.value * 2 * 3.1416,
                      child: Icon(
                        widget.icon,
                        size: 50,
                        color: Colors.white,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Role Data Model
class Role {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final String route;

  Role({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.route,
  });
}

// Role List
final List<Role> roles = [
  Role(
    title: "Customer",
    description: "Browse menus, place orders, and enjoy!",
    color: Colors.green,
    icon: Icons.fastfood,
    route: '/customer-home',
  ),
  Role(
    title: "Staff",
    description: "Manage orders and assist customers!",
    color: Colors.blue,
    icon: Icons.work,
    route: '/staff-dashboard',
  ),
  Role(
    title: "Admin",
    description: "Oversee operations and reports!",
    color: Colors.red,
    icon: Icons.admin_panel_settings,
    route: '/admin-panel',
  ),
  Role(
    title: "Guest",
    description: "Explore the app without an account!",
    color: Colors.orange,
    icon: Icons.person_outline,
    route: '/guest-mode',
  ),
];
