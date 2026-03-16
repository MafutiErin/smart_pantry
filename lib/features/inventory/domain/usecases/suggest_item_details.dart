import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/inventory_repository.dart';

class SuggestItemDetails {
  final InventoryRepository repository;

  SuggestItemDetails(this.repository);

  Future<Either<Failure, Map<String, String>>> call(
    String itemName,
    String? category,
    String? notes,
  ) async {
    return await repository.suggestItemDetails(itemName, category, notes);
  }
}
