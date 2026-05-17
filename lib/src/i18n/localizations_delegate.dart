import 'package:flutter/material.dart';

import 'localizations.dart';

class CriteriaSelectorLocalizationsDelegate
    extends LocalizationsDelegate<CriteriaSelectorLocalizations> {
  const CriteriaSelectorLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // As long as the primary language code is supported,
    // it will automatically perform granular matching internally based on scriptCode and countryCode.
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<CriteriaSelectorLocalizations> load(Locale locale) async {
    return CriteriaSelectorLocalizations(locale);
  }

  @override
  bool shouldReload(
      covariant LocalizationsDelegate<CriteriaSelectorLocalizations> old) {
    return false;
  }
}
