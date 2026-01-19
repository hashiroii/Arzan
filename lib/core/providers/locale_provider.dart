import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'selected_locale';
  
  LocaleNotifier() : super(_getSystemLocale()) {
    _loadSavedLocale();
  }

  static Locale _getSystemLocale() {
    final systemLocale = PlatformDispatcher.instance.locale;
    if (AppConstants.supportedLanguages.contains(systemLocale.languageCode)) {
      return systemLocale;
    }
    return const Locale(AppConstants.defaultLanguage);
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);
      if (savedLocaleCode != null && 
          AppConstants.supportedLanguages.contains(savedLocaleCode)) {
        state = Locale(savedLocaleCode);
      }
    } catch (e) {
      // If loading fails, use system locale
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (AppConstants.supportedLanguages.contains(locale.languageCode)) {
      state = locale;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_localeKey, locale.languageCode);
      } catch (e) {
        // If saving fails, continue with locale change
      }
    }
  }

  void setLocaleFromString(String languageCode) {
    if (AppConstants.supportedLanguages.contains(languageCode)) {
      setLocale(Locale(languageCode));
    }
  }
}
