// lib/app/routes/route_generator.dart

import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view/login_view.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view/register_view.dart';
import 'package:tottouchordertastemobileapplication/screens/dashboard/customer_dashboard_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/onboarding/onboarding_screen.dart';
import 'package:tottouchordertastemobileapplication/screens/splash/flash_screen.dart';

import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.initial:
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const FlashScreen(),
        );

      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginView(), 
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) =>
              const RegisterView(), 
        );

      case AppRoutes.customerDashboard:
        final dashboardArgs = args as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CustomerDashboard(
            userName: dashboardArgs?['userName'] as String? ?? '',
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              centerTitle: true,
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Page not found',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ),
        );
    }
  }
}
