import 'package:equatable/equatable.dart';

abstract class VerifyEmailState extends Equatable {
  const VerifyEmailState();

  @override
  List<Object> get props => [];
}

class VerifyEmailInitial extends VerifyEmailState {}

class VerifyEmailLoading extends VerifyEmailState {}

class VerifyEmailSuccess extends VerifyEmailState {
  final String message;

  const VerifyEmailSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class VerifyEmailFailure extends VerifyEmailState {
  final String error;

  const VerifyEmailFailure({required this.error});

  @override
  List<Object> get props => [error];
}
