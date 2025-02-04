import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/repository/auth_repository.dart';
import 'package:tottouchordertastemobileapplication/features/customer/customer_profile.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_event.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_state.dart';

class CustomerDashboardBloc
    extends Bloc<CustomerDashboardEvent, CustomerDashboardState> {
  final AuthRepository _authRepository;

  // Constructor
  CustomerDashboardBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(CustomerDashboardInitial()) {
    // Registering event handlers
    on<ChangeTabEvent>(_onChangeTab);
    on<LoadRestaurantsEvent>(_onLoadRestaurants);
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<LogoutRequestedEvent>(_onLogoutRequested);
    on<CustomerDashboardTabChangedEvent>(_onTabChanged);
  }

  // Event handler for ChangeTabEvent
  void _onChangeTab(
      ChangeTabEvent event, Emitter<CustomerDashboardState> emit) {
    emit(CustomerDashboardTabChanged(selectedIndex: event.index));
  }

  // Event handler for CustomerDashboardTabChangedEvent
  void _onTabChanged(CustomerDashboardTabChangedEvent event,
      Emitter<CustomerDashboardState> emit) {
    emit(CustomerDashboardTabChanged(selectedIndex: event.selectedIndex));
  }

  // Event handler for LoadRestaurantsEvent
  Future<void> _onLoadRestaurants(
      LoadRestaurantsEvent event, Emitter<CustomerDashboardState> emit) async {
    emit(CustomerDashboardLoading());
    try {
      final result = await _authRepository.getRestaurants();
      result.fold(
        (failure) => emit(CustomerDashboardError(message: failure.message)),
        (restaurants) => emit(RestaurantsLoaded(restaurants: restaurants)),
      );
    } catch (e) {
      emit(CustomerDashboardError(
          message: 'Failed to load restaurants: ${e.toString()}'));
    }
  }

  // Event handler for LoadProfileEvent
  Future<void> _onLoadProfile(
      LoadProfileEvent event, Emitter<CustomerDashboardState> emit) async {
    emit(CustomerDashboardLoading());
    try {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) => emit(CustomerDashboardError(message: failure.message)),
        (authEntity) {
          final customerProfile = CustomerProfile(
            id: authEntity.id ?? '',
            username: authEntity.profile.username ?? '',
            email: authEntity.email,
            displayName: authEntity.profile.displayName,
            phoneNumber: authEntity.profile.phoneNumber,
            profileImage: authEntity.profile.profileImage,
            role: authEntity.userType,
            isEmailVerified: authEntity.isEmailVerified,
            createdAt: authEntity.metadata.createdAt ?? DateTime.now(),
            updatedAt: authEntity.metadata.lastUpdatedAt ?? DateTime.now(),
            additionalInfo: authEntity.profile.additionalInfo ?? {},
          );
          emit(ProfileLoaded(profile: customerProfile));
        },
      );
    } catch (e) {
      emit(CustomerDashboardError(
          message: 'Failed to load profile: ${e.toString()}'));
    }
  }

  // Event handler for UpdateProfileEvent
  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<CustomerDashboardState> emit) async {
    emit(CustomerDashboardLoading());
    try {
      final currentUserResult = await _authRepository.getCurrentUser();
      currentUserResult.fold(
        (failure) => emit(CustomerDashboardError(message: failure.message)),
        (currentUser) async {
          final result = await _authRepository.updateProfile(
            userId: currentUser.id ?? '',
            username: event.name,
            phoneNumber: event.phoneNumber,
          );
          result.fold(
            (failure) => emit(CustomerDashboardError(message: failure.message)),
            (_) async {
              final updatedUserResult = await _authRepository.getCurrentUser();
              updatedUserResult.fold(
                (failure) =>
                    emit(CustomerDashboardError(message: failure.message)),
                (updatedUser) {
                  final updatedProfile = CustomerProfile(
                    id: updatedUser.id ?? '',
                    username: updatedUser.profile.username ?? '',
                    email: updatedUser.email,
                    displayName: updatedUser.profile.displayName,
                    phoneNumber: updatedUser.profile.phoneNumber,
                    profileImage: updatedUser.profile.profileImage,
                    role: updatedUser.userType,
                    isEmailVerified: updatedUser.isEmailVerified,
                    createdAt: updatedUser.metadata.createdAt ?? DateTime.now(),
                    updatedAt:
                        updatedUser.metadata.lastUpdatedAt ?? DateTime.now(),
                    additionalInfo: updatedUser.profile.additionalInfo ?? {},
                  );
                  emit(ProfileLoaded(profile: updatedProfile));
                },
              );
            },
          );
        },
      );
    } catch (e) {
      emit(CustomerDashboardError(
          message: 'Failed to update profile: ${e.toString()}'));
    }
  }

  // Event handler for LogoutRequestedEvent
  Future<void> _onLogoutRequested(
      LogoutRequestedEvent event, Emitter<CustomerDashboardState> emit) async {
    emit(CustomerDashboardLoading());
    try {
      final result = await _authRepository.logout();
      result.fold(
        (failure) => emit(CustomerDashboardError(message: failure.message)),
        (_) => emit(CustomerDashboardInitial()),
      );
    } catch (e) {
      emit(
          CustomerDashboardError(message: 'Failed to logout: ${e.toString()}'));
    }
  }

  // Method to refresh data (loads restaurants and profile)
  Future<void> refreshData(String userName) async {
    add(LoadRestaurantsEvent());
    add(LoadProfileEvent(userName: userName));
  }
}
