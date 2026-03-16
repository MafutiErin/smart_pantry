import 'package:get_it/get_it.dart';

import 'core/ai/ai_provider_service.dart';
import 'core/cache/ai_summary_cache_service.dart';
import 'core/database/database_helper.dart';
import 'features/inventory/data/datasources/inventory_local_datasource.dart';
import 'features/inventory/data/repositories/inventory_repository_impl.dart';
import 'features/inventory/domain/repositories/inventory_repository.dart';
import 'features/inventory/domain/usecases/add_item.dart';
import 'features/inventory/domain/usecases/get_items.dart';
import 'features/inventory/domain/usecases/delete_item.dart';
import 'features/inventory/presentation/bloc/inventory_bloc.dart';
import 'core/network/dio_client.dart';
import 'features/inventory/data/datasources/product_remote_datasource.dart';
import 'features/inventory/domain/usecases/lookup_product_by_barcode.dart';
import 'core/network/gemini_dio_client.dart';
import 'core/network/openai_dio_client.dart';
import 'features/inventory/data/datasources/llm_remote_datasource.dart';
import 'features/inventory/domain/usecases/suggest_menu_from_pantry.dart';
import 'features/inventory/domain/usecases/suggest_item_details.dart';
import 'features/inventory/domain/usecases/identify_item_from_label.dart';
import 'features/setting/presentation/theme_cubit.dart';
import 'features/setting/presentation/language_cubit.dart';
import 'features/setting/presentation/ai_provider_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /// Database
  sl.registerLazySingleton(() => DatabaseHelper.instance);

  /// Cache services
  sl.registerLazySingleton(() => AiSummaryCacheService());

  /// DataSource
  sl.registerLazySingleton<InventoryLocalDataSource>(
    () => InventoryLocalDataSourceImpl(sl()),
  );

  /// Gemini Dio
  sl.registerLazySingleton(() => GeminiDioClient.create());

  /// OpenAI Dio
  sl.registerLazySingleton(() => OpenAIDioClient.create());

  /// AI Provider service
  sl.registerLazySingleton(() => AiProviderService());

  /// LLM datasource
  sl.registerLazySingleton<LlmRemoteDataSource>(
    () => LlmRemoteDataSourceImpl(sl(), sl(), sl()),
  );

  /// Repository
  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(sl(), sl(), sl(), sl()),
  );

  /// UseCases
  sl.registerLazySingleton(() => GetItems(sl()));
  sl.registerLazySingleton(() => AddItem(sl()));
  sl.registerLazySingleton(() => DeleteItem(sl()));
  sl.registerLazySingleton(() => SuggestMenuFromPantry(sl()));
  sl.registerLazySingleton(() => SuggestItemDetails(sl()));
  sl.registerLazySingleton(() => IdentifyItemFromLabel(sl()));

  /// Bloc
  sl.registerFactory(
    () => InventoryBloc(
      getItemsUseCase: sl(),
      addItemUseCase: sl(),
      deleteItemUseCase: sl(),
      suggestItemDetailsUseCase: sl(),
    ),
  );

  /// Dio
  sl.registerLazySingleton(() => DioClient.create());

  /// Product API datasource
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );

  /// Product API usecase
  sl.registerLazySingleton(() => LookupProductByBarcode(sl()));

  /// Theme and Language Cubits
  sl.registerLazySingleton(() => ThemeCubit());
  sl.registerLazySingleton(() => LanguageCubit());

  /// AI Provider Cubit
  sl.registerLazySingleton(() => AiProviderCubit(sl()));
}
