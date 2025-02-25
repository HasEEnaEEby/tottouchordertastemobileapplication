import 'dart:io';

class ApiEndpoints {
  ApiEndpoints._();

  // Configure timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Base URLs
  static const String _androidBaseUrl = "http://10.0.2.2:4000/api/v1";
  static const String _iosBaseUrl = "http://localhost:4000/api/v1";
  static const String _physicalDeviceBaseUrl =
      "http://192.168.254.81:4000/api/v1";

  static const String _androidImageUrl = "http://10.0.2.2:4000/uploads/";
  static const String _iosImageUrl = "http://localhost:4000/uploads/";
  static const String _physicalDeviceImageUrl =
      "http://192.168.254.81:4000/uploads/";

  // Dynamically determine base URL based on platform
  static String get baseUrl {
    if (Platform.isAndroid) {
      return _androidBaseUrl;
    } else if (Platform.isIOS) {
      return _iosBaseUrl;
    } else {
      return _physicalDeviceBaseUrl;
    }
  }

  // Dynamic Image URL
  static String get imageUrl {
    if (Platform.isAndroid) {
      return _androidImageUrl;
    } else if (Platform.isIOS) {
      return _iosImageUrl;
    } else {
      return _physicalDeviceImageUrl;
    }
  }

  // ====================== Auth Routes ======================
  static String get signup => "$baseUrl/auth/signup";
  static String get login => "$baseUrl/auth/login";
  static String get verifyEmail => "$baseUrl/auth/verify-email";
  static String get resendVerification => "$baseUrl/auth/resend-verification";
  static String get refreshToken => "$baseUrl/auth/refresh-token";
  static String get logout => "$baseUrl/auth/logout";

  // ====================== Profile Management ======================
  static String get profile => "$baseUrl/auth/profile";
  static String get updateProfile => "$baseUrl/auth/profile";

  // ====================== Admin Routes ======================
  static String get adminRegister => "$baseUrl/auth/admin/register";
  static String get adminLogin => "$baseUrl/auth/admin/login";

  // ====================== Upload Routes ======================
  static String get uploadImage => "$baseUrl/upload/image";

  // ====================== Restaurant Routes ======================
  static const String _restaurantBase = "/restaurants";

  // Get all restaurants
  static String get getAllRestaurants => "$baseUrl$_restaurantBase";

  // Get restaurant by ID
  static String getRestaurantById(String id) => "$baseUrl$_restaurantBase/$id";

  // Get restaurant details
  static String getRestaurantDetails(String id) =>
      "$baseUrl$_restaurantBase/$id/details";

  // Update restaurant status
  static String updateRestaurantStatus(String id) =>
      "$baseUrl$_restaurantBase/$id/status";

  // Restaurant tables
  static String getRestaurantTables(String restaurantId) =>
      "$baseUrl$_restaurantBase/$restaurantId/tables";

  // Restaurant menu
  static String getRestaurantMenu(String restaurantId) =>
      "$baseUrl$_restaurantBase/$restaurantId/menu";

  // Get menu by category
  static String getRestaurantMenuByCategory(
          String restaurantId, String category) =>
      "$baseUrl$_restaurantBase/$restaurantId/menu/category/$category";

  // ====================== Menu Routes ======================
  static const String _menuBase = "/menus";
  static String get getAllMenus => "$baseUrl$_menuBase";
  static String getMenuById(String id) => "$baseUrl$_menuBase/$id";
  static String get createMenu => "$baseUrl$_menuBase";
  static String updateMenu(String id) => "$baseUrl$_menuBase/$id";
  static String deleteMenu(String id) => "$baseUrl$_menuBase/$id";

  // ====================== Order Routes ======================
  static const String _orderBase = "/orders";
  static String get getAllOrders => "$baseUrl$_orderBase";
  static String getOrderById(String id) => "$baseUrl$_orderBase/$id";
  static String get createOrder => "$baseUrl$_orderBase";
  static String updateOrderStatus(String id) =>
      "$baseUrl$_orderBase/$id/status";
  static String get getCustomerOrders => "$baseUrl/orders/customer";
  static String cancelOrder(String orderId) => "$baseUrl$_orderBase/$orderId";

  // ====================== Table Routes ======================
  static String getTableById(String tableId) => "$baseUrl/tables/$tableId";
  static String updateTableStatus(String tableId) =>
      "$baseUrl/tables/$tableId/status";

  // ====================== Category Routes ======================
  static const String _categoryBase = "/categories";
  static String get getAllCategories => "$baseUrl$_categoryBase";
  static String getCategoryById(String id) => "$baseUrl$_categoryBase/$id";
  static String get createCategory => "$baseUrl$_categoryBase";
  static String updateCategory(String id) => "$baseUrl$_categoryBase/$id";
  static String deleteCategory(String id) => "$baseUrl$_categoryBase/$id";

  // ====================== Review Routes ======================
  static const String _reviewBase = "/reviews";
  static String get getAllReviews => "$baseUrl$_reviewBase";
  static String getReviewById(String id) => "$baseUrl$_reviewBase/$id";
  static String get createReview => "$baseUrl$_reviewBase";
  static String updateReview(String id) => "$baseUrl$_reviewBase/$id";
  static String deleteReview(String id) => "$baseUrl$_reviewBase/$id";

  // ====================== Dashboard Routes ======================
  static const String _dashboardBase = "/dashboard";
  static String get getDashboardStats => "$baseUrl$_dashboardBase/stats";
  static String get getRevenueAnalytics => "$baseUrl$_dashboardBase/revenue";
  static String get getOrderAnalytics => "$baseUrl$_dashboardBase/orders";

  // ====================== Helper Methods ======================
  static String generateRoute(String basePath, [String? id]) {
    return id != null ? "$baseUrl$basePath/$id" : "$baseUrl$basePath";
  }

  static String generateRouteWithParams(
      String baseRoute, Map<String, dynamic> params) {
    final queryString = params.entries
        .map((entry) =>
            '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');
    return queryString.isNotEmpty ? '$baseRoute?$queryString' : baseRoute;
  }

  // Generate URL with multiple path segments
  static String generatePathUrl(String base, List<String> segments) {
    return [baseUrl, base, ...segments].join('/');
  }
}
