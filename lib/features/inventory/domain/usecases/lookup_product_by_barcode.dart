import '../../data/datasources/product_remote_datasource.dart';
import '../../data/models/product_lookup_model.dart';

class LookupProductByBarcode {
  final ProductRemoteDataSource remoteDataSource;

  LookupProductByBarcode(this.remoteDataSource);

  Future<ProductLookupModel> call(String barcode) {
    return remoteDataSource.getProductByBarcode(barcode);
  }
}