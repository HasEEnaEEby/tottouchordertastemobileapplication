import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/app/services/navigation_service.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/auth_entity.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/repository/auth_repository.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/login_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_event.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc(
      {required AuthRepository authRepository,
      required LoginUseCase useCase,
      required NavigationService navigationService})
      : _authRepository = authRepository,
        super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthenticationStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    if (!AuthEntity.isValidEmail(event.email)) {
      emit(const LoginError('Invalid email format'));
      return;
    }

    try {
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
        userType: event.userType,
      );

      result.fold(
        (failure) => emit(LoginError(failure.message)),
        (user) => emit(LoginSuccess(user)),
      );
    } catch (e) {
      emit(LoginError('Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      final result = await _authRepository.logout();

      result.fold(
        (failure) => emit(LoginError(failure.message)),
        (_) => emit(LoginInitial()),
      );
    } catch (e) {
      emit(LoginError('Logout failed: ${e.toString()}'));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthenticationStatus event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      final result = await _authRepository.getCurrentUser();

      result.fold(
        (failure) => emit(LoginInitial()),
        (user) => emit(LoginSuccess(user)),
      );
    } catch (e) {
      emit(LoginInitial());
    }
  }
}
