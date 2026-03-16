import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/ai/ai_provider_service.dart';
import '../../../../core/cache/ai_summary_cache_service.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_local_datasource.dart';
import '../datasources/llm_remote_datasource.dart';
import '../models/inventory_item_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDataSource;
  final LlmRemoteDataSource llmRemoteDataSource;
  final AiSummaryCacheService aiSummaryCacheService;
  final AiProviderService aiProviderService;

  InventoryRepositoryImpl(
    this.localDataSource,
    this.llmRemoteDataSource,
    this.aiSummaryCacheService,
    this.aiProviderService,
  );

  @override
  Future<void> addItem(InventoryItem item) async {
    final model = InventoryItemModel.fromEntity(item);
    await localDataSource.addItem(model);
  }

  @override
  Future<List<InventoryItem>> getItems() async {
    final result = await localDataSource.getItems();
    return result;
  }

  @override
  Future<void> updateItem(InventoryItem item) async {
    final model = InventoryItemModel.fromEntity(item);
    await localDataSource.updateItem(model);
  }

  @override
  Future<void> deleteItem(int id) async {
    await localDataSource.deleteItem(id);
  }

  @override
  Future<Either<Failure, String>> suggestMenuFromPantry(
    List<String> itemNames,
    String userMessage,
  ) async {
    try {
      final result = await llmRemoteDataSource.suggestMenuFromPantry(
        itemNames,
        userMessage,
      );
      return Right(result);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> suggestItemDetails(
    String itemName,
    String? category,
    String? notes,
  ) async {
    try {
      final provider = await aiProviderService.getProvider();

      final cached = await aiSummaryCacheService.get(
        provider: provider,
        itemName: itemName,
        category: category,
        notes: notes,
      );

      if (cached != null && cached.isNotEmpty) {
        return Right(cached);
      }

      final result = await llmRemoteDataSource.suggestItemDetails(
        itemName,
        category,
        notes,
      );

      try {
        await aiSummaryCacheService.put(
          provider: provider,
          itemName: itemName,
          category: category,
          notes: notes,
          value: result,
        );
      } catch (_) {
        // cache is optional
      }

      return Right(result);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> identifyItemFromLabel(
    String ocrText,
  ) async {
    try {
      final result = await llmRemoteDataSource.identifyItemFromLabel(ocrText);
      return Right(result);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
