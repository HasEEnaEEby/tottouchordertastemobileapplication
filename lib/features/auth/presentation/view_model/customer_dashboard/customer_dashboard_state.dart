import 'package:equatable/equatable.dart';

class CustomerProfile {
  final String name;
  final String email;
  final int loyaltyPoints;
  final List<String> favoriteRestaurants;

  CustomerProfile({
    required this.name,
    required this.email,
    required this.loyaltyPoints,
    required this.favoriteRestaurants,
  });
}

abstract class CustomerDashboardState extends Equatable {
  const CustomerDashboardState();
  
  @override
  List<Object> get props => [];
}

class CustomerDashboardInitial extends CustomerDashboardState {}

class CustomerDashboardLoading extends CustomerDashboardState {}

class CustomerDashboardTabChanged extends CustomerDashboardState {
  final int selectedIndex;
  
  const CustomerDashboardTabChanged({required this.selectedIndex});

  @override
  List<Object> get props => [selectedIndex];
}

class RestaurantsLoaded extends CustomerDashboardState {
  final List<String> restaurants;
  
  const RestaurantsLoaded({required this.restaurants});

  @override
  List<Object> get props => [restaurants];
}

class ProfileLoaded extends CustomerDashboardState {
  final CustomerProfile profile;
  
  const ProfileLoaded({required this.profile});

  @override
  List<Object> get props => [profile];
}

class CustomerDashboardError extends CustomerDashboardState {
  final String message;
  
  const CustomerDashboardError({required this.message});

  @override
  List<Object> get props => [message];
}