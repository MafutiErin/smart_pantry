import '../../domain/entities/inventory_item.dart';

abstract class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryItem> items;

  InventoryLoaded(this.items);
}

class InventoryError extends InventoryState {
  final String message;

  InventoryError(this.message);
}

class ItemDetailsLoading extends InventoryState {}

class ItemDetailsSuggested extends InventoryState {
  final Map<String, String> suggestion;

  ItemDetailsSuggested(this.suggestion);
}

class ItemDetailsSuggestionError extends InventoryState {
  final String message;

  ItemDetailsSuggestionError(this.message);
}
