import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/table_entity.dart';

class TableCard extends StatelessWidget {
  final TableEntity table;
  final bool isSelected;
  final bool requiresQR;
  final VoidCallback onTap;

  const TableCard({
    super.key,
    required this.table,
    this.isSelected = false,
    this.requiresQR = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: table.status == 'available' ? onTap : null,
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getBorderColor(),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Main content
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildTableIcon(),
                        const SizedBox(height: 4),
                        Text(
                          'Table ${table.number}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getTextColor(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${table.capacity} Seats',
                          style: TextStyle(
                            fontSize: 10,
                            color: _getTextColor().withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        _buildStatusBadge(),
                      ],
                    ),
                  ),
                ),

                // QR indicator for available tables
                if (requiresQR && table.status == 'available')
                  _buildQRIndicator(),

                // Selected indicator
                if (isSelected)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableIcon() {
    return Icon(
      Icons.table_restaurant,
      size: 32,
      color: _getIconColor(),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        table.status.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQRIndicator() {
    return Positioned(
      top: 5,
      left: 5,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner,
          size: 10,
          color: Colors.green,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (table.status) {
      case 'available':
        return isSelected ? Colors.green.shade50 : Colors.white;
      case 'reserved':
        return Colors.orange.shade50;
      case 'occupied':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getBorderColor() {
    if (isSelected) return Colors.green;
    switch (table.status) {
      case 'available':
        return Colors.green.shade200;
      case 'reserved':
        return Colors.orange.shade200;
      case 'occupied':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getIconColor() {
    switch (table.status) {
      case 'available':
        return Colors.green;
      case 'reserved':
        return Colors.orange;
      case 'occupied':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getTextColor() {
    switch (table.status) {
      case 'available':
        return Colors.green.shade800;
      case 'reserved':
        return Colors.orange.shade800;
      case 'occupied':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Color _getStatusColor() {
    switch (table.status) {
      case 'available':
        return Colors.green;
      case 'reserved':
        return Colors.orange;
      case 'occupied':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
