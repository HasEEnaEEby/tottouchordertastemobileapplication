import 'package:equatable/equatable.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/cart_item_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/menu_item_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';

// Base State
abstract class CustomerDashboardState extends Equatable {
  const CustomerDashboardState();

  @override
  List<Object?> get props => [];

  @override
  String toString() => runtimeType.toString();
}

// Initial State
class CustomerDashboardInitial extends CustomerDashboardState {
  @override
  String toString() => 'CustomerDashboardInitial';
}

// Loading States
class CustomerDashboardLoading extends CustomerDashboardState {
  @override
  String toString() => 'CustomerDashboardLoading';
}

class RestaurantDetailsLoading extends CustomerDashboardState {
  @override
  String toString() => 'RestaurantDetailsLoading';
}

// Loaded States
class RestaurantsLoaded extends CustomerDashboardState {
  final List<RestaurantEntity> restaurants;

  const RestaurantsLoaded({required this.restaurants});

  @override
  List<Object?> get props => [restaurants];

  @override
  String toString() => 'RestaurantsLoaded(count: ${restaurants.length})';
}

class RestaurantDetailsLoaded extends CustomerDashboardState {
  final RestaurantEntity restaurant;
  final List<MenuItemEntity> menuItems;
  final List<TableEntity> tables;
  final List<CartItemEntity> cartItems;
  final TableEntity? selectedTable;
  final String? selectedTableId;

  const RestaurantDetailsLoaded({
    required this.restaurant,
    required this.menuItems,
    required this.tables,
    this.cartItems = const [],
    this.selectedTable,
    this.selectedTableId,
  });

  RestaurantDetailsLoaded copyWith({
    RestaurantEntity? restaurant,
    List<MenuItemEntity>? menuItems,
    List<TableEntity>? tables,
    List<CartItemEntity>? cartItems,
    TableEntity? selectedTable,
    String? selectedTableId,
  }) {
    return RestaurantDetailsLoaded(
      restaurant: restaurant ?? this.restaurant,
      menuItems: menuItems ?? this.menuItems,
      tables: tables ?? this.tables,
      cartItems: cartItems ?? this.cartItems,
      selectedTable: selectedTable ?? this.selectedTable,
      selectedTableId: selectedTableId ?? this.selectedTableId,
    );
  }

  @override
  List<Object?> get props => [
        restaurant,
        menuItems,
        tables,
        cartItems,
        selectedTable,
        selectedTableId,
      ];

  @override
  String toString() {
    return '''RestaurantDetailsLoaded(
      restaurant: ${restaurant.restaurantName}, 
      menuItems: ${menuItems.length}, 
      tables: ${tables.length}, 
      cartItems: ${cartItems.length}, 
      selectedTable: $selectedTableId
    )''';
  }
}

class ProfileLoaded extends CustomerDashboardState {
  final String userName;
  final String email;
  final bool isVerified;
  final List<RestaurantEntity> restaurants;

  const ProfileLoaded({
    required this.userName,
    required this.email,
    required this.isVerified,
    required this.restaurants,
  });

  @override
  List<Object?> get props => [userName, email, isVerified, restaurants];

  @override
  String toString() =>
      'ProfileLoaded(userName: $userName, email: $email, isVerified: $isVerified)';
}

class CustomerDashboardTabChanged extends CustomerDashboardState {
  final int selectedIndex;
  final List<RestaurantEntity> restaurants;

  const CustomerDashboardTabChanged({
    required this.selectedIndex,
    required this.restaurants,
  });

  @override
  List<Object?> get props => [selectedIndex, restaurants];

  @override
  String toString() =>
      'CustomerDashboardTabChanged(selectedIndex: $selectedIndex)';
}

// Error States
class CustomerDashboardError extends CustomerDashboardState {
  final String message;

  const CustomerDashboardError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'CustomerDashboardError: $message';
}

class RestaurantDetailsError extends CustomerDashboardState {
  final String message;

  const RestaurantDetailsError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'RestaurantDetailsError: $message';
}

class OrderError extends CustomerDashboardState {
  final String message;

  const OrderError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'OrderError: $message';
}

// Authentication States
class CustomerDashboardAuthError extends CustomerDashboardState {
  final String message;

  const CustomerDashboardAuthError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'CustomerDashboardAuthError: $message';
}

// Success States
class ProfileUpdateSuccess extends CustomerDashboardState {
  final String message;
  final List<RestaurantEntity> restaurants;

  const ProfileUpdateSuccess({
    required this.message,
    required this.restaurants,
  });

  @override
  List<Object?> get props => [message, restaurants];

  @override
  String toString() => 'ProfileUpdateSuccess: $message';
}

class OrderPlacedSuccessfully extends CustomerDashboardState {
  final String orderId;
  final String restaurantName;

  const OrderPlacedSuccessfully({
    required this.orderId,
    required this.restaurantName,
  });

  @override
  List<Object?> get props => [orderId, restaurantName];

  @override
  String toString() =>
      'OrderPlacedSuccessfully(orderId: $orderId, restaurant: $restaurantName)';
}

class LogoutSuccess extends CustomerDashboardState {
  @override
  String toString() => 'LogoutSuccess';
}
