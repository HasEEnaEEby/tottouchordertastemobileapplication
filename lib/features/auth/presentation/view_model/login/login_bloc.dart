import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/repository/auth_repository.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/login_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view/register_view.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_event.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_state.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/sync/sync_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view/customer_dashboard_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view/restaurant_dashboard_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;
  final LoginUseCase _loginUseCase;
  final RegisterBloc _registerBloc;
  final SyncBloc _syncBloc;

  LoginBloc({
    required AuthRepository authRepository,
    required LoginUseCase loginUseCase,
    required RegisterBloc registerBloc,
    required SyncBloc syncBloc,
  })  : _authRepository = authRepository,
        _loginUseCase = loginUseCase,
        _registerBloc = registerBloc,
        _syncBloc = syncBloc,
        super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<NavigateRegisterScreenEvent>(_onNavigateRegisterScreen);
    on<CheckAuthenticationStatus>(_onCheckAuthStatus);
  }

  void _onNavigateRegisterScreen(
    NavigateRegisterScreenEvent event,
    Emitter<LoginState> emit,
  ) {
    Navigator.of(event.context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _registerBloc),
            BlocProvider.value(value: _syncBloc),
          ],
          child: const RegisterView(),
        ),
      ),
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    try {
      emit(LoginLoading());

      // Validate restaurant login requires admin code
      if (event.userType == 'restaurant' &&
          (event.adminCode == null || event.adminCode!.isEmpty)) {
        const errorMessage = 'Admin code is required for restaurant login';
        emit(const LoginError(errorMessage));
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Log detailed login attempt
      print(
          'Login Attempt - Email: ${event.email}, UserType: ${event.userType}');

      final result = await _loginUseCase(
        LoginParams(
          email: event.email,
          password: event.password,
          userType: event.userType,
          adminCode: event.userType == 'restaurant' ? event.adminCode : null,
        ),
      );

      result.fold(
        (failure) {
          // Log and handle login failure
          print('Login Failure - Message: ${failure.message}');

          final errorMessage = failure.message ?? 'Login failed';

          emit(LoginError(errorMessage));
          ScaffoldMessenger.of(event.context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        },
        (user) {
          // Comprehensive logging for successful login
          print('Login Success - User Details:');
          print('User ID: ${user.id}');
          print('Email: ${user.email}');
          print('User Type: ${user.userType}');
          print('Profile Username: ${user.profile.username}');
          print('Is Email Verified: ${user.isEmailVerified}');

          // Emit success state
          emit(LoginSuccess(user));

          // Navigate based on user type
          if (user.userType == 'customer') {
            Navigator.of(event.context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: _syncBloc),
                    BlocProvider(
                      create: (context) =>
                          GetIt.instance<CustomerDashboardBloc>()
                            ..add(LoadRestaurantsEvent())
                            ..add(LoadProfileEvent(
                                userName: user.profile.username ?? 'Customer')),
                    ),
                  ],
                  child: CustomerDashboardView(
                    userName: user.profile.username ?? 'Customer',
                  ),
                ),
              ),
            );

            // Show success message
            ScaffoldMessenger.of(event.context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (user.userType == 'restaurant') {
            Navigator.of(event.context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: _syncBloc),
                  ],
                  child: const RestaurantDashboardView(),
                ),
              ),
            );
          } else {
            // Handle unexpected user type
            print('Unexpected user type: ${user.userType}');
            emit(const LoginError('Unexpected user type'));
          }
        },
      );
    } catch (e, stackTrace) {
      // Comprehensive error handling
      print('Unexpected Login Error: $e');
      print('Stacktrace: $stackTrace');

      emit(LoginError(e.toString()));
      ScaffoldMessenger.of(event.context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
        (_) {
          emit(LoginInitial());
          Navigator.of(event.context).pushReplacementNamed('/login');
        },
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
        (failure) {
          emit(LoginInitial());
          Navigator.of(event.context).pushReplacementNamed('/login');
        },
        (user) {
          emit(LoginSuccess(user));
          if (user.userType == 'customer') {
            Navigator.of(event.context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: _syncBloc),
                  ],
                  child: CustomerDashboardView(
                    userName: user.profile.username ?? '',
                  ),
                ),
              ),
            );
          } else if (user.userType == 'restaurant') {
            Navigator.of(event.context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: _syncBloc),
                  ],
                  child: const RestaurantDashboardView(),
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      emit(LoginInitial());
      Navigator.of(event.context).pushReplacementNamed('/login');
    }
  }

  void dispose() {
    close();
  }
}
