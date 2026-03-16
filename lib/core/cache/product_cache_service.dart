import 'package:hive_flutter/hive_flutter.dart';

/// Hive box names
const String _productCacheBoxName = 'product_cache';

/// Service for caching product lookup API responses using Hive
/// This reduces redundant API calls for the same barcode
class ProductCacheService {
  static final ProductCacheService _instance = ProductCacheService._internal();

  factory ProductCacheService() {
    return _instance;
  }

  ProductCacheService._internal();

  late Box<String> _productCacheBox;

  /// Initialize the Hive box for product caching
  Future<void> init() async {
    _productCacheBox = await Hive.openBox<String>(_productCacheBoxName);
  }

  /// Get cached product by barcode
  /// Returns null if not found in cache
  String? getProductByBarcode(String barcode) {
    try {
      final key = 'barcode_$barcode';
      return _productCacheBox.get(key);
    } catch (e) {
      return null;
    }
  }

  /// Cache a product lookup result
  /// Uses barcode as the key to enable quick lookups
  Future<void> cacheProduct(String barcode, String productName) async {
    try {
      final key = 'barcode_$barcode';
      await _productCacheBox.put(key, productName);
    } catch (e) {
      // Silently fail, cache is optional
    }
  }

  /// Clear all cached products
  Future<void> clearCache() async {
    try {
      await _productCacheBox.clear();
    } catch (e) {
      // Silently fail
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cached_products': _productCacheBox.length,
      'box_name': _productCacheBoxName,
    };
  }

  /// Close the Hive box
  Future<void> close() async {
    await _productCacheBox.close();
  }
}
