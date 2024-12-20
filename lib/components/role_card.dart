import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/screens/signin_screen.dart';

class RoleCard extends StatefulWidget {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final String role; // Role parameter

  const RoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.role, // Role parameter added here
  });

  @override
  _RoleCardState createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> with SingleTickerProviderStateMixin {
  bool _isFlipped = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> greetings = [
    "Hello there!",
    "Welcome!",
    "Have a great day!",
    "You're amazing!",
    "Enjoy your journey!"
  ];

  late String _greeting;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _greeting = greetings[Random().nextInt(greetings.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _flipCard() async {
    setState(() {
      _isFlipped = !_isFlipped;
    });

    if (_isFlipped) {
      await _controller.forward();
      await Future.delayed(const Duration(seconds: 2));

      // Navigating to SignInScreen and passing the role
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignInScreen(role: widget.role), // Pass role to SignInScreen
          ),
        );
      }
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi; // Rotate Y-axis
          final isFrontVisible = angle < pi / 2 || angle > 3 * pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective effect
              ..rotateY(angle),
            child: isFrontVisible ? _buildFrontCard() : _buildBackCard(),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard() {
    return Card(
      color: widget.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 50, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
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
    );
  }

  Widget _buildBackCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      child: Center(
        child: Text(
          _greeting,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: widget.color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
