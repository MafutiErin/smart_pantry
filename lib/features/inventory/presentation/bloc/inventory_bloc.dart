import 'package:flutter_bloc/flutter_bloc.dart';

//import '../../domain/entities/inventory_item.dart';
import '../../domain/usecases/add_item.dart';
import '../../domain/usecases/get_items.dart';
import '../../domain/usecases/delete_item.dart';
import '../../domain/usecases/suggest_item_details.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetItems getItemsUseCase;
  final AddItem addItemUseCase;
  final DeleteItem deleteItemUseCase;
  final SuggestItemDetails suggestItemDetailsUseCase;

  InventoryBloc({
    required this.getItemsUseCase,
    required this.addItemUseCase,
    required this.deleteItemUseCase,
    required this.suggestItemDetailsUseCase,
  }) : super(InventoryInitial()) {
    on<LoadInventory>(_onLoadInventory);
    on<AddInventoryItem>(_onAddInventoryItem);
    on<DeleteInventoryItem>(_onDeleteInventoryItem);
    on<SuggestItemDetailsEvent>(_onSuggestItemDetails);
  }

  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());

    try {
      final items = await getItemsUseCase();
      emit(InventoryLoaded(items));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onAddInventoryItem(
    AddInventoryItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await addItemUseCase(event.item);

      final items = await getItemsUseCase();
      emit(InventoryLoaded(items));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onDeleteInventoryItem(
    DeleteInventoryItem event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await deleteItemUseCase(event.itemId);

      final items = await getItemsUseCase();
      emit(InventoryLoaded(items));
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onSuggestItemDetails(
    SuggestItemDetailsEvent event,
    Emitter<InventoryState> emit,
  ) async {
    emit(ItemDetailsLoading());

    try {
      final result = await suggestItemDetailsUseCase(
        event.itemName,
        event.category,
        event.notes,
      );

      result.fold(
        (failure) => emit(ItemDetailsSuggestionError(failure.toString())),
        (suggestion) => emit(ItemDetailsSuggested(suggestion)),
      );
    } catch (e) {
      emit(ItemDetailsSuggestionError(e.toString()));
    }
  }
}
