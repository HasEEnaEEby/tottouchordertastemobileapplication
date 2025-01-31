import 'package:flutter_bloc/flutter_bloc.dart';

import 'customer_dashboard_event.dart';
import 'customer_dashboard_state.dart';

class CustomerDashboardBloc
    extends Bloc<CustomerDashboardEvent, CustomerDashboardState> {
  CustomerDashboardBloc() : super(CustomerDashboardInitial()) {
    on<ChangeTabEvent>(_onChangeTab);
    on<LoadRestaurantsEvent>(_onLoadRestaurants);
    on<LoadProfileEvent>(_onLoadProfile);
  }

  void _onChangeTab(
      ChangeTabEvent event, Emitter<CustomerDashboardState> emit) {
    emit(CustomerDashboardTabChanged(selectedIndex: event.index));
  }

  void _onLoadRestaurants(
      LoadRestaurantsEvent event, Emitter<CustomerDashboardState> emit) async {
    emit(CustomerDashboardLoading());
    try {
      // Simulate loading restaurants (replace with actual data fetching)
      final restaurants = ['Thakali Restaurant', 'Pizza Hub', 'Spice Villa'];
      emit(RestaurantsLoaded(restaurants: restaurants));
    } catch (e) {
      emit(const CustomerDashboardError(message: 'Failed to load restaurants'));
    }
  }

  void _onLoadProfile(
      LoadProfileEvent event, Emitter<CustomerDashboardState> emit) async {
    emit(CustomerDashboardLoading());
    try {
      // Simulate loading user profile (replace with actual data fetching)
      final profile = CustomerProfile(
          name: 'John Doe',
          email: 'johndoe@example.com',
          loyaltyPoints: 1200,
          favoriteRestaurants: ['Thakali Restaurant', 'Pizza Hub']);
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(const CustomerDashboardError(message: 'Failed to load profile'));
    }
  }
}
