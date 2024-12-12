import 'package:flutter/material.dart';
import 'dart:math';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Welcome to TOT',
      'description': 'Touch, Order, Taste like never before!',
      'image': 'assets/images/AppLogo.png',
    },
    {
      'title': 'Easy Ordering',
      'description': 'Seamlessly place orders from your table.',
      'image': 'assets/images/ordering.png',
    },
    {
      'title': 'Personalized Experience',
      'description': 'Tailored menus and recommendations just for you.',
      'image': 'assets/images/personalized.png',
    },
  ];

  final List<String> _foodIcons = [
    '🍔',
    '🍕',
    '🍎',
    '🍣',
    '🍩',
    '🍪',
    '🥗',
    '🍿',
    '🍤',
    '🍜'
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10), // Slower animation speed
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

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

          // Animated Food Rain
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: List.generate(_foodIcons.length, (index) {
                  final x =
                      Random().nextDouble() * MediaQuery.of(context).size.width;
                  final y = (_controller.value + index * 0.1) %
                      1.0 *
                      MediaQuery.of(context).size.height;
                  return Positioned(
                    left: x,
                    top: y,
                    child: Text(
                      _foodIcons[index],
                      style: const TextStyle(fontSize: 30),
                    ),
                  );
                }),
              );
            },
          ),

          // PageView for Onboarding Screens
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular Image
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.orange.shade100,
                    child: ClipOval(
                      child: Image.asset(
                        _onboardingData[index]['image']!,
                        fit: BoxFit.cover,
                        height: 180,
                        width: 180,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Title
                  Text(
                    _onboardingData[index]['title']!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      _onboardingData[index]['description']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Bottom Navigation with Skip and Next/Done Button
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicator Dots
                Row(
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 12,
                      width: _currentPage == index ? 24 : 12,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.orange
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),

                // Skip or Next/Done Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (_currentPage == _onboardingData.length - 1) {
                      Navigator.pushNamed(context, '/role-selection');
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    _currentPage == _onboardingData.length - 1
                        ? 'Done'
                        : 'Next',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
