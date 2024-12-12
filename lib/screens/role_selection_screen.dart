import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tottouchordertastemobileapplication/screens/signin_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/dashboard_screen.dart'; // Assuming you have a DashboardScreen

// Convert the RoleSelectionScreen to StatefulWidget to manage hover state and interaction
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Your Role',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Choose your role to start your tasty journey!",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: roles.length,
                  itemBuilder: (context, index) {
                    final role = roles[index];
                    return _buildRoleCard(
                      context,
                      title: role['title'] as String,
                      icon: role['icon'] as IconData,
                      backgroundColor: role['color'] as Color,
                      onTap: role['action'] != null
                          ? () => (role['action'] as Function)(context)
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => role['route'] as Widget,
                                ),
                              );
                            },
                    ).animate().fadeIn(duration: (800 + index * 100).ms)
                      ..slideY(begin: -0.2);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      onEnter: (_) => _hoverAnimation(true),
      onExit: (_) => _hoverAnimation(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      spreadRadius: 3,
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: _isHovered ? 70 : 60,
                  color: Colors.deepOrangeAccent,
                ).animate().scale(duration: 600.ms),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _hoverAnimation(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }
}

final roles = [
  {
    'title': 'User',
    'icon': Icons.person_outline,
    'color': Colors.orange.shade200,
    'route': const SignInScreen(),
  },
  {
    'title': 'Restaurant',
    'icon': Icons.restaurant,
    'color': Colors.red.shade200,
    'route': const SignInScreen(),
  },
  {
    'title': 'Guest',
    'icon': Icons.fastfood_outlined,
    'color': Colors.green.shade200,
    'action': (BuildContext context) {
      _showGuestLoginPopup(context);
    },
  },
];

void _showGuestLoginPopup(BuildContext context) {
  final TextEditingController tableNumberController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Guest Login',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your table number to proceed:',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: tableNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Table Number',
                hintText: 'e.g., 101',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.orangeAccent,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.orangeAccent,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (tableNumberController.text.isNotEmpty) {
                Navigator.pop(context); // Close the dialog
                // Navigate to DashboardScreen after closing dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                );
              } else {
                // Show an error or validation message if no table number is entered
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please enter a valid table number.',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                );
              }
            },
            child: Text(
              'Proceed',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
        ],
      );
    },
  );
}
