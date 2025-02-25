import 'package:equatable/equatable.dart';

abstract class VerifyEmailEvent extends Equatable {
  const VerifyEmailEvent();

  @override
  List<Object> get props => [];
}

class VerifyEmailRequested extends VerifyEmailEvent {
  final String token;

  const VerifyEmailRequested({required this.token});

  @override
  List<Object> get props => [token];
}

class ResendVerificationEmailRequested extends VerifyEmailEvent {
  final String email;

  const ResendVerificationEmailRequested({required this.email});

  @override
  List<Object> get props => [email];
}
