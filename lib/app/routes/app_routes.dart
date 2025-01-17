abstract class AppRoutes {
  
  static const String initial = '/';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';

  static const String customerDashboard = '/customer/dashboard';
  static const String customerProfile = '/customer/profile';
  static const String customerOrders = '/customer/orders';
  static const String customerFavorites = '/customer/favorites';
  static const String customerSettings = '/customer/settings';

  static const String restaurantDashboard = '/restaurant/dashboard';
  static const String restaurantProfile = '/restaurant/profile';
  static const String restaurantOrders = '/restaurant/orders';
  static const String restaurantMenu = '/restaurant/menu';
  static const String restaurantSettings = '/restaurant/settings';

  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String help = '/help';
  static const String termsAndConditions = '/terms';
  static const String privacyPolicy = '/privacy';

  static const String error = '/error';
  static const String noConnection = '/no-connection';
  static const String maintenance = '/maintenance';

  static String customerNestedRoute(String route) => '/customer$route';
  static String restaurantNestedRoute(String route) => '/restaurant$route';

  static String orderDetails(String orderId) => '/orders/$orderId';
  static String menuItem(String itemId) => '/menu-items/$itemId';
  static String restaurantDetails(String restaurantId) =>
      '/restaurants/$restaurantId';
}
abstract class AuthRoutes {
  static const String base = '/auth';
  static const String login = '$base/login';
  static const String register = '$base/register';

}
abstract class CustomerRoutes {
  static const String base = '/customer';
  static const String dashboard = '$base/dashboard';

}
abstract class RestaurantRoutes {
  static const String base = '/restaurant';
  static const String dashboard = '$base/dashboard';

}
