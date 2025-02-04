import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;
  final String userType;
  final String? adminCode;
  final BuildContext context;

  const LoginSubmitted({
    required this.email,
    required this.password,
    required this.userType,
    required this.context,
    this.adminCode,
  });

  @override
  List<Object?> get props => [email, password, userType, adminCode, context];
}

class LogoutRequested extends LoginEvent {
  final BuildContext context;

  const LogoutRequested({required this.context});
}

class NavigateRegisterScreenEvent extends LoginEvent {
  final BuildContext context;

  const NavigateRegisterScreenEvent({required this.context});
}

class CheckAuthenticationStatus extends LoginEvent {
  final BuildContext context;

  const CheckAuthenticationStatus({required this.context});
}
