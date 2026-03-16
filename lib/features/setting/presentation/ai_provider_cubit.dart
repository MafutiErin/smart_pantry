import 'package:flutter_bloc/flutter_bloc.dart';
 
import '../../../core/ai/ai_provider.dart';
import '../../../core/ai/ai_provider_service.dart';

class AiProviderCubit extends Cubit<AiProvider> {
  final AiProviderService service;

  AiProviderCubit(this.service) : super(AiProvider.gemini);

  Future<void> loadProvider() async {
    final provider = await service.getProvider();
    emit(provider);
  }

  Future<void> setProvider(AiProvider provider) async {
    await service.setProvider(provider);
    emit(provider);
  }
}
