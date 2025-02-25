import 'package:dartz/dartz.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/repository/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository repository;

  VerifyEmailUseCase(this.repository);

  Future<Either<Failure, bool>> call(String token) async {
    // Validate token input
    if (token.isEmpty) {
      return const Left(
          ValidationFailure('Verification token cannot be empty'));
    }

    try {
      // Delegate verification to repository
      return await repository.verifyEmail(token);
    } catch (e) {
      // Handle any unexpected errors during verification
      return Left(ServerFailure('Failed to verify email: ${e.toString()}'));
    }
  }

  // Optional method for resending verification email
  Future<Either<Failure, bool>> resendVerificationEmail(String email) async {
    // Validate email input
    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure('Invalid email address'));
    }

    try {
      // Delegate resend to repository
      return await repository.resendVerificationEmail(email);
    } catch (e) {
      return Left(ServerFailure(
          'Failed to resend verification email: ${e.toString()}'));
    }
  }

  // Email validation helper method
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
