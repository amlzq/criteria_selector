import 'package:flutter/material.dart';

class CriteriaSelectorLocalizations {
  final Locale locale;

  CriteriaSelectorLocalizations(this.locale);

  static CriteriaSelectorLocalizations? of(BuildContext context) {
    return Localizations.of<CriteriaSelectorLocalizations>(
        context, CriteriaSelectorLocalizations);
  }

  // Dynamically compute the best-matching language pack for the current context.
  Map<String, String> get _currentValues {
    final keys = [
      // 1. Highest priority: Full match (e.g., zh_Hans_CN or zh_Hant_TW)
      if (locale.scriptCode != null && locale.countryCode != null)
        '${locale.languageCode}_${locale.scriptCode}_${locale.countryCode}',

      // 2. Second highest priority: Language + Script (e.g., zh_Hans or zh_Hant)
      if (locale.scriptCode != null)
        '${locale.languageCode}_${locale.scriptCode}',

      // 3. Medium priority: Language + Region (e.g., zh_CN or zh_TW)
      if (locale.countryCode != null)
        '${locale.languageCode}_${locale.countryCode}',

      // 4. Low priority: Language only (e.g., zh or en)
      locale.languageCode,
    ];

    // Iterate through the priority list to find the first matching language pack.
    for (final key in keys) {
      if (_localizedValues.containsKey(key)) {
        return _localizedValues[key]!;
      }
    }

    // 5. Final fallback: Default to English if no match is found.
    return _localizedValues['en']!;
  }

  // Business strings are retrieved directly from the computed _currentValues.
  String get reset => _currentValues['reset'] ?? 'Reset';
  String get apply => _currentValues['apply'] ?? 'Apply';
  String get multiple => _currentValues['multiple'] ?? 'Multiple';

  // Extended language resource dictionary
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'reset': 'Reset',
      'apply': 'Apply',
      'multiple': 'Multiple',
    },
    'es': {
      'reset': 'Restablecer',
      'apply': 'Aplicar',
      'multiple': 'Multiple',
    },
    'pt': {
      'reset': 'Redefinir',
      'apply': 'Aplicar',
      'multiple': 'Múltipla',
    },
    'id': {
      'reset': 'Atur Ulang',
      'apply': 'Terapkan',
      'multiple': 'Multi',
    },
    'vi': {
      'reset': 'Đặt lại',
      'apply': 'Áp dụng',
      'multiple': 'Nhiều lựa chọn',
    },
    'fr': {
      'reset': 'Réinitialiser',
      'apply': 'Appliquer',
      'multiple': 'Multiple',
    },
    'de': {
      'reset': 'Zurücksetzen',
      'apply': 'Anwenden',
      'multiple': 'Mehrfach',
    },
    'ja': {
      'reset': 'リセット',
      'apply': '適用',
      'multiple': '複数',
    },
    'ko': {
      'reset': '초기화',
      'apply': '적용',
      'multiple': '다중',
    },
    'zh_Hans': {
      'reset': '重置',
      'apply': '应用',
      'multiple': '多选',
    },
    'zh_Hant': {
      'reset': '重置',
      'apply': '应用',
      'multiple': '多選',
    },
    'zh_Hant_TW': {
      'reset': '重設',
      'apply': '套用',
      'multiple': '多選',
    },
    'zh_Hant_HK': {
      'reset': '重設',
      'apply': '立即搜尋',
      'multiple': '多選',
    },
  };
}
