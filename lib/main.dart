import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/screens/flash_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/login_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/onboarding_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/role_dashboard/customer_dashboard_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/role_selection_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/signin_screen.dart';

class AppColors {
  static const Color lightPink = Color(0xFFF8BBD0);
  static const Color lightPurple = Color(0xFFF48FB1);
}

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
        primaryColor: AppColors.lightPink,
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
            final role =
                settings.arguments as String?; // Get role from arguments
            return MaterialPageRoute(
              builder: (context) => SignInScreen(role: role ?? 'Restaurant'),
            );
          case '/login':
            final role = settings.arguments as String?; // Get role
            return MaterialPageRoute(
                builder: (context) => LoginScreen(role: role ?? 'Customer'));
          case '/dashboard':
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null && args.containsKey('userName')) {
              final userName = args['userName'] as String;
              return MaterialPageRoute(
                builder: (context) => CustomerDashboard(
                    userName: userName), // Pass userName without context
              );
            }
            // Fallback case, if no username is provided
            return MaterialPageRoute(builder: (context) => const FlashScreen());
          default:
            return MaterialPageRoute(builder: (context) => const FlashScreen());
        }
      },
    );
  }
}
