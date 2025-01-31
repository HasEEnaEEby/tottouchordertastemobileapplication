import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../view_model/customer_dashboard/customer_dashboard_bloc.dart';
import '../view_model/customer_dashboard/customer_dashboard_event.dart';
import '../view_model/customer_dashboard/customer_dashboard_state.dart';

class CustomerDashboardView extends StatelessWidget {
  const CustomerDashboardView({super.key, required String userName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerDashboardBloc()
        ..add(LoadRestaurantsEvent())
        ..add(LoadProfileEvent()),
      child: BlocBuilder<CustomerDashboardBloc, CustomerDashboardState>(
        builder: (context, state) {
          return Scaffold(
            body: _buildBody(context, state),
            bottomNavigationBar: _buildBottomNavigationBar(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CustomerDashboardState state) {
    if (state is CustomerDashboardLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CustomerDashboardError) {
      return Center(child: Text('Error: ${state.message}'));
    }

    if (state is CustomerDashboardTabChanged) {
      return _getPageForIndex(state.selectedIndex, context);
    }

    return _getPageForIndex(0, context); // Default to first page
  }

  Widget _getPageForIndex(int index, BuildContext context) {
    switch (index) {
      case 0:
        return _buildRestaurantListScreen(context);
      case 1:
        return _buildCustomerProfileScreen(context);
      default:
        return _buildRestaurantListScreen(context);
    }
  }

  Widget _buildRestaurantListScreen(BuildContext context) {
    final state = context.watch<CustomerDashboardBloc>().state;

    if (state is! RestaurantsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Restaurants')),
      body: ListView.builder(
        itemCount: state.restaurants.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(state.restaurants[index]),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Implement navigation to menu screen
              // Navigator.push(...);
            },
          );
        },
      ),
    );
  }

  Widget _buildCustomerProfileScreen(BuildContext context) {
    final state = context.watch<CustomerDashboardBloc>().state;

    if (state is! ProfileLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = state.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: 20),
            Text('Name: ${profile.name}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Email: ${profile.email}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Loyalty Points: ${profile.loyaltyPoints}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            const Text('Favorite Restaurants:'),
            ...profile.favoriteRestaurants
                .map((restaurant) => ListTile(title: Text(restaurant))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile Updated')));
              },
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(
      BuildContext context, CustomerDashboardState state) {
    int currentIndex = 0;
    if (state is CustomerDashboardTabChanged) {
      currentIndex = state.selectedIndex;
    }

    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(Icons.restaurant), label: 'Restaurants'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.orange,
      onTap: (index) {
        context.read<CustomerDashboardBloc>().add(ChangeTabEvent(index: index));
      },
    );
  }
}
