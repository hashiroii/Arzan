import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale(AppConstants.defaultLanguage));

  void setLocale(Locale locale) {
    if (AppConstants.supportedLanguages.contains(locale.languageCode)) {
      state = locale;
    }
  }

  void setLocaleFromString(String languageCode) {
    if (AppConstants.supportedLanguages.contains(languageCode)) {
      state = Locale(languageCode);
    }
  }
  
  Future<void> reloadTranslations() async {
    state = state;
  }
}
