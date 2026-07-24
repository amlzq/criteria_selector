import 'package:flutter/material.dart';

import 'localizations.dart';

class SelectorLocalizationsDelegate
    extends LocalizationsDelegate<SelectorLocalizations> {
  const SelectorLocalizationsDelegate();

  static const supportedLanguageCodes = <String>{
    'en',
    'zh',
    'es',
    'pt',
    'id',
    'vi',
    'fr',
    'de',
    'ja',
    'ko',
  };

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
    Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'),
    Locale('es'),
    Locale('pt'),
    Locale('id'),
    Locale('vi'),
    Locale('fr'),
    Locale('de'),
    Locale('ja'),
    Locale('ko'),
  ];

  @override
  bool isSupported(Locale locale) {
    // As long as the primary language code is supported,
    // it will automatically perform granular matching internally based on scriptCode and countryCode.
    return supportedLanguageCodes.contains(locale.languageCode);
  }

  @override
  Future<SelectorLocalizations> load(Locale locale) async {
    return SelectorLocalizations(locale);
  }

  @override
  bool shouldReload(
      covariant LocalizationsDelegate<SelectorLocalizations> old) {
    return false;
  }
}
