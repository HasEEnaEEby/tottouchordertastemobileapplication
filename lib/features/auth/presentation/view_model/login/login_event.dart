import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;
  final String userType;

  const LoginSubmitted({
    required this.email,
    required this.password,
    required this.userType, String? adminCode,
  });

  @override
  List<Object?> get props => [email, password, userType];
}
class LogoutRequested extends LoginEvent {}

class CheckAuthenticationStatus extends LoginEvent {}