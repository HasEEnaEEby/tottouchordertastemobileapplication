import 'dart:io';

class ApiEndpoints {
  ApiEndpoints._();

  // Configure timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Base URLs - Configure these based on your setup
  static const String _androidEmulatorBaseUrl = "http://10.0.2.2:4000/api/v1";
  static const String _iosSimulatorBaseUrl = "http://localhost:4000/api/v1";
  static const String _localHostBaseUrl = "http://127.0.0.1:4000/api/v1";

  // Update this to your actual server IP when testing on physical devices
  static const String _physicalDeviceBaseUrl =
      "http://192.168.254.102:4000/api/v1";

  // Ngrok tunnel URL - update this with your current ngrok URL
  static const String _ngrokBaseUrl =
      "https://1416-2407-5200-400-53e0-b507-6cc9-ac4c-a3f0.ngrok-free.app/api/v1";

  // Image URLs
  static const String _androidEmulatorImageUrl =
      "http://10.0.2.2:4000/uploads/";
  static const String _iosSimulatorImageUrl = "http://localhost:4000/uploads/";
  static const String _localHostImageUrl = "http://127.0.0.1:4000/uploads/";
  static const String _physicalDeviceImageUrl =
      "http://192.168.254.102:4000/uploads/";
  static const String _ngrokImageUrl =
      "https://1416-2407-5200-400-53e0-b507-6cc9-ac4c-a3f0.ngrok-free.app/uploads/";
  // Flag to enable ngrok for all connections
  static const bool useNgrok = true;

  static String get baseUrl {
    // If ngrok is enabled, always use ngrok for physical devices
    if (useNgrok) {
      // Check if this is a simulator/emulator
      bool isSimulator = false;
      if (Platform.isIOS) {
        // iOS simulator detection
        try {
          final home = Platform.environment['HOME'] ?? '';
          isSimulator = home.contains('CoreSimulator');
        } catch (_) {}
      } else if (Platform.isAndroid) {
        // Android emulator detection
        try {
          final model = Platform.environment['ro.hardware.model'] ?? '';
          isSimulator = model.contains('sdk') || model.contains('emulator');
        } catch (_) {}
      }

      if (isSimulator) {
        // Use local URLs for simulators
        String url =
            Platform.isAndroid ? _androidEmulatorBaseUrl : _iosSimulatorBaseUrl;
        String deviceType =
            Platform.isAndroid ? "Android Emulator" : "iOS Simulator";
        print("🔍 Using LOCAL URL: $url on $deviceType");
        return url;
      } else {
        // Use ngrok for physical devices
        print("🔍 Using NGROK URL: $_ngrokBaseUrl for physical device");
        return _ngrokBaseUrl;
      }
    }

    // Original logic (used when ngrok is disabled)
    String url;
    String deviceType;

    if (Platform.isAndroid) {
      const bool isEmulator =
          bool.fromEnvironment('IS_EMULATOR', defaultValue: false);
      if (isEmulator) {
        url = _androidEmulatorBaseUrl;
        deviceType = "Android Emulator";
      } else {
        url = _physicalDeviceBaseUrl;
        deviceType = "Android Physical Device";
      }
    } else if (Platform.isIOS) {
      const bool isSimulator =
          bool.fromEnvironment('IS_SIMULATOR', defaultValue: false);
      if (isSimulator) {
        url = _iosSimulatorBaseUrl;
        deviceType = "iOS Simulator";
      } else {
        url = _physicalDeviceBaseUrl;
        deviceType = "iOS Physical Device";
      }
    } else {
      url = _localHostBaseUrl;
      deviceType = "Unknown Platform";
    }

    print(
        "🔍 Using BASE URL: $url on $deviceType (${Platform.operatingSystem})");
    return url;
  }

