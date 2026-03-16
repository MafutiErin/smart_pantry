import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class GetItems {
  final InventoryRepository repository;

  GetItems(this.repository);

  Future<List<InventoryItem>> call() async {
    return await repository.getItems();
  }
}