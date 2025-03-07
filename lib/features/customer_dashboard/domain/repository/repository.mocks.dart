// ignore: depend_on_referenced_packages
import 'package:mocktail/mocktail.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/customer_dashboard_repository.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/order_repository.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/table_repository.dart';

class MockCustomerDashboardRepository extends Mock
    implements CustomerDashboardRepository {}

class MockOrderRepository extends Mock implements OrderRepository {}

class MockTableRepository extends Mock implements TableRepository {}
