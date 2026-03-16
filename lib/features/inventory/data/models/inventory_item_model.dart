import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/inventory_item.dart';

part 'inventory_item_model.g.dart';

@JsonSerializable()
class InventoryItemModel extends InventoryItem {
  const InventoryItemModel({
    super.id,
    required super.name,
    super.barcode,
    required super.category,
    required super.quantity,
    required super.unit,
    super.imagePath,
    super.expiryDate,
    required super.createdAt,
    required super.updatedAt,
    super.notes,
    required super.isFood,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryItemModelToJson(this);

  factory InventoryItemModel.fromMap(Map<String, dynamic> map) {
    return InventoryItemModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      barcode: map['barcode'] as String?,
      category: map['category'] as String,
      quantity: map['quantity'] as int,
      unit: map['unit'] as String,
      imagePath: map['image_path'] as String?,
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      notes: map['notes'] as String?,
      isFood: (map['is_food'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'image_path': imagePath,
      'expiry_date': expiryDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'notes': notes,
      'is_food': isFood ? 1 : 0,
    };
  }

  factory InventoryItemModel.fromEntity(InventoryItem item) {
    return InventoryItemModel(
      id: item.id,
      name: item.name,
      barcode: item.barcode,
      category: item.category,
      quantity: item.quantity,
      unit: item.unit,
      imagePath: item.imagePath,
      expiryDate: item.expiryDate,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      notes: item.notes,
      isFood: item.isFood,
    );
  }
}