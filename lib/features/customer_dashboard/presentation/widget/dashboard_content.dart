// lib/features/customer_dashboard/presentation/widget/dashboard_content.dart

import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_state.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view/customer_profile_view.dart';

import 'notifications_view.dart';
import 'order_history_view.dart';
import 'support_view.dart';

class DashboardContent extends StatelessWidget {
  final CustomerDashboardState state;
  final String userName;

  const DashboardContent({
    super.key,
    required this.state,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0;
    if (state is CustomerDashboardTabChanged) {
      selectedIndex = (state as CustomerDashboardTabChanged).selectedIndex;
    } else if (state is RestaurantsLoaded) {
      selectedIndex = 0;
    } else if (state is ProfileLoaded) {
      selectedIndex = 1;
    }

    if (state is CustomerDashboardLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return IndexedStack(
      index: selectedIndex,
      children: const [
        CustomerProfileView(),
        OrderHistoryView(),
        NotificationsView(),
        SupportView(),
      ],
    );
  }
}
