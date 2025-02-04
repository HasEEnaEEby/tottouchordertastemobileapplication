import 'package:equatable/equatable.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer/customer_profile.dart';

abstract class CustomerDashboardState extends Equatable {
  const CustomerDashboardState();

  @override
  List<Object?> get props => [];
}

class CustomerDashboardInitial extends CustomerDashboardState {}

class CustomerDashboardLoading extends CustomerDashboardState {}

class CustomerDashboardError extends CustomerDashboardState {
  final String message;

  const CustomerDashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CustomerDashboardTabChanged extends CustomerDashboardState {
  final int selectedIndex;

  const CustomerDashboardTabChanged({required this.selectedIndex});

  @override
  List<Object?> get props => [selectedIndex];
}

class RestaurantsLoaded extends CustomerDashboardState {
  final List<RestaurantEntity> restaurants;

  const RestaurantsLoaded({required this.restaurants});

  @override
  List<Object?> get props => [restaurants];
}

class ProfileLoaded extends CustomerDashboardState {
  final CustomerProfile profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}
