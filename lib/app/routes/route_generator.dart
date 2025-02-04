// import 'package:flutter/material.dart';
// import 'package:tottouchordertastemobileapplication/features/auth/presentation/view/login_view.dart';
// import 'package:tottouchordertastemobileapplication/features/onboarding.dart/onboarding_screen.dart';
// import 'package:tottouchordertastemobileapplication/features/splash/presentation/view/splash_view.dart';

// import 'app_routes.dart';

// class RouteGenerator {
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case AppRoutes.initial:
//       case AppRoutes.splash:
//         return MaterialPageRoute(
//           builder: (_) => const FlashScreen(),
//           settings: const RouteSettings(name: AppRoutes.splash),
//         );
//       case AppRoutes.onboarding:
//         return MaterialPageRoute(
//           builder: (_) => const OnboardingScreen(),
//           settings: const RouteSettings(name: AppRoutes.onboarding),
//         );
//       case AppRoutes.login:
//         return MaterialPageRoute(
//           builder: (_) => const LoginView(),
//           settings: const RouteSettings(name: AppRoutes.login),
//         );
//       default:
//         return _errorRoute();
//     }
//   }

//   static Route<dynamic> _errorRoute() {
//     return MaterialPageRoute(
//       builder: (_) => Scaffold(
//         appBar: AppBar(title: const Text('Error')),
//         body: const Center(child: Text('Page not found')),
//       ),
//     );
//   }
// }
