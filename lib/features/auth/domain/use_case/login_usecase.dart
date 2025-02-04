import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entity/auth_entity.dart';
import '../repository/auth_repository.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;
  final String userType;
  final String? adminCode;

  const LoginParams({
    required this.email,
    required this.password,
    required this.userType,
    this.adminCode,
  });

  @override
  List<Object?> get props => [email, password, userType, adminCode];
}

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<Either<Failure, AuthEntity>> call(LoginParams params) async {
    // Validate email
    if (params.email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }

    if (!AuthEntity.isValidEmail(params.email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    // Validate password
    if (params.password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
    }

    if (!AuthEntity.isValidPassword(params.password)) {
      return const Left(ValidationFailure(
        'Password must be at least 8 characters with letters and numbers',
      ));
    }

    // Validate user type
    if (params.userType.isEmpty) {
      return const Left(ValidationFailure('User type cannot be empty'));
    }

    final validUserTypes = ['customer', 'restaurant'];
    if (!validUserTypes.contains(params.userType.toLowerCase())) {
      return const Left(ValidationFailure(
        'Invalid user type. Must be either customer or restaurant',
      ));
    }

    // Validate admin code if user type is restaurant
    if (params.userType.toLowerCase() == 'restaurant' &&
        (params.adminCode == null || params.adminCode!.isEmpty)) {
      return const Left(
          ValidationFailure('Admin code is required for restaurant login'));
    }

    try {
      return await repository.login(
        email: params.email.trim(),
        password: params.password,
        userType: params.userType.toLowerCase(),
        adminCode: params.adminCode
        
      );
    } catch (e) {
      return Left(AuthFailure('Login failed: ${e.toString()}'));
    }
  }
}
