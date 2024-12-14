import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/screens/flash_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/onboarding_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/role_selection_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/signin_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/login_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/dashboard_screen.dart'; // Add the dashboard screen here

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
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const FlashScreen());
          case '/onboarding':
            return MaterialPageRoute(
                builder: (context) => const OnboardingScreen());
          case '/role-selection':
            return MaterialPageRoute(
                builder: (context) => const RoleSelectionScreen());
          case '/signin':
            final args = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => SignInScreen(role: args ?? 'Restaurant'),
            );
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/dashboard':
            return MaterialPageRoute(
                builder: (context) => const RestaurantProfileScreen());
          default:
            return MaterialPageRoute(builder: (context) => const FlashScreen());
        }
      },
    );
  }
}
