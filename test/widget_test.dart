import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_pantry_inventory/core/error/failures.dart';
import 'package:smart_pantry_inventory/features/inventory/domain/entities/inventory_item.dart';
import 'package:smart_pantry_inventory/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:smart_pantry_inventory/features/inventory/domain/usecases/add_item.dart';
import 'package:smart_pantry_inventory/features/inventory/domain/usecases/get_items.dart';
import 'package:smart_pantry_inventory/features/inventory/domain/usecases/delete_item.dart';
import 'package:smart_pantry_inventory/features/inventory/domain/usecases/suggest_item_details.dart';
import 'package:smart_pantry_inventory/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:smart_pantry_inventory/features/inventory/presentation/pages/add_item_page.dart';
import 'package:smart_pantry_inventory/features/setting/presentation/theme_cubit.dart';
import 'package:smart_pantry_inventory/features/setting/presentation/language_cubit.dart';

void main() {
  testWidgets('AddItemPage exists', (WidgetTester tester) async {
    final fakeRepo = FakeInventoryRepository();

    // Set large window size for form to fit
    tester.view.physicalSize = const Size(1200, 2000);
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => LanguageCubit()),
          BlocProvider(
            create: (_) => InventoryBloc(
              getItemsUseCase: GetItems(fakeRepo),
              addItemUseCase: AddItem(fakeRepo),
              deleteItemUseCase: DeleteItem(fakeRepo),
              suggestItemDetailsUseCase: SuggestItemDetails(fakeRepo),
            ),
          ),
        ],
        child: const MaterialApp(home: AddItemPage()),
      ),
    );

    // Verify form elements are present
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.byIcon(Icons.save), findsOneWidget);
  });
}

class FakeInventoryRepository implements InventoryRepository {
  @override
  Future<void> addItem(InventoryItem item) async {}

  @override
  Future<void> deleteItem(int id) async {}

  @override
  Future<List<InventoryItem>> getItems() async => [];

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
