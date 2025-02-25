import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tottouchordertastemobileapplication/core/auth/auth_token_manager.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/auth_entity.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/repository/auth_repository.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/login_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view/register_view.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_event.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_state.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/sync/sync_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/customer_dashboard_repository.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view/customer_dashboard_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view/restaurant_dashboard_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;
  final CustomerDashboardRepository _customerDashboardRepository;
  final LoginUseCase _loginUseCase;
  final RegisterBloc _registerBloc;
  final SyncBloc _syncBloc;
  final AuthTokenManager _tokenManager;

  LoginBloc({
    required AuthRepository authRepository,
    required CustomerDashboardRepository customerDashboardRepository,
    required LoginUseCase loginUseCase,
    required RegisterBloc registerBloc,
    required SyncBloc syncBloc,
    required AuthTokenManager tokenManager,
  })  : _authRepository = authRepository,
        _customerDashboardRepository = customerDashboardRepository,
        _loginUseCase = loginUseCase,
        _registerBloc = registerBloc,
        _syncBloc = syncBloc,
        _tokenManager = tokenManager,
        super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<NavigateRegisterScreenEvent>(_onNavigateRegisterScreen);
    on<CheckAuthenticationStatus>(_onCheckAuthStatus);
  }

  Future<void> _saveAuthData(AuthEntity user) async {
    try {
      debugPrint(
          '💾 Saving auth data with token: ${user.token?.substring(0, 20)}...');

      await _tokenManager.saveAuthData(
        token: user.token!,
        refreshToken: user.refreshToken!,
        userData: {
          'id': user.id,
          'email': user.email,
          'username': user.profile.username,
          'role': user.userType,
          'isEmailVerified': user.isEmailVerified,
        },
      );

      final storedToken = _tokenManager.getToken();
      debugPrint(
          '✅ Stored token verification: ${storedToken?.substring(0, 20)}...');

      if (storedToken == null) {
        throw Exception('❌ Token storage verification failed');
      }
    } catch (e) {
      debugPrint('❌ Error saving auth data: $e');
      throw Exception('Failed to save authentication data');
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    try {
      emit(LoginLoading());

      if (event.userType == 'restaurant' &&
          (event.adminCode?.isEmpty ?? true)) {
        emit(const LoginError('Admin code is required for restaurant login'));
        return;
      }

      debugPrint(
          '🔑 Login Attempt - Email: ${event.email}, UserType: ${event.userType}');

      final result = await _loginUseCase(
        LoginParams(
          email: event.email,
          password: event.password,
          userType: event.userType,
          adminCode: event.userType == 'restaurant' ? event.adminCode : null,
        ),
      );

      await result.fold(
        (failure) async {
          debugPrint('❌ Login Failure - ${failure.message}');
          emit(LoginError(failure.message));
        },
        (user) async {
          debugPrint('✅ Login Success - Processing user data');

          await _saveAuthData(user);

          if (!_tokenManager.hasValidToken()) {
            emit(const LoginError('Failed to store authentication data'));
            return;
          }

          if (!user.isEmailVerified) {
            emit(
                const LoginError('Please verify your email before logging in'));
            return;
          }

          if (user.isRestaurant && user.isPendingApproval) {
            emit(const LoginError(
                'Your restaurant account is pending approval'));
            return;
          }

          if (user.isRestaurant && user.isRejected) {
            emit(const LoginError('Your restaurant account has been rejected'));
            return;
          }

          emit(LoginSuccess(user));

          if (event.context.mounted) {
            await _handleSuccessfulLogin(event.context, user);
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('🆘 Unexpected Login Error: $e');
      debugPrint('Stacktrace: $stackTrace');
      emit(LoginError(e.toString()));
    }
  }

  Future<void> _handleSuccessfulLogin(
      BuildContext context, AuthEntity user) async {
    if (!context.mounted) return;

    debugPrint("✅ Login Successful: Navigating to Dashboard...");

    if (user.isCustomer) {
      // Get existing or create new CustomerDashboardBloc
      final customerDashboardBloc = context.read<CustomerDashboardBloc>();

      debugPrint("🔄 Setting up dashboard...");

      // Navigate using PageRouteBuilder for smooth transition
      await Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MultiBlocProvider(
            providers: [
              BlocProvider.value(value: customerDashboardBloc),
              BlocProvider.value(value: _syncBloc),
            ],
            child: CustomerDashboardView(
              userName: user.profile.username ?? 'Customer',
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        (route) => false,
      );
    } else if (user.isRestaurant) {
      await _navigateToRestaurantDashboard(context, user);
    }
  }

  Future<void> _navigateToRestaurantDashboard(
      BuildContext context, AuthEntity user) async {
    if (!context.mounted || user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Invalid user ID')),
      );
      return;
    }

    final result =
        await _customerDashboardRepository.getRestaurantDetails(user.id!);

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (restaurant) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: _syncBloc),
                BlocProvider.value(
                    value: GetIt.instance<CustomerDashboardBloc>()),
              ],
              child: RestaurantDashboardView(restaurant: restaurant),
            ),
          ),
          (route) => false,
        );
      },
    );
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

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<LoginState> emit) async {
    try {
      emit(LoginLoading());
      await _tokenManager.clearAuthData();
      final result = await _authRepository.logout();

      result.fold(
        (failure) => emit(LoginError(failure.message)),
        (_) {
          emit(LoginInitial());
          Navigator.of(event.context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        },
      );
    } catch (e) {
      debugPrint('❌ Logout Error: $e');
      emit(LoginError('Logout failed: ${e.toString()}'));
    }
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthenticationStatus event, Emitter<LoginState> emit) async {
    try {
      emit(LoginLoading());

      if (!_tokenManager.hasValidToken()) {
        emit(LoginInitial());
        return;
      }

      final result = await _authRepository.getCurrentUser();

      await result.fold(
        (failure) async {
          await _tokenManager.clearAuthData();
          emit(LoginInitial());
        },
        (user) async {
          emit(LoginSuccess(user));
          if (event.context.mounted) {
            await _handleSuccessfulLogin(event.context, user);
          }
        },
      );
    } catch (e) {
      debugPrint('Auth Status Check Error: $e');
      emit(LoginInitial());
    }
  }
}
