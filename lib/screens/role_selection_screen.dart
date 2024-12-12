import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tottouchordertastemobileapplication/screens/signin_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/dashboard_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Your Role',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 4,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                "Choose your role to start your journey!",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.orangeAccent,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: roles.map((role) {
                    return _buildRoleCard(context, role);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, Map<String, dynamic> role) {
    return GestureDetector(
      onTap: () {
        if (role['action'] != null) {
          role['action'](context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => role['route'] as Widget),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: role['color'],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 4,
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.deepOrangeAccent.withOpacity(0.1),
              child: Icon(
                role['icon'],
                size: 40,
                color: Colors.deepOrangeAccent,
              ),
            ).animate().scale(duration: 400.ms),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                role['title'],
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.deepOrangeAccent,
            ),
          ],
        ),
      ),
    );
  }
}

final roles = [
  {
    'title': 'Customer',
    'icon': Icons.person_outline,
    'color': Colors.orange.shade100,
    'route': const SignInScreen(),
  },
  {
    'title': 'Restaurant',
    'icon': Icons.restaurant_menu,
    'color': Colors.red.shade100,
    'route': const SignInScreen(),
  },
  {
    'title': 'Guest',
    'icon': Icons.fastfood_outlined,
    'color': Colors.green.shade100,
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
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.orangeAccent,
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
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DashboardScreen()),
                );
              } else {
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
