import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/entity/cart_item_entity.dart';

class CartItemTile extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: IntrinsicWidth(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildItemImage(),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: _buildItemDetails(),
                  ),
                  const SizedBox(width: 8),
                  _buildQuantityControls(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        imageUrl: item.image ?? '',
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(
            Icons.fastfood,
            color: Colors.grey,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildItemDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₹${item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 6),
            _buildVegNonVegIndicator(),
          ],
        ),
        if (item.specialInstructions != null) _buildSpecialInstructions(),
      ],
    );
  }

  Widget _buildVegNonVegIndicator() {
    if (item.isVegetarian == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: item.isVegetarian! ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: item.isVegetarian! ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 2),
          Text(
            item.isVegetarian! ? 'Veg' : 'Non-Veg',
            style: TextStyle(
              fontSize: 6,
              fontWeight: FontWeight.w500,
              color: item.isVegetarian! ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialInstructions() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'Special: ${item.specialInstructions}',
        style: const TextStyle(
          fontSize: 8,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconButton(
            icon: Icons.remove,
            color: Colors.red,
            onPressed: item.quantity > 1 ? onDecrement : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          _buildIconButton(
            icon: Icons.add,
            color: Colors.green,
            onPressed: onIncrement,
          ),
          _buildIconButton(
            icon: Icons.delete_outline,
            color: Colors.red,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
      iconSize: 16,
      constraints: const BoxConstraints(
        minWidth: 24,
        minHeight: 24,
        maxWidth: 32,
        maxHeight: 32,
      ),
      padding: const EdgeInsets.all(2),
    );
  }
}
