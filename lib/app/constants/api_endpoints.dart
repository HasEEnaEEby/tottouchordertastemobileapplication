class ApiEndpoints {
  ApiEndpoints._();

  // Configure timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Base URLs for different environments
  static const String baseUrl = "http://localhost:4000/api/v1/";
  // For Android Emulator
  // static const String baseUrl = "http://10.0.2.2:4000/api/v1/";

  // ====================== Auth Routes ======================
  static const String signup = "auth/signup";
  static const String login = "auth/login";
  static const String verifyEmail = "auth/verify-email/"; 
  static const String resendVerification = "auth/resend-verification";
  static const String refreshToken = "auth/refresh-token";
  static const String logout = "auth/logout";

  // Profile Management
  static const String profile = "auth/profile";
  static const String updateProfile = "auth/profile";

  // Admin Routes
  static const String adminRegister = "auth/admin/register";
  static const String adminLogin = "auth/admin/login";

  // Asset URLs
  static const String imageUrl = "http://localhost:4000/uploads/";
  // For Android Emulator
  // static const String imageUrl = "http://10.0.2.2:4000/uploads/";
  static const String uploadImage = "upload/image";
}
