import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/use_case/get_all_restaurants_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_event.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_state.dart';

class CustomerDashboardBloc
    extends Bloc<CustomerDashboardEvent, CustomerDashboardState> {
  final GetAllRestaurantsUseCase getAllRestaurantsUseCase;

  int currentTabIndex = 0; // Track current tab index

  CustomerDashboardBloc({required this.getAllRestaurantsUseCase})
      : super(CustomerDashboardInitial()) {
    // Handle loading restaurants
    on<LoadRestaurantsEvent>(_onLoadRestaurants);

    // ✅ Fix: Handle tab change event
    on<TabChangedEvent>(_onTabChanged);
  }

  /// Handles loading restaurants from API
  Future<void> _onLoadRestaurants(
      LoadRestaurantsEvent event, Emitter<CustomerDashboardState> emit) async {
    emit(CustomerDashboardLoading());
    final result = await getAllRestaurantsUseCase();
    result.fold(
      (failure) => emit(CustomerDashboardError(message: failure.message)),
      (restaurants) => emit(RestaurantsLoaded(restaurants: restaurants)),
    );
  }

  /// ✅ New Function: Handle tab change
  void _onTabChanged(
      TabChangedEvent event, Emitter<CustomerDashboardState> emit) {
    currentTabIndex = event.tabIndex;
    emit(CustomerDashboardTabChanged(selectedIndex: currentTabIndex));
  }
}
