import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:tottouchordertastemobileapplication/app/services/navigation_service.dart';
import 'package:tottouchordertastemobileapplication/app/services/sync_service.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/sync_hive_model.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/auth_entity.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/repository/auth_repository.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/register_user_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_event.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository repository;
  final RegisterUserUseCase _registerUseCase;
  final NavigationService _navigationService;
  final SyncService _syncService;
  final Logger _logger = Logger('RegisterBloc');

  RegisterBloc({
    required this.repository,
    required RegisterUserUseCase useCase,
    required NavigationService navigationService,
    required SyncService syncService,
  })  : _registerUseCase = useCase,
        _navigationService = navigationService,
        _syncService = syncService,
        super(const RegisterInitial()) {
    on<RegisterUserTypeChanged>(_onUserTypeChanged);
    on<RegisterSubmitted>(_onSubmitted);
  }

  void _onUserTypeChanged(
    RegisterUserTypeChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(RegisterInitial(selectedUserType: event.userType));
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading(selectedUserType: event.userType));

    // Comprehensive input validation
    final validationError = _validateRegistrationInput(event);
    if (validationError != null) {
      emit(RegisterError(
        validationError,
        selectedUserType: event.userType,
      ));
      return;
    }

    try {
      // Prepare registration params
      final registrationParams = RegisterParams(
        email: event.email,
        password: event.password,
        userType: event.userType,
        username: event.username,
        phoneNumber: event.contactNumber,
        additionalInfo: event.userType == 'restaurant'
            ? {
                'restaurantName': event.restaurantName ?? '',
                'location': event.location ?? '',
                'quote': event.quote ?? '',
              }
            : null,
      );

      // Attempt registration
      final result = await _registerUseCase.call(registrationParams);

      // Handle registration result
      await result.fold(
        // Handle registration failure
        (failure) async {
          _logger.warning('Registration failed: ${failure.message}');
          emit(RegisterError(
            _processErrorMessage(failure.message),
            selectedUserType: event.userType,
          ));
        },
        // Handle successful registration
        (user) async {
          try {
            // Queue sync for the new user
            await _queueUserSync(user, event);

            // Emit success state
            emit(RegisterSuccess(
              user,
              selectedUserType: event.userType,
            ));

            // Optional: Navigate after registration
            _navigateAfterRegistration(event.userType);
          } catch (syncError) {
            _logger.warning('User sync error after registration', syncError);
            // Emit success state even if sync fails
            emit(RegisterSuccess(
              user,
              selectedUserType: event.userType,
            ));
          }
        },
      );
    } catch (unexpectedError) {
      _logger.severe('Unexpected registration error', unexpectedError);
      emit(RegisterError(
        _processErrorMessage(unexpectedError.toString()),
        selectedUserType: event.userType,
      ));
    }
  }

  // Comprehensive input validation
  String? _validateRegistrationInput(RegisterSubmitted event) {
    // Password matching
    if (event.password != event.confirmPassword) {
      return 'Passwords do not match';
    }

    // Password strength
    if (!AuthEntity.isValidPassword(event.password)) {
      return 'Password must be at least 8 characters with letters and numbers';
    }

    // Email validation
    if (!AuthEntity.isValidEmail(event.email)) {
      return 'Invalid email format';
    }

    // Username validation
    if ((event.username).length < 3) {
      return 'Username must be at least 3 characters long';
    }

    // Additional validations based on user type
    if (event.userType == 'restaurant') {
      if ((event.restaurantName ?? '').isEmpty) {
        return 'Restaurant name is required';
      }
      if ((event.location ?? '').isEmpty) {
        return 'Restaurant location is required';
      }
    }

    return null;
  }

  // Queue user sync after registration
  Future<void> _queueUserSync(dynamic user, RegisterSubmitted event) async {
    await _syncService.queueSync(
      id: user.id ?? _generateTempId(),
      data: _prepareSyncData(user, event),
      entityType: event.userType,
      operation: SyncOperation.create,
    );
  }

  // Prepare sync data with robust fallback
  Map<String, dynamic> _prepareSyncData(dynamic user, RegisterSubmitted event) {
    return {
      'id': user.id ?? _generateTempId(),
      'email': user.email ?? event.email,
      'username': user.username ?? event.username,
      'userType': event.userType,
      if (event.userType == 'restaurant') ...{
        'restaurantName': event.restaurantName ?? '',
        'location': event.location ?? '',
        'quote': event.quote ?? '',
      }
    };
  }

  // Navigate after successful registration
  void _navigateAfterRegistration(String userType) {
    try {
      _navigationService.navigateTo(userType == 'restaurant'
          ? '/restaurant-onboarding'
          : '/email-verification');
    } catch (navError) {
      _logger.warning('Navigation error after registration', navError);
    }
  }

  // Error message processing
  String _processErrorMessage(String errorMessage) {
    final lowercaseError = errorMessage.toLowerCase();

    if (lowercaseError.contains('email already exists')) {
      return 'This email is already registered. Please login or use a different email.';
    }

    if (lowercaseError.contains('weak password')) {
      return 'The password is too weak. Please choose a stronger password.';
    }

    return errorMessage;
  }

  // Generate a temporary ID if none is provided
  String _generateTempId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Future<void> close() {
    _logger.info('RegisterBloc closing');
    return super.close();
  }
}
