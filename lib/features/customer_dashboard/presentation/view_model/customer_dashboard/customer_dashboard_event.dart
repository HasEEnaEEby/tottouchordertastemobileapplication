import 'package:equatable/equatable.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/menu_item_entity.dart';

abstract class CustomerDashboardEvent extends Equatable {
  const CustomerDashboardEvent();

  @override
  List<Object?> get props => [];

  // Add a generic toString method for better debugging
  @override
  String toString() {
    return runtimeType.toString();
  }
}

// Restaurant-related events
class LoadRestaurantsEvent extends CustomerDashboardEvent {
  @override
  String toString() => 'LoadRestaurantsEvent';
}

class LoadRestaurantDetailsEvent extends CustomerDashboardEvent {
  final String restaurantId;

  const LoadRestaurantDetailsEvent({required this.restaurantId});

  @override
  List<Object?> get props => [restaurantId];

  @override
  String toString() =>
      'LoadRestaurantDetailsEvent(restaurantId: $restaurantId)';
}

class LoadRestaurantMenuEvent extends CustomerDashboardEvent {
  final String restaurantId;

  const LoadRestaurantMenuEvent({required this.restaurantId});

  @override
  List<Object?> get props => [restaurantId];

  @override
  String toString() => 'LoadRestaurantMenuEvent(restaurantId: $restaurantId)';
}

// Navigation events
class TabChangedEvent extends CustomerDashboardEvent {
  final int tabIndex;

  const TabChangedEvent({required this.tabIndex});

  @override
  List<Object?> get props => [tabIndex];

  @override
  String toString() => 'TabChangedEvent(tabIndex: $tabIndex)';
}

// Profile-related events
class LoadProfileEvent extends CustomerDashboardEvent {
  @override
  String toString() => 'LoadProfileEvent';
}

class UpdateProfileEvent extends CustomerDashboardEvent {
  final String? name;
  final String? email;
  final String? phoneNumber;

  const UpdateProfileEvent({
    this.name,
    this.email,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [name, email, phoneNumber];

  @override
  String toString() =>
      'UpdateProfileEvent(name: $name, email: $email, phoneNumber: $phoneNumber)';
}

// Order-related events
class SelectTableEvent extends CustomerDashboardEvent {
  final String tableId;

  const SelectTableEvent({required this.tableId});

  @override
  List<Object?> get props => [tableId];

  @override
  String toString() => 'SelectTableEvent(tableId: $tableId)';
}

class AddToCartEvent extends CustomerDashboardEvent {
  final MenuItemEntity menuItem;

  const AddToCartEvent({required this.menuItem});

  @override
  List<Object?> get props => [menuItem];

  @override
  String toString() =>
      'AddToCartEvent(menuItem: ${menuItem.name}, price: ${menuItem.price})';
}

class RemoveFromCartEvent extends CustomerDashboardEvent {
  final String itemId;

  const RemoveFromCartEvent({required this.itemId});

  @override
  List<Object?> get props => [itemId];

  @override
  String toString() => 'RemoveFromCartEvent(itemId: $itemId)';
}

class UpdateCartItemQuantityEvent extends CustomerDashboardEvent {
  final String itemId;
  final int quantity;

  const UpdateCartItemQuantityEvent({
    required this.itemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [itemId, quantity];

  @override
  String toString() =>
      'UpdateCartItemQuantityEvent(itemId: $itemId, quantity: $quantity)';
}

class AddSpecialInstructionsEvent extends CustomerDashboardEvent {
  final String itemId;
  final String instructions;

  const AddSpecialInstructionsEvent({
    required this.itemId,
    required this.instructions,
  });

  @override
  List<Object?> get props => [itemId, instructions];

  @override
  String toString() =>
      'AddSpecialInstructionsEvent(itemId: $itemId, instructions: $instructions)';
}

class PlaceOrderEvent extends CustomerDashboardEvent {
  final String restaurantId;
  final String tableId;

  const PlaceOrderEvent({
    required this.restaurantId,
    required this.tableId,
  });

  @override
  List<Object?> get props => [restaurantId, tableId];

  @override
  String toString() =>
      'PlaceOrderEvent(restaurantId: $restaurantId, tableId: $tableId)';
}

class ClearCartEvent extends CustomerDashboardEvent {
  @override
  String toString() => 'ClearCartEvent';
}

// Authentication events
class LogoutRequestedEvent extends CustomerDashboardEvent {
  @override
  String toString() => 'LogoutRequestedEvent';
}

class CheckAuthStatusEvent extends CustomerDashboardEvent {
  @override
  String toString() => 'CheckAuthStatusEvent';
}
