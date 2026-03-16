import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class AddItem {
  final InventoryRepository repository;

  AddItem(this.repository);

  Future<void> call(InventoryItem item) async {
    await repository.addItem(item);
  }
}