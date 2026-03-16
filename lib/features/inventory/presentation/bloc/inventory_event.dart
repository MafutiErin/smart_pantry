import '../../domain/entities/inventory_item.dart';

abstract class InventoryEvent {}

class LoadInventory extends InventoryEvent {}

class AddInventoryItem extends InventoryEvent {
  final InventoryItem item;

  AddInventoryItem(this.item);
}

class DeleteInventoryItem extends InventoryEvent {
  final int itemId;

  DeleteInventoryItem({required this.itemId});
}

class SuggestItemDetailsEvent extends InventoryEvent {
  final String itemName;
  final String? category;
  final String? notes;

  SuggestItemDetailsEvent({required this.itemName, this.category, this.notes});
}
