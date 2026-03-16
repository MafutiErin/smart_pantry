import 'package:shared_preferences/shared_preferences.dart';

import 'ai_provider.dart';

class AiProviderService {
  static const String providerKey = 'aiProvider';

  Future<AiProvider> getProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(providerKey) ?? AiProvider.gemini.name;
    return aiProviderFromString(value);
  }

  Future<void> setProvider(AiProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(providerKey, provider.name);
  }
}
