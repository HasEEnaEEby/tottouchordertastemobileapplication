import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/screens/flash_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/onboarding_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/role_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOT Restaurant Ordering',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Initial route points to FlashScreen
      initialRoute: '/',
      routes: {
        '/': (context) => const FlashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/role-selection': (context) => RoleSelectionScreen(),
      },
    );
  }
}
