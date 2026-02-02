import 'package:flutter/material.dart';

/// App localization configuration
class Localization {
  // Base locales
  static const Locale uz = Locale('uz');
  static const Locale uzCyrl = Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl');
  static const Locale en = Locale('en');
  static const Locale ru = Locale('ru');

  /// All supported locales
  static const List<Locale> all = [
    uz,
    uzCyrl, // KIRILL QO'SHILDI!
    en,
    ru,
  ];

  /// Get locale display name
  static String getLocaleName(Locale locale) {
    if (locale.languageCode == 'uz' && locale.scriptCode == 'Cyrl') {
      return "Ўзбекча";
    }

    switch (locale.languageCode) {
      case 'uz':
        return "O'zbekcha";
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      default:
        return locale.languageCode;
    }
  }

  /// Get locale flag emoji
  static String getLocaleFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'uz':
        return '🇺🇿';
      case 'en':
        return '🇺🇸';
      case 'ru':
        return '🇷🇺';
      default:
        return '🌍';
    }
  }
}