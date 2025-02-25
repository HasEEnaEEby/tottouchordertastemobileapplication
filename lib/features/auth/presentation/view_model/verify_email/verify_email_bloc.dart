import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/core/auth/auth_token_manager.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/verify_email_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/verify_email/verify_email_event.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/verify_email/verify_email_state.dart';

class VerifyEmailBloc extends Bloc<VerifyEmailEvent, VerifyEmailState> {
  final VerifyEmailUseCase verifyEmailUseCase;
  final AuthTokenManager tokenManager;

  VerifyEmailBloc({
    required this.verifyEmailUseCase,
    required this.tokenManager,
  }) : super(VerifyEmailInitial()) {
    on<VerifyEmailRequested>(_onVerifyEmailRequested);
    on<ResendVerificationEmailRequested>(_onResendVerificationEmailRequested);
  }

  Future<void> _onVerifyEmailRequested(
    VerifyEmailRequested event,
    Emitter<VerifyEmailState> emit,
  ) async {
    try {
      emit(VerifyEmailLoading());

      final result = await verifyEmailUseCase(event.token);

      result.fold(
        (failure) {
          emit(VerifyEmailFailure(error: failure.message));
        },
        (success) {
          // Update local token manager with verified status
          final userData = tokenManager.getUserData() ?? {};
          userData['isEmailVerified'] = true;

          tokenManager.saveAuthData(
            token: tokenManager.getToken() ?? '',
            refreshToken: tokenManager.getRefreshToken() ?? '',
            userData: userData,
          );

          emit(const VerifyEmailSuccess(
            message: 'Email verified successfully! You can now log in.',
          ));
        },
      );
    } catch (e) {
      emit(VerifyEmailFailure(
        error: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  Future<void> _onResendVerificationEmailRequested(
    ResendVerificationEmailRequested event,
    Emitter<VerifyEmailState> emit,
  ) async {
    try {
      emit(VerifyEmailLoading());

      final result =
          await verifyEmailUseCase.resendVerificationEmail(event.email);

      result.fold(
        (failure) {
          emit(VerifyEmailFailure(error: failure.message));
        },
        (success) {
          emit(const VerifyEmailSuccess(
            message: 'Verification email has been resent successfully.',
          ));
        },
      );
    } catch (e) {
      emit(VerifyEmailFailure(
        error: 'Failed to resend verification email: ${e.toString()}',
      ));
    }
  }
}
