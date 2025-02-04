class ApiEndpoints {
  ApiEndpoints._();

  // Configure timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Determine base URL based on platform
  static String get baseUrl {
    // Add platform-specific logic if needed
    return "http://localhost:4000/api/v1/";
    // For Android Emulator: return "http://10.0.2.2:4000/api/v1/";
  }

  // ====================== Auth Routes ======================
  static String get signup => "${baseUrl}auth/signup";
  static String get login => "${baseUrl}auth/login";
  static String get verifyEmail => "${baseUrl}auth/verify-email/";
  static String get resendVerification => "${baseUrl}auth/resend-verification";
  static String get refreshToken => "${baseUrl}auth/refresh-token";
  static String get logout => "${baseUrl}auth/logout";

  // Profile Management
  static String get profile => "${baseUrl}auth/profile";
  static String get updateProfile => "${baseUrl}auth/profile";

  // Admin Routes
  static String get adminRegister => "${baseUrl}auth/admin/register";
  static String get adminLogin => "${baseUrl}auth/admin/login";

  // Asset URLs
  static String get imageUrl {
    return "http://localhost:4000/uploads/";
    // For Android Emulator: return "http://10.0.2.2:4000/uploads/";
  }

  static String get uploadImage => "${baseUrl}upload/image";
}
