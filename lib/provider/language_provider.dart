import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/string_file.dart';

class LanguageProvider with ChangeNotifier {
  static const String _languageKey = 'selected_language';
  Locale _locale = const Locale('en', 'US');
  SharedPreferences? _prefs;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Locale get locale => _locale;

  Future<void> _loadSavedLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLanguage = _prefs?.getString(_languageKey);
    if (savedLanguage != null) {
      final parts = savedLanguage.split('_');
      if (parts.length == 2) {
        _locale = Locale(parts[0], parts[1]);
        notifyListeners();
      }
    }
  }

  String translate(String key) {
    final localeKey = '${_locale.languageCode}_${_locale.countryCode}';
    if (translations.containsKey(localeKey) &&
        translations[localeKey]!.containsKey(key)) {
      return translations[localeKey]![key]!;
    }
    // Fallback to English
    if (translations['en_US']!.containsKey(key)) {
      return translations['en_US']![key]!;
    }
    return key;
  }


  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _prefs?.setString(_languageKey, '${locale.languageCode}_${locale.countryCode}');
    notifyListeners();
  }

  Future<void> clearLocale() async {
    _locale = const Locale('en', 'US');
    await _prefs?.remove(_languageKey);
    notifyListeners();
  }
} 