import '../repositories/inventory_repository.dart';

class DeleteItem {
  final InventoryRepository repository;

  DeleteItem(this.repository);

  Future<void> call(int itemId) async {
    await repository.deleteItem(itemId);
  }
}
