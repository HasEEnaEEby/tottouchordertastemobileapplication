import 'package:equatable/equatable.dart';
import 'package:tottouchordertastemobileapplication/features/customer/customer_profile.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';

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

/// When a tab is changed, we need the selectedIndex.
class CustomerDashboardTabChanged extends CustomerDashboardState {
  final int selectedIndex;
  const CustomerDashboardTabChanged({required this.selectedIndex});
  @override
  List<Object?> get props => [selectedIndex];
}

/// State when restaurants are loaded from the API.
class RestaurantsLoaded extends CustomerDashboardState {
  final List<RestaurantEntity> restaurants;
  const RestaurantsLoaded({required this.restaurants});
  @override
  List<Object?> get props => [restaurants];
}

/// State when profile data is loaded.
class ProfileLoaded extends CustomerDashboardState {
  final CustomerProfile profile;
  const ProfileLoaded({required this.profile});
  @override
  List<Object?> get props => [profile];
}
