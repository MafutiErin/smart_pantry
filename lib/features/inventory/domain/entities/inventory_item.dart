import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final int? id;
  final String name;
  final String? barcode;
  final String category;
  final int quantity;
  final String unit;
  final String? imagePath;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final bool isFood;

  const InventoryItem({
    this.id,
    required this.name,
    this.barcode,
    required this.category,
    required this.quantity,
    required this.unit,
    this.imagePath,
    this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    required this.isFood,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        barcode,
        category,
        quantity,
        unit,
        imagePath,
        expiryDate,
        createdAt,
        updatedAt,
        notes,
        isFood,
      ];
}