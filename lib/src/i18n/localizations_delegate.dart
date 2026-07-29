import 'package:flutter/material.dart';

import 'localizations.dart';

class SelectorLocalizationsDelegate
    extends LocalizationsDelegate<SelectorLocalizations> {
  const SelectorLocalizationsDelegate();

  static const supportedLanguageCodes = <String>{
    'de',
    'en',
    'es',
    'fr',
    'id',
    'ja',
    'ko',
    'pt',
    'vi',
    'zh',
  };

  static const supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('vi'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'),
    Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
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
