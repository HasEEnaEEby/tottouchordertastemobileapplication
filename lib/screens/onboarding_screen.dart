import 'package:flutter/material.dart';
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
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF7043), Color(0xFFD84315)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                    // Circular Image
                    CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.orange.shade200,
                      child: ClipOval(
                        child: Image.asset(
                          steps[index].imagePath,
                          fit: BoxFit.cover,
                          height: 180,
                          width: 180,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Title
                    Text(
                      steps[index].title,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Description
                    Text(
                      steps[index].description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            },
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
                            ? Colors.orange
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),

                // Next/Done Button
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
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _currentPage == steps.length - 1 ? 'Done' : 'Next',
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
