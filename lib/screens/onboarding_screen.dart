import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tottouchordertastemobileapplication/controller/onboarding_controller.dart';
import 'package:tottouchordertastemobileapplication/usecase/get_onboarding_steps_use_case.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  late final OnboardingController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController(GetOnboardingStepsUseCase());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _controller.steps;

    return Scaffold(
      body: Stack(
        children: [
          // Background with Cherry Blossoms and Updated Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF8BBD0), // Soft pink
                  Color(0xFFF48FB1), // Light lavender pink
                  Color(0xFFFFAB91), // Soft orange
                  Color(0xFFEF9A9A), // Light red-pink
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  0.1,
                  0.4,
                  0.7,
                  1.0
                ], // Adjust stops to control gradient transition
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: -50,
            child: SvgPicture.asset(
              'assets/images/cherry_blossoms.svg',
              height: 300,
              colorFilter: ColorFilter.mode(
                Colors.pinkAccent.withOpacity(0.2),
                BlendMode.srcIn,
              ),
            ),
          ),

          // PageView for Onboarding
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: steps.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular Image with Shadow
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.asset(
                            steps[index].imagePath,
                            fit: BoxFit.cover,
                            height: 180,
                            width: 180,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Title with ShipporiMincho-Bold Font
                    Text(
                      steps[index].title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'ShipporiMincho-Bold', // Apply bold font
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Description with ShipporiMincho-Regular Font
                    Text(
                      steps[index].description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily:
                            'ShipporiMincho-Regular', // Apply regular font
                        color: Color.fromARGB(255, 2, 1, 1),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Skip Button
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: () {
                // Skip directly to the last step (or complete onboarding)
                _pageController.jumpToPage(steps.length - 1);
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 83, 18, 18),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ShipporiMincho-SemiBold',
                ),
              ),
            ),
          ),

          // Bottom Navigation
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
                    steps.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 10,
                      width: _currentPage == index ? 20 : 10,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFFB71C1C)
                            : const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),

                // Next/Done Button with Minimal Glow
                ElevatedButton(
                  onPressed: () {
                    _controller.onNextPage(
                      _currentPage,
                      () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      () {
                        Navigator.pushNamed(context, '/role-selection');
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C),
                    shadowColor: Colors.redAccent,
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _currentPage == steps.length - 1 ? 'Done' : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontFamily: 'ShipporiMincho-SemiBold',
                    ),
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
