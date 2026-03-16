import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_pantry_inventory/features/inventory/domain/entities/inventory_item.dart';
import 'package:smart_pantry_inventory/features/inventory/domain/usecases/add_item.dart';
import 'package:smart_pantry_inventory/features/inventory/domain/usecases/get_items.dart';
import 'package:smart_pantry_inventory/features/inventory/domain/usecases/delete_item.dart';
import 'package:smart_pantry_inventory/features/inventory/domain/usecases/suggest_item_details.dart';
import 'package:smart_pantry_inventory/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:smart_pantry_inventory/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:smart_pantry_inventory/features/inventory/presentation/bloc/inventory_state.dart';

// Mock classes
class MockGetItemsUseCase extends Mock implements GetItems {}

class MockAddItemUseCase extends Mock implements AddItem {}

class MockDeleteItemUseCase extends Mock implements DeleteItem {}

class MockSuggestItemDetailsUseCase extends Mock
    implements SuggestItemDetails {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      InventoryItem(
        id: 0,
        name: 'Test Item',
        barcode: 'test',
        category: 'Test',
        quantity: 0,
        unit: 'pcs',
        imagePath: null,
        expiryDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: null,
        isFood: false,
      ),
    );
  });

  late InventoryBloc inventoryBloc;
  late MockGetItemsUseCase mockGetItemsUseCase;
  late MockAddItemUseCase mockAddItemUseCase;
  late MockDeleteItemUseCase mockDeleteItemUseCase;
  late MockSuggestItemDetailsUseCase mockSuggestItemDetailsUseCase;

  setUp(() {
    mockGetItemsUseCase = MockGetItemsUseCase();
    mockAddItemUseCase = MockAddItemUseCase();
    mockDeleteItemUseCase = MockDeleteItemUseCase();
    mockSuggestItemDetailsUseCase = MockSuggestItemDetailsUseCase();
    inventoryBloc = InventoryBloc(
      getItemsUseCase: mockGetItemsUseCase,
      addItemUseCase: mockAddItemUseCase,
      deleteItemUseCase: mockDeleteItemUseCase,
      suggestItemDetailsUseCase: mockSuggestItemDetailsUseCase,
    );
  });

  tearDown(() {
    inventoryBloc.close();
  });

  group('InventoryBloc - LoadInventory Event', () {
    final mockItems = [
      InventoryItem(
        id: 1,
        name: 'Tomato',
        barcode: '123456',
        category: 'Food',
        quantity: 5,
        unit: 'pcs',
        imagePath: null,
        expiryDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: 'Fresh tomatoes',
        isFood: true,
      ),
      InventoryItem(
        id: 2,
        name: 'Olive Oil',
        barcode: '789012',
        category: 'Food',
        quantity: 2,
        unit: 'bottle',
        imagePath: null,
        expiryDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notes: null,
        isFood: true,
      ),
    ];

    blocTest<InventoryBloc, InventoryState>(
      'emits [InventoryLoading, InventoryLoaded] when LoadInventory is added',
      setUp: () {
        when(() => mockGetItemsUseCase()).thenAnswer((_) async => mockItems);
      },
      build: () => inventoryBloc,
      act: (bloc) => bloc.add(LoadInventory()),
      expect: () => [
        isA<InventoryLoading>(),
        isA<InventoryLoaded>().having(
          (state) => state.items.length,
          'items length',
          equals(2),
        ),
      ],
      verify: (_) {
        verify(() => mockGetItemsUseCase()).called(1);
      },
    );

    blocTest<InventoryBloc, InventoryState>(
      'emits [InventoryLoading, InventoryError] when GetItems throws exception',
      setUp: () {
        when(
          () => mockGetItemsUseCase(),
        ).thenThrow(Exception('Database error'));
      },
      build: () => inventoryBloc,
      act: (bloc) => bloc.add(LoadInventory()),
      expect: () => [
        isA<InventoryLoading>(),
        isA<InventoryError>().having(
          (state) => state.message,
          'error message',
          contains('Database error'),
        ),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'emits InventoryLoaded with empty list when no items exist',
      setUp: () {
        when(() => mockGetItemsUseCase()).thenAnswer((_) async => []);
      },
      build: () => inventoryBloc,
      act: (bloc) => bloc.add(LoadInventory()),
      expect: () => [
        isA<InventoryLoading>(),
        isA<InventoryLoaded>().having(
          (state) => state.items.isEmpty,
          'items is empty',
          true,
        ),
      ],
    );
  });

  group('InventoryBloc - AddInventoryItem Event', () {
    final newItem = InventoryItem(
      id: 3,
      name: 'Pasta',
      barcode: null,
      category: 'Food',
      quantity: 3,
      unit: 'pcs',
      imagePath: null,
      expiryDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: null,
      isFood: true,
    );

    final mockItems = [newItem];

    blocTest<InventoryBloc, InventoryState>(
      'emits [InventoryLoaded] when AddInventoryItem is added successfully',
      setUp: () {
        when(() => mockAddItemUseCase(any())).thenAnswer((_) async {});
        when(() => mockGetItemsUseCase()).thenAnswer((_) async => mockItems);
      },
      build: () => inventoryBloc,
      act: (bloc) => bloc.add(AddInventoryItem(newItem)),
      expect: () => [
        isA<InventoryLoaded>().having(
          (state) => state.items.length,
          'items length after add',
          equals(1),
        ),
      ],
      verify: (_) {
        verify(() => mockAddItemUseCase(newItem)).called(1);
        verify(() => mockGetItemsUseCase()).called(1);
      },
    );

    blocTest<InventoryBloc, InventoryState>(
      'emits [InventoryError] when AddInventoryItem throws exception',
      setUp: () {
        when(
          () => mockAddItemUseCase(any()),
        ).thenThrow(Exception('Failed to add item'));
      },
      build: () => inventoryBloc,
      act: (bloc) => bloc.add(AddInventoryItem(newItem)),
      expect: () => [
        isA<InventoryError>().having(
          (state) => state.message,
          'error message',
          contains('Failed to add item'),
        ),
      ],
    );
  });

  group('InventoryBloc - State Transitions', () {
    blocTest<InventoryBloc, InventoryState>(
      'initial state is InventoryInitial',
      build: () => inventoryBloc,
      expect: () => [],
      verify: (bloc) => expect(bloc.state, isA<InventoryInitial>()),
    );

    blocTest<InventoryBloc, InventoryState>(
      'multiple LoadInventory events load items correctly',
      setUp: () {
        when(() => mockGetItemsUseCase()).thenAnswer((_) async => []);
      },
      build: () => inventoryBloc,
      act: (bloc) {
        bloc.add(LoadInventory());
        bloc.add(LoadInventory());
      },
      expect: () => [
        isA<InventoryLoading>(),
        isA<InventoryLoaded>(),
        isA<InventoryLoading>(),
        isA<InventoryLoaded>(),
      ],
    );
  });
}
