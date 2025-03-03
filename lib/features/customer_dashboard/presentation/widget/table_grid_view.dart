import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_event.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/widget/qr_code_scanner.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/widget/table_card.dart';

class TableGridView extends StatelessWidget {
  final List<TableEntity> tables;
  final String? selectedTableId;
  final bool requireQRVerification;
  final String restaurantId;

  const TableGridView({
    super.key,
    required this.tables,
    this.selectedTableId,
    this.requireQRVerification = true,
    required this.restaurantId,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select a Table',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                _buildScanQRButton(context),
              ],
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
          const SizedBox(height: 16),
          if (requireQRVerification)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please scan the QR code on your table to verify your selection',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanQRButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _openQRScanner(context),
      icon: const Icon(Icons.qr_code_scanner, size: 16),
      label: const Text('Scan QR'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _openQRScanner(BuildContext context) {
    print("📌 Opening QR Scanner with Restaurant ID: $restaurantId");

    if (restaurantId.isEmpty) {
      print("🚨 Error: Restaurant ID is empty in TableGridView!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurant information is missing. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          print(
              "📌 Navigating to QRCodeScannerView with Restaurant ID: $restaurantId");
          return QRCodeScannerView(
            restaurantId: restaurantId, // ✅ Ensure it's passed correctly
            onTableVerified: (tableId) {
              _handleTableVerified(context, tableId);
            },
          );
        },
      ),
    );
  }

  void _handleTableVerified(BuildContext context, String tableId) {
    print("📌 Scanned Table ID: $tableId");
    print("📌 Available Tables: ${tables.map((t) => t.id).toList()}");

    final tableExists = tables.any((table) => table.id == tableId);

    if (!tableExists) {
      print("🚨 Table ID not found in available tables");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid table QR code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final verifiedTable = tables.firstWhere((table) => table.id == tableId);

    if (verifiedTable.status == 'available') {
      print("✅ Table ${verifiedTable.number} selected");

      context.read<CustomerDashboardBloc>().add(
            SelectTableEvent(tableId: tableId),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Table ${verifiedTable.number} selected successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print("🚫 Table ${verifiedTable.number} is ${verifiedTable.status}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Table ${verifiedTable.number} is ${verifiedTable.status}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
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
                requiresQR: requireQRVerification,
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
      if (requireQRVerification) {
        // Open QR scanner for table verification
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QRCodeScannerView(
              restaurantId: table.restaurantId,
              onTableVerified: (scannedTableId) {
                print("📌 QR Scanned Table ID: $scannedTableId");
                print("📌 Selected Table ID: ${table.id}");

                // Ensure the scanned table ID matches the selected table
                if (scannedTableId == table.id) {
                  context.read<CustomerDashboardBloc>().add(
                        SelectTableEvent(tableId: table.id),
                      );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Table ${table.number} verified and selected'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  print("🚨 Scanned QR does not match selected table!");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('QR code does not match Table ${table.number}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else {
        // Directly select the table without QR verification
        print("✅ Selecting Table ${table.number}");
        context.read<CustomerDashboardBloc>().add(
              SelectTableEvent(tableId: table.id),
            );
      }
    } else {
      print("🚫 Table ${table.number} is ${table.status}");
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
