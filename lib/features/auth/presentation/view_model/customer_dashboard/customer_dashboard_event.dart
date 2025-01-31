import 'package:equatable/equatable.dart';

abstract class CustomerDashboardEvent extends Equatable {
  const CustomerDashboardEvent();

  @override
  List<Object> get props => [];
}

class ChangeTabEvent extends CustomerDashboardEvent {
  final int index;
  
  const ChangeTabEvent({required this.index});

  @override
  List<Object> get props => [index];
}

class LoadRestaurantsEvent extends CustomerDashboardEvent {}

class LoadProfileEvent extends CustomerDashboardEvent {}