import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/app_strings.dart';

class LanguageCubit extends Cubit<AppLanguage> {
  static const String languageKey = 'appLanguage';

  LanguageCubit() : super(AppLanguage.thai);

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(languageKey) ?? 'th';
    final language = langCode == 'en' ? AppLanguage.english : AppLanguage.thai;
    AppStrings.setLanguage(language);
    emit(language);
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = language == AppLanguage.english ? 'en' : 'th';
    await prefs.setString(languageKey, langCode);
    AppStrings.setLanguage(language);
    emit(language);
  }

  void detectAndSetLanguage(String text) {
    final detectedLanguage = AppStrings.detectLanguage(text);
    emit(detectedLanguage);
  }
}
