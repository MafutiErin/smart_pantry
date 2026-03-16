import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/inventory_item.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getItems();

  Future<void> addItem(InventoryItem item);

  Future<void> updateItem(InventoryItem item);

  Future<void> deleteItem(int id);

  Future<Either<Failure, String>> suggestMenuFromPantry(
    List<String> itemNames,
    String userMessage,
  );

  Future<Either<Failure, Map<String, String>>> suggestItemDetails(
    String itemName,
    String? category,
    String? notes,
  );

  Future<Either<Failure, Map<String, String>>> identifyItemFromLabel(
    String ocrText,
  );
}
