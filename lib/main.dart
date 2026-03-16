import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'features/inventory/data/datasources/inventory_local_datasource.dart';
import 'features/inventory/domain/entities/inventory_item.dart';
import 'features/inventory/domain/usecases/add_item.dart';
import 'features/inventory/presentation/bloc/inventory_bloc.dart';
import 'features/inventory/presentation/bloc/inventory_event.dart';
import 'features/setting/presentation/theme_cubit.dart';
import 'features/setting/presentation/language_cubit.dart';
import 'features/setting/presentation/ai_provider_cubit.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await di.init();

  // Initialize with sample data if database is empty
  try {
    final localDataSource = di.sl<InventoryLocalDataSource>();
    final existingItems = await localDataSource.getItems();

    if (existingItems.isEmpty) {
      final addItemUseCase = di.sl<AddItem>();
      final now = DateTime.now();

      // Add sample data for demonstration
      await addItemUseCase(
        InventoryItem(
          id: 1,
          name: 'Apple',
          quantity: 5,
          unit: 'pieces',
          category: 'Fruits',
          createdAt: now,
          updatedAt: now,
          isFood: true,
        ),
      );

      await addItemUseCase(
        InventoryItem(
          id: 2,
          name: 'Chicken Breast',
          quantity: 2,
          unit: 'kg',
          category: 'Meat',
          createdAt: now,
          updatedAt: now,
          isFood: true,
        ),
      );

      await addItemUseCase(
        InventoryItem(
          id: 3,
          name: 'Milk',
          quantity: 1,
          unit: 'liter',
          category: 'Dairy',
          createdAt: now,
          updatedAt: now,
          isFood: true,
        ),
      );
    }
  } catch (e) {
    // Silently ignore initialization errors
    debugPrint('Sample data initialization error: $e');
  }

  final themeCubit = ThemeCubit();
  await themeCubit.loadTheme();

  final languageCubit = LanguageCubit();
  await languageCubit.loadLanguage();

  final aiProviderCubit = di.sl<AiProviderCubit>();
  await aiProviderCubit.loadProvider();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: themeCubit),
        BlocProvider<LanguageCubit>.value(value: languageCubit),
        BlocProvider<AiProviderCubit>.value(value: aiProviderCubit),
        BlocProvider(
          create: (_) => di.sl<InventoryBloc>()..add(LoadInventory()),
        ),
      ],
      child: const App(),
    ),
  );
}
