class InventoryItemUi {
  final String name;
  final int quantity;
  final String category;
  final String unit;
  final String? note;

  const InventoryItemUi({
    required this.name,
    required this.quantity,
    required this.category,
    required this.unit,
    this.note,
  });
}