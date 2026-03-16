import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/network/dio_client.dart';
import '../models/product_lookup_model.dart';

const String _productCacheBoxName = 'product_lookup_cache';

abstract class ProductRemoteDataSource {
  Future<ProductLookupModel> getProductByBarcode(String barcode);
  Future<void> initCache();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient dioClient;
  late Box<String> _cacheBox;
  bool _initialized = false;

  ProductRemoteDataSourceImpl(this.dioClient);

  @override
  Future<void> initCache() async {
    if (_initialized) return;

    try {
      _cacheBox = await Hive.openBox<String>(_productCacheBoxName);
      _initialized = true;
    } catch (e) {
      // Cache initialization failed, continue without cache
    }
  }

  @override
  Future<ProductLookupModel> getProductByBarcode(String barcode) async {
    await initCache();

    // Check cache first
    final cacheKey = 'barcode_$barcode';
    if (_initialized && _cacheBox.containsKey(cacheKey)) {
      try {
        final cachedJson = _cacheBox.get(cacheKey);
        if (cachedJson != null) {
          return ProductLookupModel.fromJson(
            Map<String, dynamic>.from(
              Map<String, dynamic>.from(
                {"product_name": cachedJson} as Map<String, dynamic>,
              ),
            ),
          );
        }
      } catch (e) {
        // If cache read fails, continue with API call
      }
    }

    // Fetch from API if not in cache
    try {
      final response = await dioClient.dio.get(
        '/product/$barcode',
        queryParameters: {'fields': 'product_name,brands,quantity'},
      );

      final result = ProductLookupModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Cache the result
      if (_initialized && result.product?.productName != null) {
        try {
          _cacheBox.put(cacheKey, result.product!.productName!);
        } catch (e) {
          // Cache write failed, continue
        }
      }

      return result;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? 'Network error',
      );
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
