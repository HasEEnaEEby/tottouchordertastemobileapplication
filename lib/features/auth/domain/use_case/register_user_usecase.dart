import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/auth_entity.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/repository/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;
  final String userType;
  final String? username;
  final String? phoneNumber;
  final Map<String, dynamic>? additionalInfo;

  RegisterParams({
    required this.email,
    required this.password,
    required this.userType,
    this.username,
    this.phoneNumber,
    this.additionalInfo,
  });
}

class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase({required this.repository});

  Future<Either<Failure, AuthEntity>> call(RegisterParams params) async {
    try {
      // Validate input
      final validationResult = _validateInput(params);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Perform registration
      return await repository.register(
        username: params.username,
        email: params.email,
        password: params.password,
        userType: params.userType,
        phoneNumber: params.phoneNumber,
        additionalInfo: params.additionalInfo,
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure? _validateInput(RegisterParams params) {
    // Email validation
    if (!_isValidEmail(params.email)) {
      return const ValidationFailure('Please enter a valid email address');
    }

    // Password validation
    if (!_isValidPassword(params.password)) {
      return const ValidationFailure(
        'Password must be at least 8 characters long and contain a mix of letters and numbers',
      );
    }

    // Username validation
    final usernameValidationResult = _validateUsername(params.username);
    if (usernameValidationResult != null) {
      return ValidationFailure(usernameValidationResult);
    }

    // Phone number validation
    final phoneValidation = _validatePhoneNumber(params.phoneNumber);
    if (phoneValidation != null) {
      return ValidationFailure(phoneValidation);
    }

    // User type validation
    if (!_isValidUserType(params.userType)) {
      return const ValidationFailure(
        'User type must be either "customer" or "restaurant"',
      );
    }

    // Additional info validation for restaurant
    if (params.userType == 'restaurant') {
      final restaurantValidation =
          _validateRestaurantInfo(params.additionalInfo);
      if (restaurantValidation != null) {
        return ValidationFailure(restaurantValidation);
      }
    }

    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    if (password.length < 8) return false;

    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    return hasLetter && hasNumber;
  }

  String? _validateUsername(String? username) {
    // Skip validation if username is null
    if (username == null) return null;

    // Check username length
    if (username.isEmpty) {
      return 'Username cannot be empty';
    }

    if (username.length < 3) {
      return 'Username must be at least 3 characters long';
    }

    if (username.length > 20) {
      return 'Username must be no more than 20 characters long';
    }

    // Check username format
    final validUsernameRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{2,19}$');
    if (!validUsernameRegex.hasMatch(username)) {
      return 'Username must start with a letter and can only contain letters, numbers, and underscores';
    }

    return null;
  }

  String? _validatePhoneNumber(String? phoneNumber) {
    // Phone number is optional
    if (phoneNumber == null || phoneNumber.isEmpty) return null;

    final phoneRegex = RegExp(r'^\+?[0-9]{10,14}$');
    if (!phoneRegex.hasMatch(phoneNumber)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  String? _validateRestaurantInfo(Map<String, dynamic>? additionalInfo) {
    if (additionalInfo == null) {
      return 'Restaurant information is required';
    }

    final restaurantName = additionalInfo['restaurantName'] as String?;
    if (restaurantName == null || restaurantName.isEmpty) {
      return 'Restaurant name is required';
    }

    final location = additionalInfo['location'] as String?;
    if (location == null || location.isEmpty) {
      return 'Restaurant location is required';
    }

    return null;
  }

  bool _isValidUserType(String userType) {
    return ['customer', 'restaurant'].contains(userType.toLowerCase());
  }
}
