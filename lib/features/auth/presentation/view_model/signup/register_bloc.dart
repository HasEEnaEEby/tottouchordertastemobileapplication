import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view/login_view.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_event.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_state.dart';

import '../../../domain/repository/auth_repository.dart';
import '../../../domain/use_case/register_user_usecase.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _repository;
  final RegisterUserUseCase _registerUseCase;
  final Logger _logger = Logger('RegisterBloc');

  RegisterBloc({
    required AuthRepository repository,
    required RegisterUserUseCase registerUseCase,
  })  : _repository = repository,
        _registerUseCase = registerUseCase,
        super(const RegisterInitial()) {
    on<RegisterUserTypeChanged>(_onUserTypeChanged);
    on<RegisterSubmitted>(_onSubmitted);
    on<NavigateToLoginEvent>(_onNavigateToLogin);
  }

  void _onUserTypeChanged(
    RegisterUserTypeChanged event,
    Emitter<RegisterState> emit,
  ) {
    try {
      emit(RegisterInitial(selectedUserType: event.userType));
      _logger.info('User type changed to: ${event.userType}');
    } catch (e) {
      _logger.warning('Error changing user type', e);
      emit(RegisterError(
        'Failed to change user type',
        selectedUserType: state.selectedUserType,
      ));
    }
  }

  void _onNavigateToLogin(
    NavigateToLoginEvent event,
    Emitter<RegisterState> emit,
  ) {
    Navigator.of(event.context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    try {
      // Set loading state
      emit(RegisterLoading(selectedUserType: event.userType));

      // Input validation
      final validationError = _validateInput(event);
      if (validationError != null) {
        _showErrorSnackBar(event.context, validationError);
        emit(RegisterError(
          validationError,
          selectedUserType: event.userType,
        ));
        return;
      }

      // Prepare registration parameters
      final params = RegisterParams(
        username: event.username,
        email: event.email,
        password: event.password,
        userType: event.userType,
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
      final result = await _registerUseCase(params);

      result.fold(
        (failure) {
          _logger.warning('Registration failed: ${failure.message}');
          final processedError = _processErrorMessage(failure.message);

          _showErrorSnackBar(event.context, processedError);
          emit(RegisterError(
            processedError,
            selectedUserType: event.userType,
          ));
        },
        (user) {
          // Registration successful
          _showSuccessSnackBar(event.context);
          emit(RegisterSuccess(user, selectedUserType: event.userType));

          // Navigate to login screen
          Navigator.of(event.context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginView()),
          );
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Unexpected registration error', e, stackTrace);

      const errorMessage = 'An unexpected error occurred. Please try again.';
      _showErrorSnackBar(event.context, errorMessage);
      emit(RegisterError(
        errorMessage,
        selectedUserType: event.userType,
      ));
    }
  }

  // Validate registration input
  String? _validateInput(RegisterSubmitted event) {
    if (event.password != event.confirmPassword) {
      return 'Passwords do not match';
    }

    if (!_isValidPassword(event.password)) {
      return 'Password must be at least 8 characters with letters and numbers';
    }

    if (!_isValidEmail(event.email)) {
      return 'Invalid email format';
    }

    if (event.username.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (event.userType == 'restaurant') {
      if (event.restaurantName == null || event.restaurantName!.isEmpty) {
        return 'Restaurant name is required';
      }
      if (event.location == null || event.location!.isEmpty) {
        return 'Location is required';
      }
      if (event.contactNumber == null || event.contactNumber!.isEmpty) {
        return 'Contact number is required';
      }
    }

    return null;
  }

  // Email validation helper
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Password validation helper
  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'\d')) &&
        password.contains(RegExp(r'[a-zA-Z]'));
  }

  // Process and standardize error messages
  String _processErrorMessage(String errorMessage) {
    final lowercaseError = errorMessage.toLowerCase();

    if (lowercaseError.contains('email already exists')) {
      return 'This email is already registered. Please use a different email.';
    }

    if (lowercaseError.contains('weak password')) {
      return 'Please choose a stronger password with at least 8 characters.';
    }

    if (lowercaseError.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }

    if (lowercaseError.contains('network')) {
      return 'Network error. Please check your connection and try again.';
    }

    return errorMessage;
  }

  // Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show success snackbar
  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registration successful! Please log in.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Future<void> close() {
    _logger.info('RegisterBloc closing');
    return super.close();
  }
}
