import '../../data/datasources/llm_remote_datasource.dart';

class SuggestMenuFromPantry {
  final LlmRemoteDataSource remoteDataSource;

  SuggestMenuFromPantry(this.remoteDataSource);

  Future<String> call(List<String> itemNames, {String userMessage = ''}) {
    return remoteDataSource.suggestMenuFromPantry(itemNames, userMessage);
  }
}
