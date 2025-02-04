import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterUserTypeChanged extends RegisterEvent {
  final String userType;

  const RegisterUserTypeChanged(this.userType);

  @override
  List<Object> get props => [userType];
}

class RegisterSubmitted extends RegisterEvent {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String userType;
  final String? restaurantName;
  final String? location;
  final String? contactNumber;
  final String? quote;
  final BuildContext context;

  const RegisterSubmitted({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.userType,
    required this.context,
    this.restaurantName,
    this.location,
    this.contactNumber,
    this.quote,
  });

  @override
  List<Object?> get props => [
        username,
        email,
        password,
        confirmPassword,
        userType,
        restaurantName,
        location,
        contactNumber,
        quote,
        context,
      ];
}

// Add this new event for navigating to the login page
class NavigateToLoginEvent extends RegisterEvent {
  final BuildContext context;

  const NavigateToLoginEvent({required this.context});

  @override
  List<Object?> get props => [context];
}
