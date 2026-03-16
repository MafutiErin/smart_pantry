import 'package:json_annotation/json_annotation.dart';

part 'product_lookup_model.g.dart';

@JsonSerializable()
class ProductLookupModel {
  final int status;
  @JsonKey(name: 'status_verbose')
  final String? statusVerbose;
  final String? code;
  final ProductDataModel? product;

  const ProductLookupModel({
    required this.status,
    this.statusVerbose,
    this.code,
    this.product,
  });

  factory ProductLookupModel.fromJson(Map<String, dynamic> json) =>
      _$ProductLookupModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductLookupModelToJson(this);
}

@JsonSerializable()
class ProductDataModel {
  @JsonKey(name: 'product_name')
  final String? productName;

  final String? brands;

  @JsonKey(name: 'quantity')
  final String? packageQuantity;

  const ProductDataModel({
    this.productName,
    this.brands,
    this.packageQuantity,
  });

  factory ProductDataModel.fromJson(Map<String, dynamic> json) =>
      _$ProductDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDataModelToJson(this);
}