  // Dynamic Image URL determination
  static String get imageUrl {
    // If ngrok is enabled
    if (useNgrok) {
      // Check if this is a simulator/emulator
      bool isSimulator = false;
      if (Platform.isIOS) {
        try {
          final home = Platform.environment['HOME'] ?? '';
          isSimulator = home.contains('CoreSimulator');
        } catch (_) {}
      } else if (Platform.isAndroid) {
        try {
          final model = Platform.environment['ro.hardware.model'] ?? '';
          isSimulator = model.contains('sdk') || model.contains('emulator');
        } catch (_) {}
      }

      if (isSimulator) {
        return Platform.isAndroid
            ? _androidEmulatorImageUrl
            : _iosSimulatorImageUrl;
      } else {
        return _ngrokImageUrl;
      }
    }

    // Original logic
    if (Platform.isAndroid) {
      const bool isEmulator =
          bool.fromEnvironment('IS_EMULATOR', defaultValue: false);
      return isEmulator ? _androidEmulatorImageUrl : _physicalDeviceImageUrl;
    } else if (Platform.isIOS) {
      const bool isSimulator =
          bool.fromEnvironment('IS_SIMULATOR', defaultValue: false);
      return isSimulator ? _iosSimulatorImageUrl : _physicalDeviceImageUrl;
    } else {
      return _localHostImageUrl;
    }
  }

  // For testing connection during startup
  static void testConnection() {
    print("🛠 BASE URL: ${ApiEndpoints.baseUrl}");
    print("🖼 IMAGE URL: ${ApiEndpoints.imageUrl}");
  }

  // ====================== Auth Routes ======================
  static String get signup => "$baseUrl/auth/signup";
  static String get login => "$baseUrl/auth/login";
  static String get verifyEmail => "$baseUrl/auth/verify-email";
  static String get biometricLogin => "$baseUrl/auth/biometric-login";
  static String get resendVerification => "$baseUrl/auth/resend-verification";
  static String get refreshToken => "$baseUrl/auth/refresh-token";
  static String get logout => "$baseUrl/auth/logout";

  // ====================== Profile Management ======================
  static String get profile => "$baseUrl/auth/profile";
  static String get updateProfile => "$baseUrl/auth/profile";

  // ====================== Image Upload ======================
  static String get uploadProfileImage => "$baseUrl/auth/profile-image";
  static String get uploadCoverImage => "$baseUrl/auth/cover-image";

  // ====================== Admin Routes ======================
  static String get adminRegister => "$baseUrl/auth/admin/register";
  static String get adminLogin => "$baseUrl/auth/admin/login";

  // ====================== Upload Routes ======================
  static String get uploadImage => "$baseUrl/upload/image";

  // ====================== Restaurant Routes ======================
  static const String _restaurantBase = "/restaurants";
  static String get getAllRestaurants => "$baseUrl$_restaurantBase";
  static String getRestaurantById(String id) => "$baseUrl$_restaurantBase/$id";
  static String getRestaurantDetails(String id) =>
      "$baseUrl$_restaurantBase/$id/details";
  static String updateRestaurantStatus(String id) =>
      "$baseUrl$_restaurantBase/$id/status";
  static String getRestaurantTables(String restaurantId) =>
      "$baseUrl$_restaurantBase/$restaurantId/tables";
  static String getRestaurantMenu(String restaurantId) =>
      "$baseUrl$_restaurantBase/$restaurantId/menu";
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

  // ====================== Table QR code endpoints ======================
  static String validateTableQR() => "$baseUrl/restaurants/tables/validate-qr";
  static String getTableQRCode(String tableId) =>
      "$baseUrl/restaurants/tables/$tableId/qrcode";
  static String refreshTableQRCode(String tableId) =>
      "$baseUrl/restaurants/tables/$tableId/refresh-qrcode";
  static String requestTable(String tableId) =>
      "$baseUrl/restaurants/tables/$tableId/request";
  static String verifyTableForOrder(String tableId) =>
      "$baseUrl/restaurants/tables/$tableId/verify-for-order";

  // ====================== Profile Routes ======================
  static String get userProfile => "$baseUrl/auth/profile";
  static String get updateUserProfile => "$baseUrl/auth/profile";

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

  static String generatePathUrl(String base, List<String> segments) {
    return [baseUrl, base, ...segments].join('/');
  }
}
