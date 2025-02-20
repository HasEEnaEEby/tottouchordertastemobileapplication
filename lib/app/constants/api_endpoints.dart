import 'dart:io';

class ApiEndpoints {
  ApiEndpoints._();

  // Configure timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Dynamically determine base URL based on platform
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:4000/api/v1"; // ✅ Android Emulator
    } else if (Platform.isIOS) {
      return "http://localhost:4000/api/v1"; // ✅ iOS Simulator
    } else {
      return "http://192.168.254.81:4000/api/v1"; // ✅ Physical Device (Use correct local IP)
    }
  }

  // ====================== Auth Routes ======================
  static String get signup => "$baseUrl/auth/signup";
  static String get login => "$baseUrl/auth/login";
  static String get verifyEmail => "$baseUrl/auth/verify-email/";
  static String get resendVerification => "$baseUrl/auth/resend-verification";
  static String get refreshToken => "$baseUrl/auth/refresh-token";
  static String get logout => "$baseUrl/auth/logout";

  // ====================== Profile Management ======================
  static String get profile => "$baseUrl/auth/profile";
  static String get updateProfile => "$baseUrl/auth/profile";

  // ====================== Admin Routes ======================
  static String get adminRegister => "$baseUrl/auth/admin/register";
  static String get adminLogin => "$baseUrl/auth/admin/login";

  // ====================== Asset URLs ======================
  static String get imageUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:4000/uploads/"; // ✅ Android Emulator
    } else if (Platform.isIOS) {
      return "http://localhost:4000/uploads/"; // ✅ iOS Simulator
    } else {
      return "http://192.168.254.81:4000/uploads/"; // ✅ Physical Device
    }
  }

  // ====================== Upload Routes ======================
  static String get uploadImage => "$baseUrl/upload/image";

  // ====================== Restaurant Routes ======================
  static String get getAllRestaurants => "$baseUrl/restaurants";
  static String get getRestaurantById => "$baseUrl/restaurants/";
  static String get updateRestaurantStatus => "$baseUrl/restaurants/status/";

  // ====================== Menu Routes ======================
  static String get getAllMenus => "$baseUrl/menus";
  static String get getMenuById => "$baseUrl/menus/";
  static String get createMenu => "$baseUrl/menus";
  static String get updateMenu => "$baseUrl/menus/";
  static String get deleteMenu => "$baseUrl/menus/";

  // ====================== Order Routes ======================
  static String get getAllOrders => "$baseUrl/orders";
  static String get getOrderById => "$baseUrl/orders/";
  static String get createOrder => "$baseUrl/orders";
  static String get updateOrderStatus => "$baseUrl/orders/status/";

  // ====================== Category Routes ======================
  static String get getAllCategories => "$baseUrl/categories";
  static String get getCategoryById => "$baseUrl/categories/";
  static String get createCategory => "$baseUrl/categories";
  static String get updateCategory => "$baseUrl/categories/";
  static String get deleteCategory => "$baseUrl/categories/";

  // ====================== Review Routes ======================
  static String get getAllReviews => "$baseUrl/reviews";
  static String get getReviewById => "$baseUrl/reviews/";
  static String get createReview => "$baseUrl/reviews";
  static String get updateReview => "$baseUrl/reviews/";
  static String get deleteReview => "$baseUrl/reviews/";

  // ====================== Dashboard Routes ======================
  static String get getDashboardStats => "$baseUrl/dashboard/stats";
  static String get getRevenueAnalytics => "$baseUrl/dashboard/revenue";
  static String get getOrderAnalytics => "$baseUrl/dashboard/orders";
}
