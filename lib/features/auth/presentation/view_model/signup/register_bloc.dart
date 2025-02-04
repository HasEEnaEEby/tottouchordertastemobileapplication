import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:tottouchordertastemobileapplication/app/services/sync_service.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/sync_hive_model.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/auth_entity.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/repository/auth_repository.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/register_user_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view/login_view.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_event.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_state.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/sync/sync_bloc.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _repository;
  final RegisterUserUseCase _registerUseCase;
  final SyncService _syncService;
  final SyncBloc _syncBloc;
  final Logger _logger = Logger('RegisterBloc');

  RegisterBloc({
    required AuthRepository repository,
    required RegisterUserUseCase registerUseCase,
    required SyncService syncService,
    required SyncBloc syncBloc,
  })  : _repository = repository,
        _registerUseCase = registerUseCase,
        _syncService = syncService,
        _syncBloc = syncBloc,
        super(const RegisterInitial()) {
    // Register event handlers
    on<RegisterUserTypeChanged>(_onUserTypeChanged);
    on<RegisterSubmitted>(_onSubmitted);
    on<NavigateToLoginEvent>(_onNavigateToLogin);
  }

  // Handle user type change event
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

  // Handle navigation to login page
  void _onNavigateToLogin(
    NavigateToLoginEvent event,
    Emitter<RegisterState> emit,
  ) {
    Navigator.of(event.context).push(
      MaterialPageRoute(
        builder: (context) => const LoginView(),
      ),
    );
  }

  // Handle registration submission
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
        emit(RegisterError(
          validationError,
          selectedUserType: event.userType,
        ));
        ScaffoldMessenger.of(event.context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check for existing email
      try {
        final emailExists = await _repository.checkEmailExists(event.email);
        if (emailExists == true) {
          emit(RegisterError(
            'This email is already registered. Please use a different email.',
            selectedUserType: event.userType,
          ));
          ScaffoldMessenger.of(event.context).showSnackBar(
            const SnackBar(
              content: Text(
                  'This email is already registered. Please use a different email.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } catch (e) {
        _logger.warning('Error checking email existence', e);
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

      await result.fold(
        (failure) async {
          _logger.warning('Registration failed: ${failure.message}');
          final processedError = _processErrorMessage(failure.message);

          emit(RegisterError(
            processedError,
            selectedUserType: event.userType,
          ));

          ScaffoldMessenger.of(event.context).showSnackBar(
            SnackBar(
              content: Text(processedError),
              backgroundColor: Colors.red,
            ),
          );
        },
        (user) async {
          try {
            // Queue sync operation
            await _queueUserSync(user, event);

            // Trigger sync
            _syncBloc.add(StartSync());

            // Emit success state
            emit(RegisterSuccess(user, selectedUserType: event.userType));

            // Show success snackbar
            ScaffoldMessenger.of(event.context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful! Please log in.'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to login screen
            Navigator.of(event.context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const LoginView(),
              ),
            );
          } catch (syncError) {
            _logger.warning('Sync error after registration', syncError);

            // Still emit success even if sync fails
            emit(RegisterSuccess(user, selectedUserType: event.userType));

            // Navigate to login screen
            Navigator.of(event.context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const LoginView(),
              ),
            );
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Unexpected registration error', e, stackTrace);

      // Show unexpected error snackbar
      ScaffoldMessenger.of(event.context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );

      emit(RegisterError(
        'An unexpected error occurred. Please try again.',
        selectedUserType: event.userType,
      ));
    }
  }

  // Validate registration input
  String? _validateInput(RegisterSubmitted event) {
    if (event.password != event.confirmPassword) {
      return 'Passwords do not match';
    }

    if (!AuthEntity.isValidPassword(event.password)) {
      return 'Password must be at least 8 characters with letters and numbers';
    }

    if (!AuthEntity.isValidEmail(event.email)) {
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

  // Queue user sync after registration
  Future<void> _queueUserSync(dynamic user, RegisterSubmitted event) async {
    final syncData = {
      'id': user.id ?? _generateTempId(),
      'email': event.email,
      'username': event.username,
      'userType': event.userType,
      'phoneNumber': event.contactNumber,
      if (event.userType == 'restaurant') ...{
        'restaurantName': event.restaurantName,
        'location': event.location,
        'quote': event.quote,
      }
    };

    await _syncService.queueSync(
      id: user.id ?? _generateTempId(),
      data: syncData,
      entityType: event.userType,
      operation: SyncOperation.create,
    );
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

  // Generate a temporary ID for sync operations
  String _generateTempId() {
    return 'temp_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> close() {
    _logger.info('RegisterBloc closing');
    return super.close();
  }
}
