// import 'package:flutter/material.dart';
// import 'package:tottouchordertastemobileapplication/app/routes/app_routes.dart';

// class NavigationService {
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   // Auth Navigation
//   Future<dynamic> toLogin() {
//     return replaceTo(AuthRoutes.login);
//   }

//   Future<dynamic> toRegister() {
//     return navigateTo(AuthRoutes.register);
//   }

//   Future<dynamic> toForgotPassword() {
//     return navigateTo(AppRoutes.forgotPassword);
//   }

//   // Customer Navigation
//   Future<dynamic> toCustomerDashboard({required String userName}) {
//     return replaceTo(
//       CustomerRoutes.dashboard,
//       arguments: {'userName': userName},
//     );
//   }

//   Future<dynamic> toCustomerProfile() {
//     return navigateTo(AppRoutes.customerProfile);
//   }

//   Future<dynamic> toCustomerOrders() {
//     return navigateTo(AppRoutes.customerOrders);
//   }

//   Future<dynamic> toCustomerFavorites() {
//     return navigateTo(AppRoutes.customerFavorites);
//   }

//   // Restaurant Navigation
//   Future<dynamic> toRestaurantDashboard() {
//     return replaceTo(RestaurantRoutes.dashboard);
//   }

//   Future<dynamic> toRestaurantProfile() {
//     return navigateTo(AppRoutes.restaurantProfile);
//   }

//   Future<dynamic> toRestaurantOrders() {
//     return navigateTo(AppRoutes.restaurantOrders);
//   }

//   Future<dynamic> toRestaurantMenu() {
//     return navigateTo(AppRoutes.restaurantMenu);
//   }

//   // Common Navigation
//   Future<dynamic> toOnboarding() {
//     return replaceTo(AppRoutes.onboarding);
//   }

//   Future<dynamic> toNotifications() {
//     return navigateTo(AppRoutes.notifications);
//   }

//   Future<dynamic> toSettings() {
//     return navigateTo(AppRoutes.settings);
//   }

//   Future<dynamic> toAbout() {
//     return navigateTo(AppRoutes.about);
//   }

//   Future<dynamic> toHelp() {
//     return navigateTo(AppRoutes.help);
//   }

//   Future<dynamic> toTerms() {
//     return navigateTo(AppRoutes.termsAndConditions);
//   }

//   Future<dynamic> toPrivacyPolicy() {
//     return navigateTo(AppRoutes.privacyPolicy);
//   }

//   // Dynamic Routes
//   Future<dynamic> toOrderDetails(String orderId) {
//     return navigateTo(AppRoutes.orderDetails(orderId));
//   }

//   Future<dynamic> toMenuItem(String itemId) {
//     return navigateTo(AppRoutes.menuItem(itemId));
//   }

//   Future<dynamic> toRestaurantDetails(String restaurantId) {
//     return navigateTo(AppRoutes.restaurantDetails(restaurantId));
//   }

//   // Base Navigation Methods
//   Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
//     return navigatorKey.currentState!.pushNamed(
//       routeName,
//       arguments: arguments,
//     );
//   }

//   Future<dynamic> replaceTo(String routeName, {Object? arguments}) {
//     return navigatorKey.currentState!.pushReplacementNamed(
//       routeName,
//       arguments: arguments,
//     );
//   }

//   Future<dynamic> clearStackAndNavigateTo(String routeName,
//       {Object? arguments}) {
//     return navigatorKey.currentState!.pushNamedAndRemoveUntil(
//       routeName,
//       (Route<dynamic> route) => false,
//       arguments: arguments,
//     );
//   }

//   void goBack() {
//     if (navigatorKey.currentState!.canPop()) {
//       navigatorKey.currentState!.pop();
//     }
//   }

//   void goBackToRoot() {
//     navigatorKey.currentState!.popUntil((route) => route.isFirst);
//   }

//   void goBackUntil(String routeName) {
//     navigatorKey.currentState!.popUntil(
//       (route) => route.settings.name == routeName,
//     );
//   }

//   bool canGoBack() {
//     return navigatorKey.currentState!.canPop();
//   }
// }
