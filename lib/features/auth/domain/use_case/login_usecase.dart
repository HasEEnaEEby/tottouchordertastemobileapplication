import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entity/auth_entity.dart';
import '../repository/auth_repository.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;
  final String userType;

  const LoginParams({
    required this.email,
    required this.password,
    required this.userType,
  });

  @override
  List<Object?> get props => [email, password, userType];
}

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<Either<Failure, AuthEntity>> call(LoginParams params) async {
    if (params.email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }

    if (!AuthEntity.isValidEmail(params.email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    if (params.password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
    }

    if (!AuthEntity.isValidPassword(params.password)) {
      return const Left(ValidationFailure(
        'Password must be at least 8 characters with letters and numbers',
      ));
    }

    if (params.userType.isEmpty) {
      return const Left(ValidationFailure('User type cannot be empty'));
    }

    final validUserTypes = ['customer', 'restaurant'];
    if (!validUserTypes.contains(params.userType.toLowerCase())) {
      return const Left(ValidationFailure(
        'Invalid user type. Must be either customer or restaurant',
      ));
    }

    try {
      return await repository.login(
        email: params.email.trim(),
        password: params.password,
        userType: params.userType.toLowerCase(),
      );
    } catch (e) {
      return Left(AuthFailure('Login failed: ${e.toString()}'));
    }
  }
}
