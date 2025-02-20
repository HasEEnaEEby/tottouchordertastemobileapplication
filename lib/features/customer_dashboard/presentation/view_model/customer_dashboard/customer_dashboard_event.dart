import 'package:equatable/equatable.dart';

abstract class CustomerDashboardEvent extends Equatable {
  const CustomerDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadRestaurantsEvent extends CustomerDashboardEvent {}

class LoadProfileEvent extends CustomerDashboardEvent {
  final String? userName;

  const LoadProfileEvent({this.userName});

  @override
  List<Object?> get props => [userName];
}

class UpdateProfileEvent extends CustomerDashboardEvent {
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? profilePicture;

  const UpdateProfileEvent({
    this.name,
    this.email,
    this.phoneNumber,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [name, email, phoneNumber, profilePicture];
}

class TabChangedEvent extends CustomerDashboardEvent {
  final int tabIndex;

  const TabChangedEvent({required this.tabIndex});

  @override
  List<Object?> get props => [tabIndex];
}

class LogoutRequestedEvent extends CustomerDashboardEvent {
  const LogoutRequestedEvent();
}
