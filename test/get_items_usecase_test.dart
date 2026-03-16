import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry_inventory/core/error/failures.dart';
import 'package:smart_pantry_inventory/features/inventory/domain/entities/inventory_item.dart';
import 'package:smart_pantry_inventory/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:smart_pantry_inventory/features/inventory/domain/usecases/get_items.dart';

void main() {
  late GetItems usecase;
  late FakeInventoryRepository repository;

  setUp(() {
    repository = FakeInventoryRepository();
    usecase = GetItems(repository);
  });

  test('should return inventory items from repository', () async {
    final result = await usecase();

    expect(result.length, 2);
    expect(result.first.name, 'Egg');
    expect(result.last.name, 'Milk');
  });
}

class FakeInventoryRepository implements InventoryRepository {
  @override
  Future<void> addItem(InventoryItem item) async {}

  @override
  Future<void> deleteItem(int id) async {}

  @override
  Future<List<InventoryItem>> getItems() async {
    return [
      InventoryItem(
        id: 1,
        name: 'Egg',
        barcode: null,
        category: 'Food',
        quantity: 6,
        unit: 'pcs',
        imagePath: null,
        expiryDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: null,
        isFood: true,
      ),
      InventoryItem(
        id: 2,
        name: 'Milk',
        barcode: null,
        category: 'Drink',
        quantity: 1,
        unit: 'bottle',
        imagePath: null,
        expiryDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: null,
        isFood: true,
      ),
    ];
  }

  @override
  Future<void> updateItem(InventoryItem item) async {}

  @override
  Future<Either<Failure, String>> suggestMenuFromPantry(
    List<String> itemNames,
    String userMessage,
  ) async {
    return const Right('Mock menu suggestion');
  }

  @override
  Future<Either<Failure, Map<String, String>>> suggestItemDetails(
    String itemName,
    String? category,
    String? notes,
  ) async {
    return const Right({
      'category': 'Mock Category',
      'duration': '7 days',
      'tips': 'Mock Tips',
    });
  }

  @override
  Future<Either<Failure, Map<String, String>>> identifyItemFromLabel(
    String ocrText,
  ) async {
    return const Right({
      'name': 'Mock Item',
      'category': 'Food',
      'unit': 'pcs',
      'quantity': '1',
      'confidence': '50',
    });
  }
}
