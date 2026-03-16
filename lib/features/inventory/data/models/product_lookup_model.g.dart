// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_lookup_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductLookupModel _$ProductLookupModelFromJson(Map<String, dynamic> json) =>
    ProductLookupModel(
      status: (json['status'] as num).toInt(),
      statusVerbose: json['status_verbose'] as String?,
      code: json['code'] as String?,
      product: json['product'] == null
          ? null
          : ProductDataModel.fromJson(json['product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductLookupModelToJson(ProductLookupModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'status_verbose': instance.statusVerbose,
      'code': instance.code,
      'product': instance.product,
    };

ProductDataModel _$ProductDataModelFromJson(Map<String, dynamic> json) =>
    ProductDataModel(
      productName: json['product_name'] as String?,
      brands: json['brands'] as String?,
      packageQuantity: json['quantity'] as String?,
    );

Map<String, dynamic> _$ProductDataModelToJson(ProductDataModel instance) =>
    <String, dynamic>{
      'product_name': instance.productName,
      'brands': instance.brands,
      'quantity': instance.packageQuantity,
    };
