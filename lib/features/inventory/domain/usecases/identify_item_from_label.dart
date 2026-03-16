import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/inventory_repository.dart';

class IdentifyItemFromLabel {
  final InventoryRepository repository;

  IdentifyItemFromLabel(this.repository);

  Future<Either<Failure, Map<String, String>>> call(String ocrText) async {
    return await repository.identifyItemFromLabel(ocrText);
  }
}
