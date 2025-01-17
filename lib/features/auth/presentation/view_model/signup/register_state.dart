import 'package:equatable/equatable.dart';

import '../../../domain/entity/auth_entity.dart';

abstract class RegisterState extends Equatable {
  final String selectedUserType;

  const RegisterState({
    this.selectedUserType = 'customer',
  });

  @override
  List<Object?> get props => [selectedUserType];
}

class RegisterInitial extends RegisterState {
  const RegisterInitial({super.selectedUserType});
}

class RegisterLoading extends RegisterState {
  const RegisterLoading({super.selectedUserType});
}

class RegisterSuccess extends RegisterState {
  final AuthEntity user;

  const RegisterSuccess(this.user, {super.selectedUserType});

  @override
  List<Object?> get props => [user, selectedUserType];
}

class RegisterError extends RegisterState {
  final String message;

  const RegisterError(this.message, {super.selectedUserType});

  @override
  List<Object?> get props => [message, selectedUserType];
}
