import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tottouchordertastemobileapplication/core/errors/failures.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/auth_entity.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/repository/auth_repository.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase loginUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(repository: mockAuthRepository);
  });

  const tValidEmail = 'rekc697418@gmail.com';
  const tValidPassword = 'Haseenakc123';
  const tValidUserType = 'customer';
  const tAdminCode = '075614';

  final tAuthEntity = AuthEntity(
    email: tValidEmail,
    userType: tValidUserType,
    profile: UserProfile.empty(),
    metadata: AuthMetadata.empty(),
    status: AuthStatus.authenticated,
  );

  test('should return AuthEntity when login is successful for customer',
      () async {
    when(() => mockAuthRepository.login(
          email: tValidEmail,
          password: tValidPassword,
          userType: tValidUserType,
          adminCode: null,
        )).thenAnswer((_) async => Right(tAuthEntity));

    final result = await loginUseCase(const LoginParams(
      email: tValidEmail,
      password: tValidPassword,
      userType: tValidUserType,
    ));
    expect(result, Right(tAuthEntity));
    verify(() => mockAuthRepository.login(
          email: tValidEmail,
          password: tValidPassword,
          userType: tValidUserType,
          adminCode: null,
        ));
  });

  test('should return ValidationFailure when email is invalid', () async {
    final result = await loginUseCase(const LoginParams(
      email: 'invalid-email',
      password: tValidPassword,
      userType: tValidUserType,
    ));

    expect(
      result,
      equals(const Left(ValidationFailure('Invalid email format'))),
    );
    verifyNever(() => mockAuthRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
          userType: any(named: 'userType'),
          adminCode: any(named: 'adminCode'),
        ));
  });

  test('should return ValidationFailure when password is invalid', () async {
    final result = await loginUseCase(const LoginParams(
      email: tValidEmail,
      password: '123',
      userType: tValidUserType,
    ));
    expect(
      result,
      equals(const Left(ValidationFailure(
        'Password must be at least 8 characters with letters and numbers',
      ))),
    );
  });

  test('should return ValidationFailure when user type is invalid', () async {
    final result = await loginUseCase(const LoginParams(
      email: tValidEmail,
      password: tValidPassword,
      userType: 'invalid_type',
    ));

    expect(
      result,
      equals(const Left(ValidationFailure(
        'Invalid user type. Must be either customer or restaurant',
      ))),
    );
  });

  test('should return AuthEntity when login is successful for restaurant',
      () async {
    when(() => mockAuthRepository.login(
          email: tValidEmail,
          password: tValidPassword,
          userType: 'restaurant',
          adminCode: tAdminCode,
        )).thenAnswer((_) async => Right(tAuthEntity));

    final result = await loginUseCase(const LoginParams(
      email: tValidEmail,
      password: tValidPassword,
      userType: 'restaurant',
      adminCode: tAdminCode,
    ));

    expect(result, Right(tAuthEntity));
    verify(() => mockAuthRepository.login(
          email: tValidEmail,
          password: tValidPassword,
          userType: 'restaurant',
          adminCode: tAdminCode,
        ));
  });
}
