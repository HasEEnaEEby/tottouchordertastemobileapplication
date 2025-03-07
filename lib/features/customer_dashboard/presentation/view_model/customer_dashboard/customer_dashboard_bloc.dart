import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/core/auth/auth_token_manager.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/cart_item_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/menu_item_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/order_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/restaurant_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/table_repository.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/use_case/customer_dashboard_usecases.dart';

import 'customer_dashboard_event.dart';
import 'customer_dashboard_state.dart';

class CustomerDashboardBloc
    extends Bloc<CustomerDashboardEvent, CustomerDashboardState> {
  // Use cases
  final GetAllRestaurantsUseCase getAllRestaurantsUseCase;
  final GetRestaurantDetailsUseCase getRestaurantDetailsUseCase;
  final GetRestaurantMenuUseCase getRestaurantMenuUseCase;
  final GetRestaurantTablesUseCase getRestaurantTablesUseCase;
  final PlaceOrderUseCase placeOrderUseCase;
  final AuthTokenManager _tokenManager;
  final TableRepository tableRepository;

  // Internal state management
  final List<RestaurantEntity> _restaurants = [];
  bool _isLoading = false;

  // Event queue management
  final List<CustomerDashboardEvent> _eventQueue = [];
  bool _isProcessingEvents = false;
  Timer? _eventProcessingTimer;
  final Duration _queueProcessingInterval = const Duration(milliseconds: 300);
  final Duration _debounceTime = const Duration(milliseconds: 300);
  Timer? _debounceTimer;

  CustomerDashboardBloc({
    required this.getAllRestaurantsUseCase,
    required this.getRestaurantDetailsUseCase,
    required this.getRestaurantMenuUseCase,
    required this.getRestaurantTablesUseCase,
    required this.placeOrderUseCase,
    required this.tableRepository,
    required AuthTokenManager tokenManager,
  })  : _tokenManager = tokenManager,
        super(CustomerDashboardInitial()) {
    _registerEventHandlers();
    _setupEventQueue();
  }

  void _registerEventHandlers() {
    on<LoadRestaurantsEvent>(_onLoadRestaurants);
    on<LoadRestaurantDetailsEvent>(_onLoadRestaurantDetails);
    on<TabChangedEvent>(_onTabChanged);
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<SelectTableEvent>(_onSelectTable);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateCartItemQuantity);
    on<AddSpecialInstructionsEvent>(_onAddSpecialInstructions);
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<ClearCartEvent>(_onClearCart);
    on<LogoutRequestedEvent>(_onLogoutRequested);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<ValidateTableQREvent>(_onValidateTableQR);
    on<UnselectTableEvent>(_onUnselectTable);
    on<ToggleFavoritesFilterEvent>(_onToggleFavoritesFilter);
    on<PreserveRestaurantsEvent>(_onPreserveRestaurants);
  }

  Future<void> _onLoadRestaurants(
    LoadRestaurantsEvent event,
    Emitter<CustomerDashboardState> emit,
  ) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      debugPrint('📡 Fetching restaurants from API...');
      emit(CustomerDashboardLoading());

      final result = await getAllRestaurantsUseCase.call();

      await result.fold(
        (failure) async {
          debugPrint('❌ API Failure: ${failure.message}');
          emit(CustomerDashboardError(message: failure.message));
        },
        (restaurants) async {
          debugPrint('✅ Received ${restaurants.length} restaurants.');
          for (var restaurant in restaurants) {
            debugPrint(
                '📝 ${restaurant.restaurantName} | Image: ${restaurant.image}');
          }
          _restaurants.clear();
          _restaurants.addAll(restaurants);
          emit(RestaurantsLoaded(restaurants: List.from(_restaurants)));
        },
      );
    } catch (e) {
      emit(CustomerDashboardError(message: e.toString()));
    } finally {
      _isLoading = false;
    }
  }

  void _onToggleFavoritesFilter(
    ToggleFavoritesFilterEvent event,
    Emitter<CustomerDashboardState> emit,
  ) {
    final currentState = state;

    if (currentState is RestaurantsLoaded) {
      emit(CustomerDashboardTabChanged(
        selectedIndex: 0, // Default to restaurants tab
        restaurants: _restaurants,
        showFavoritesOnly: event.showFavoritesOnly,
      ));
    } else if (currentState is CustomerDashboardTabChanged) {
      emit(CustomerDashboardTabChanged(
        selectedIndex: currentState.selectedIndex,
        restaurants: currentState.restaurants,
        showFavoritesOnly: event.showFavoritesOnly,
      ));
    }
  }

  void _onPreserveRestaurants(
    PreserveRestaurantsEvent event,
    Emitter<CustomerDashboardState> emit,
  ) {
    // Check if we already have loaded restaurants
    if (_restaurants.isNotEmpty) {
      debugPrint('🔄 Preserving ${_restaurants.length} loaded restaurants');
      emit(RestaurantsLoaded(restaurants: List.from(_restaurants)));
    } else {
      debugPrint('⚠️ No restaurants to preserve, triggering load');
      add(LoadRestaurantsEvent());
    }
  }

  Future<void> _onLoadRestaurantDetails(
    LoadRestaurantDetailsEvent event,
    Emitter<CustomerDashboardState> emit,
  ) async {
    if (!_tokenManager.hasValidToken()) {
      emit(const CustomerDashboardAuthError(
        message: 'Session expired. Please log in again.',
      ));
      return;
    }

    try {
      emit(RestaurantDetailsLoading());

      final result = await getRestaurantDetailsUseCase.call(event.restaurantId);

      await result.fold(
        (failure) async {
          emit(RestaurantDetailsError(message: failure.message));
        },
        (restaurant) async {
          // Get menu items
          final menuResult =
              await getRestaurantMenuUseCase.call(event.restaurantId);
          final List<MenuItemEntity> menuItems = await menuResult.fold(
            (failure) => [],
            (items) => items,
          );

          // Get tables
          final tablesResult =
              await getRestaurantTablesUseCase.call(event.restaurantId);
          final List<TableEntity> tables = await tablesResult.fold(
            (failure) => [],
            (tablesList) => tablesList.cast<TableEntity>().toList(),
          );

          emit(RestaurantDetailsLoaded(
            restaurant: restaurant,
            menuItems: menuItems,
            tables: tables,
            cartItems: const [],
          ));
        },
      );
    } catch (e) {
      emit(RestaurantDetailsError(message: e.toString()));
    }
  }

  void _onTabChanged(
      TabChangedEvent event, Emitter<CustomerDashboardState> emit) {
    emit(CustomerDashboardTabChanged(
      selectedIndex: event.tabIndex,
      restaurants: List.from(_restaurants),
    ));
  }

  void _debounce(VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceTime, callback);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _eventProcessingTimer?.cancel();
    return super.close();
  }

  void _setupEventQueue() {
    _eventProcessingTimer = Timer.periodic(_queueProcessingInterval, (_) {
      _processEventQueue();
    });
  }

  void _processEventQueue() {
    if (_isProcessingEvents || _eventQueue.isEmpty) return;

    _isProcessingEvents = true;
    try {
      final event = _eventQueue.removeAt(0);
      debugPrint('Processing queued event: ${event.runtimeType}');
      add(event);
    } catch (e) {
      debugPrint('Error processing event queue: $e');
    } finally {
      _isProcessingEvents = false;
    }
  }

  @override
  void add(CustomerDashboardEvent event) {
    if (!isClosed) {
      super.add(event);
    } else {
      debugPrint('Attempted to add event ${event.runtimeType} to closed bloc');
    }
  }

  // void _logError(Object error, StackTrace? stackTrace) {
  //   debugPrint('💥 Unexpected Error: $error');
  //   if (stackTrace != null) {
  //     debugPrintStack(stackTrace: stackTrace);
  //   }
  // }

  // bool _validateToken() {
  //   if (!_tokenManager.hasValidToken()) {
  //     debugPrint('🚫 Invalid Authentication Token');
  //     return false;
  //   }
  //   return true;
  // }

  Future<void> _onLoadRestaurantMenu(
    LoadRestaurantMenuEvent event,
    Emitter<CustomerDashboardState> emit,
  ) async {
    try {
      // Check token validity before making the request
      if (!_tokenManager.hasValidToken()) {
        debugPrint('Invalid token, redirecting to login');
        emit(const CustomerDashboardAuthError(
          message: 'Session expired. Please log in again.',
        ));
        return;
      }

      // Fetch restaurant menu
      final result = await getRestaurantMenuUseCase.call(event.restaurantId);

      result.fold(
        (failure) {
          debugPrint('Restaurant menu fetch failure: ${failure.message}');

          // If current state is RestaurantDetailsLoaded, emit an error while maintaining current state
          final currentState = state;
          if (currentState is RestaurantDetailsLoaded) {
            emit(RestaurantDetailsError(message: failure.message));
          } else {
            emit(CustomerDashboardError(message: failure.message));
          }
        },
        (menuItems) {
          final currentState = state;

          // Update menu items if in RestaurantDetailsLoaded state
          if (currentState is RestaurantDetailsLoaded) {
            emit(currentState.copyWith(menuItems: menuItems));
          } else {
            // If not in RestaurantDetailsLoaded state, just print a debug message
            debugPrint('Received menu items, but not in expected state');
          }
        },
      );
    } catch (e) {
      debugPrint('Unexpected error loading restaurant menu: $e');

      final currentState = state;
      if (currentState is RestaurantDetailsLoaded) {
        emit(RestaurantDetailsError(
          message: 'Failed to load restaurant menu: ${e.toString()}',
        ));
      } else {
        emit(CustomerDashboardError(
          message: 'Failed to load restaurant menu: ${e.toString()}',
        ));
      }
    }
  }

  void _onUnselectTable(
    UnselectTableEvent event,
    Emitter<CustomerDashboardState> emit,
  ) {
    final currentState = state;
    if (currentState is RestaurantDetailsLoaded) {
      emit(currentState.copyWith(
        selectedTable: null,
        selectedTableId: null,
      ));
    }
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<CustomerDashboardState> emit,
  ) async {
    try {
      if (!_tokenManager.hasValidToken()) {
        emit(const CustomerDashboardAuthError(
          message: 'Session expired. Please log in again.',
        ));
        return;
      }

      emit(CustomerDashboardLoading());

      final userData = _tokenManager.getUserData();
      if (userData == null) {
        emit(const CustomerDashboardAuthError(
          message: 'User data not found. Please log in again.',
        ));
        return;
      }

      emit(ProfileLoaded(
        userName: userData['username'] ?? 'Guest User',
        email: userData['email'] ?? '',
        isVerified: userData['isEmailVerified'] ?? false,
        restaurants: List.from(_restaurants),
      ));
    } catch (e) {
      emit(CustomerDashboardError(
        message: 'Failed to load profile: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<CustomerDashboardState> emit,
  ) async {
    try {
      if (!_tokenManager.hasValidToken()) {
        emit(const CustomerDashboardAuthError(
          message: 'Session expired. Please log in again.',
        ));
        return;
      }

      emit(CustomerDashboardLoading());

      final userData = _tokenManager.getUserData();
      if (userData != null) {
        userData['username'] = event.name ?? userData['username'];
        userData['email'] = event.email ?? userData['email'];
        userData['phoneNumber'] = event.phoneNumber ?? userData['phoneNumber'];

        await _tokenManager.saveAuthData(
          token: _tokenManager.getToken()!,
          refreshToken: _tokenManager.getRefreshToken()!,
          userData: userData,
        );

        emit(ProfileUpdateSuccess(
          message: 'Profile updated successfully',
          restaurants: List.from(_restaurants),
        ));
      }
    } catch (e) {
      emit(CustomerDashboardError(
        message: 'Failed to update profile: ${e.toString()}',
      ));
    }
  }

  Future<void> _onPlaceOrder(
    PlaceOrderEvent event,
    Emitter<CustomerDashboardState> emit,
  ) async {
    try {
      if (!_tokenManager.hasValidToken()) {
        emit(const CustomerDashboardAuthError(
          message: 'Session expired. Please log in again.',
        ));
        return;
      }

      final currentState = state;
      if (currentState is! RestaurantDetailsLoaded) {
        emit(const OrderError(message: 'Invalid order state'));
        return;
      }

      // Validate order requirements
      if (currentState.selectedTable == null) {
        emit(const OrderError(message: 'Please select a table'));
        return;
      }

      if (currentState.cartItems.isEmpty) {
        emit(const OrderError(message: 'Cart is empty'));
        return;
      }

      // Calculate total amount
      final totalAmount = currentState.cartItems
          .fold(0.0, (total, item) => total + (item.price * item.quantity));

      // Create OrderRequestEntity from cart items
      final orderRequest = OrderRequestEntity(
        restaurantId: event.restaurantId,
        tableId: event.tableId,
        items: currentState.cartItems
            .map((cartItem) => OrderItemEntity(
                  menuItemId: cartItem.id,
                  name: cartItem.name,
                  price: cartItem.price,
                  quantity: cartItem.quantity,
                  specialInstructions: cartItem.specialInstructions,
                ))
            .toList(),
        totalAmount: totalAmount,
      );

      final result = await placeOrderUseCase.call(orderRequest);

      result.fold(
        (failure) => emit(OrderError(message: failure.message)),
        (order) => emit(OrderPlacedSuccessfully(
          orderId: order.id,
          restaurantName: currentState.restaurant.id, // Use id instead of name
        )),
      );
    } catch (e) {
      emit(OrderError(message: 'Failed to place order: $e'));
    }
  }

  // Implement other methods similarly...
  void _onSelectTable(
    SelectTableEvent event,
    Emitter<CustomerDashboardState> emit,
  ) {
    print("📌 Bloc: Selecting Table ${event.tableId}");

    final currentState = state;
    if (currentState is RestaurantDetailsLoaded) {
      try {
        final selectedTable = currentState.tables.firstWhere(
          (table) => table.id == event.tableId,
          orElse: () {
            print(
                "🚨 Table ID ${event.tableId} not found in available tables!");
            return currentState.tables.first; // Fallback to first table
          },
        );

        print(
            "✅ Selected Table: ${selectedTable.id}, Number: ${selectedTable.number}");

        emit(currentState.copyWith(
          selectedTable: selectedTable,
          selectedTableId: selectedTable.id,
        ));
      } catch (e) {
        print("🚨 Error selecting table: $e");
      }
    }
  }

  void _onAddToCart(
    AddToCartEvent event,
    Emitter<CustomerDashboardState> emit,
  ) {
    // Comprehensive logging
    debugPrint('🛒 Adding to Cart');
    debugPrint('📍 Menu Item Details:');
    debugPrint('   Name: ${event.menuItem.name}');
    debugPrint('   ID: ${event.menuItem.id}');
    debugPrint('   Price: ₹${event.menuItem.price}');
    debugPrint('   Is Vegetarian: ${event.menuItem.isVegetarian}');

    // Check current state
    final currentState = state;

    // Validate state
    if (currentState is! RestaurantDetailsLoaded) {
      debugPrint('❌ Cannot add to cart: Invalid state');
      debugPrint('   Current State Type: ${currentState.runtimeType}');
      return;
    }

    // Create a mutable copy of cart items
    final updatedCartItems = List<CartItemEntity>.from(currentState.cartItems);

    // Validate menu item
    if (!_validateMenuItem(event.menuItem)) {
      debugPrint('❌ Invalid menu item. Cannot add to cart.');
      return;
    }

    // Find existing item index
    final existingItemIndex = updatedCartItems.indexWhere(
      (item) => item.id == event.menuItem.id,
    );

    // Maximum quantity limit (optional)
    const int maxQuantity = 10;

    if (existingItemIndex != -1) {
      // Item exists in cart
      final currentItem = updatedCartItems[existingItemIndex];

      if (currentItem.quantity >= maxQuantity) {
        debugPrint('⚠️ Maximum quantity reached for ${event.menuItem.name}');
        // Optionally, show a snackbar or toast to user
        return;
      }

      // Update existing item quantity
      updatedCartItems[existingItemIndex] = currentItem.copyWith(
        quantity: currentItem.quantity + 1,
      );

      debugPrint('🔄 Updated existing item: ${event.menuItem.name}');
      debugPrint(
          '   New Quantity: ${updatedCartItems[existingItemIndex].quantity}');
    } else {
      // Create new cart item
      final newCartItem = CartItemEntity(
        id: event.menuItem.id,
        name: event.menuItem.name,
        price: event.menuItem.price,
        image: event.menuItem.image,
        isVegetarian: event.menuItem.isVegetarian,
        quantity: 1,
        // Optional: Add special instructions field
        specialInstructions: null,
      );

      updatedCartItems.add(newCartItem);

      debugPrint('➕ Added new item to cart: ${event.menuItem.name}');
    }

    // Calculate total items and total price
    final totalItems =
        updatedCartItems.fold(0, (total, item) => total + item.quantity);
    final totalPrice = updatedCartItems.fold(
        0.0, (total, item) => total + (item.price * item.quantity));

    debugPrint('🛒 Cart Summary:');
    debugPrint('   Total Items: $totalItems');
    debugPrint('   Total Price: ₹$totalPrice');

    // Emit updated state
    emit(
      currentState.copyWith(
        cartItems: updatedCartItems,
      ),
    );
  }

// Optional: Validate menu item before adding to cart
  bool _validateMenuItem(MenuItemEntity menuItem) {
    // Add your validation logic
    if (menuItem.id.isEmpty) {
      debugPrint('❌ Invalid Menu Item: Empty ID');
      return false;
    }

    if (menuItem.name.isEmpty) {
      debugPrint('❌ Invalid Menu Item: Empty Name');
      return false;
    }

    if (menuItem.price <= 0) {
      debugPrint('❌ Invalid Menu Item: Invalid Price');
      return false;
    }

    return true;
  }

  void _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CustomerDashboardState> emit,
  ) {
    final currentState = state;
    if (currentState is RestaurantDetailsLoaded) {
      final updatedCartItems = List<CartItemEntity>.from(currentState.cartItems)
        ..removeWhere((item) => item.id == event.itemId);

      emit(currentState.copyWith(cartItems: updatedCartItems));
    }
  }

  void _onUpdateCartItemQuantity(
    UpdateCartItemQuantityEvent event,
    Emitter<CustomerDashboardState> emit,
  ) {
    final currentState = state;
    if (currentState is RestaurantDetailsLoaded) {
      final updatedCartItems =
          List<CartItemEntity>.from(currentState.cartItems);

      final itemIndex = updatedCartItems.indexWhere(
        (item) => item.id == event.itemId,
      );

      if (itemIndex != -1) {
        if (event.quantity > 0) {
          updatedCartItems[itemIndex] = updatedCartItems[itemIndex].copyWith(
            quantity: event.quantity,
          );
        } else {
          updatedCartItems.removeAt(itemIndex);
        }

        emit(currentState.copyWith(cartItems: updatedCartItems));
      }
    }
  }

  void _onAddSpecialInstructions(
    AddSpecialInstructionsEvent event,
    Emitter<CustomerDashboardState> emit,
  ) {
    final currentState = state;
    if (currentState is RestaurantDetailsLoaded) {
      final updatedCartItems =
          List<CartItemEntity>.from(currentState.cartItems);

      final itemIndex = updatedCartItems.indexWhere(
        (item) => item.id == event.itemId,
      );

      if (itemIndex != -1) {
        updatedCartItems[itemIndex] = updatedCartItems[itemIndex].copyWith(
          specialInstructions: event.instructions,
        );

        emit(currentState.copyWith(cartItems: updatedCartItems));
      }
    }
  }

  void _onClearCart(
    ClearCartEvent event,
    Emitter<CustomerDashboardState> emit,
  ) {
    final currentState = state;
    if (currentState is RestaurantDetailsLoaded) {
      emit(currentState.copyWith(cartItems: []));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<CustomerDashboardState> emit,
  ) async {
    try {
      emit(CustomerDashboardLoading());
      await _tokenManager.clearAuthData();
      _restaurants.clear();
      emit(LogoutSuccess());
    } catch (e) {
      emit(CustomerDashboardError(
        message: 'Failed to logout: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<CustomerDashboardState> emit,
  ) async {
    if (!_tokenManager.hasValidToken()) {
      await _tokenManager.clearAuthData();
      emit(const CustomerDashboardAuthError(
        message: 'Session expired. Please log in again.',
      ));
    }
  }

  Future<void> _onValidateTableQR(
    ValidateTableQREvent event,
    Emitter<CustomerDashboardState> emit,
  ) async {
    debugPrint('🔍 Validating QR code for restaurant: ${event.restaurantId}');

    if (event.restaurantId.isEmpty) {
      debugPrint("🚨 Error: Restaurant ID is missing during QR validation!");
      event.onError('Restaurant ID is missing. Please restart the app.');
      return;
    }

    if (!_tokenManager.hasValidToken()) {
      event.onError('Session expired. Please log in again.');
      return;
    }

    try {
      final result = await tableRepository.validateTableQR(
        event.restaurantId,
        event.qrData,
      );

      await result.fold(
        (failure) async {
          debugPrint('❌ QR validation failed: ${failure.message}');
          event.onError(failure.message);
        },
        (validationModel) async {
          debugPrint(
              '✅ QR code validated! Table ID: ${validationModel.table.id}');

          if (validationModel.table.status != 'available') {
            event.onError(
                'Table ${validationModel.table.number} is ${validationModel.table.status}');
            return;
          }

          final currentState = state;
          if (currentState is RestaurantDetailsLoaded) {
            final tableEntity = currentState.tables.firstWhere(
              (table) => table.id == validationModel.table.id,
              orElse: () => TableEntity(
                id: validationModel.table.id,
                number: validationModel.table.number,
                capacity: validationModel.table.capacity,
                restaurantId: validationModel.table.restaurantId,
                status: validationModel.table.status,
                position: const {'x': 0, 'y': 0},
              ),
            );

            emit(currentState.copyWith(
              selectedTable: tableEntity,
              selectedTableId: validationModel.table.id,
            ));
          }

          event.onSuccess(validationModel.table.id);
        },
      );
    } catch (e) {
      debugPrint('💥 Unexpected error during QR validation: $e');
      event.onError('An unexpected error occurred: $e');
    }
  }
}
