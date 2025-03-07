import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/auth_entity.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/repository/auth_repository.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/register_user_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUserUseCase registerUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerUseCase = RegisterUserUseCase(repository: mockAuthRepository);
  });

  group('RegisterUserUseCase', () {
    const tValidEmail = 'rekc697418@gmail.com';
    const tValidPassword = 'Haseenakc123';
    const tValidUsername = 'haseena';
    const tValidPhoneNumber = '075614';
    const tValidUserType = 'customer';

    final tAuthEntity = AuthEntity(
      email: tValidEmail,
      userType: tValidUserType,
      profile: const UserProfile(
        username: tValidUsername,
        phoneNumber: tValidPhoneNumber,
      ),
      metadata: AuthMetadata.empty(),
      status: AuthStatus.authenticated,
    );

    test('should return ValidationFailure for invalid email', () async {
      final result = await registerUseCase(RegisterParams(
        email: 'invalid-email',
        password: tValidPassword,
        userType: tValidUserType,
        username: tValidUsername,
      ));

      expect(
        result,
        equals(const Left(
            ValidationFailure('Please enter a valid email address'))),
      );
      verifyNever(() => mockAuthRepository.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            userType: any(named: 'userType'),
            username: any(named: 'username'),
            phoneNumber: any(named: 'phoneNumber'),
            additionalInfo: any(named: 'additionalInfo'),
          ));
    });

    test('should return ValidationFailure for invalid restaurant info',
        () async {
      final result = await registerUseCase(RegisterParams(
        email: tValidEmail,
        password: tValidPassword,
        userType: 'restaurant',
        username: tValidUsername,
        additionalInfo: {},
      ));

      expect(
        result,
        equals(const Left(ValidationFailure('Restaurant name is required'))),
      );
    });

    test('should return ValidationFailure for invalid username format',
        () async {
      final result = await registerUseCase(RegisterParams(
        email: tValidEmail,
        password: tValidPassword,
        userType: tValidUserType,
        username: '12invalid',
      ));

      expect(
        result,
        equals(const Left(ValidationFailure(
          'Username must start with a letter and can only contain letters, numbers, and underscores',
        ))),
      );
    });

    test('should return ServerFailure when repository throws', () async {
      when(() => mockAuthRepository.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            userType: any(named: 'userType'),
            username: any(named: 'username'),
            phoneNumber: any(named: 'phoneNumber'),
            additionalInfo: any(named: 'additionalInfo'),
          )).thenThrow(Exception('Server error'));

      final result = await registerUseCase(RegisterParams(
        email: tValidEmail,
        password: tValidPassword,
        userType: tValidUserType,
        username: tValidUsername,
      ));

      expect(
        result,
        equals(const Left(ServerFailure('Exception: Server error'))),
      );
    });
  });
}
