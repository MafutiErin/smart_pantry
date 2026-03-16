// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryItemModel _$InventoryItemModelFromJson(Map<String, dynamic> json) =>
    InventoryItemModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      barcode: json['barcode'] as String?,
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unit: json['unit'] as String,
      imagePath: json['imagePath'] as String?,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      notes: json['notes'] as String?,
      isFood: json['isFood'] as bool,
    );

Map<String, dynamic> _$InventoryItemModelToJson(InventoryItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'barcode': instance.barcode,
      'category': instance.category,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'imagePath': instance.imagePath,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'notes': instance.notes,
      'isFood': instance.isFood,
    };
