import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tottouchordertastemobileapplication/app/constants/api_endpoints.dart';
import 'package:tottouchordertastemobileapplication/core/auth/auth_token_manager.dart';

class AuthInterceptor extends Interceptor {
  final AuthTokenManager _tokenManager;
  final Dio _dio;

  AuthInterceptor({
    required AuthTokenManager tokenManager,
    required Dio dio,
  })  : _tokenManager = tokenManager,
        _dio = dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add token to request headers if available
    final token = _tokenManager.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint('Adding token to request: ${token.substring(0, 20)}...');
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint('Interceptor caught error: ${err.response?.statusCode}');

    // Check for unauthorized access
    if (err.response?.statusCode == 401) {
      debugPrint('Unauthorized access detected');

      try {
        // Attempt to refresh token
        final refreshToken = _tokenManager.getRefreshToken();
        if (refreshToken != null) {
          final response = await _dio.post(
            ApiEndpoints.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            // Extract new tokens from response
            final newToken = response.data['token'];
            final newRefreshToken = response.data['refreshToken'];
            final userData = _tokenManager.getUserData() ?? {};

            // Save new tokens
            await _tokenManager.saveAuthData(
              token: newToken,
              refreshToken: newRefreshToken,
              userData: userData,
            );

            // Retry the original request with new token
            return handler.resolve(
              await _dio.fetch(err.requestOptions),
            );
          }
        }
      } catch (e) {
        debugPrint('Token refresh failed: $e');
      }

      // If token refresh fails, clear auth data and redirect to login
      await _tokenManager.clearAuthData();
      return handler.reject(err);
    }

    return handler.next(err);
  }
}
