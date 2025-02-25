import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/widget/table_card.dart';

import '../view_model/customer_dashboard/customer_dashboard_bloc.dart';
import '../view_model/customer_dashboard/customer_dashboard_event.dart';

class TableGridView extends StatelessWidget {
  final List<TableEntity> tables;
  final String? selectedTableId;

  const TableGridView({
    super.key,
    required this.tables,
    this.selectedTableId,
  });

  @override
  Widget build(BuildContext context) {
    if (tables.isEmpty) {
      return _buildEmptyTablesView();
    }

    final categorizedTables = _categorizedTables();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select a Table',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...categorizedTables.entries.map((entry) {
            if (entry.value.isEmpty) return const SizedBox.shrink();
            return _buildTableSection(
              context,
              entry.key,
              entry.value,
              _getColorForStatus(entry.key),
            );
          }),
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    );
  }

  Map<String, List<TableEntity>> _categorizedTables() {
    return {
      'Available': tables.where((t) => t.status == 'available').toList(),
      'Reserved': tables.where((t) => t.status == 'reserved').toList(),
      'Occupied': tables.where((t) => t.status == 'occupied').toList(),
      'Unavailable': tables.where((t) => t.status == 'unavailable').toList(),
    };
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Reserved':
        return Colors.orange;
      case 'Occupied':
        return Colors.red;
      case 'Unavailable':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Widget _buildTableSection(BuildContext context, String title,
      List<TableEntity> sectionTables, Color sectionColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: sectionColor,
            ),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: sectionTables.length,
            itemBuilder: (context, index) {
              final table = sectionTables[index];
              return TableCard(
                table: table,
                isSelected: table.id == selectedTableId,
                onTap: () => _handleTableSelection(context, table),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleTableSelection(BuildContext context, TableEntity table) {
    if (table.status == 'available') {
      context.read<CustomerDashboardBloc>().add(
            SelectTableEvent(tableId: table.id),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Table ${table.number} is ${table.status}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildEmptyTablesView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_restaurant_outlined,
            size: 70,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'No Tables Available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Please contact restaurant staff',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(Colors.green, 'Available'),
          _buildLegendItem(Colors.red, 'Occupied'),
          _buildLegendItem(Colors.orange, 'Reserved'),
          _buildLegendItem(Colors.grey, 'Unavailable'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
