import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/inventory_item.dart';

@RoutePage()
class ItemDetailPage extends StatelessWidget {
  final InventoryItem item;
  final int index;

  const ItemDetailPage({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final heroTag = 'item-header-$index';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Item Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: heroTag,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        item.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: colorScheme.onPrimaryContainer),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.qr_code),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Barcode: ${item.barcode ?? '-'}')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Quantity: ${item.quantity} ${item.unit}'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.category_outlined),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Category: ${item.category}')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes_outlined),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Note: ${item.notes ?? '-'}')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
