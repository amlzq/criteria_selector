import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Tests that the deprecated `SelectorLocalizationsDelegate` alias resolves to
// `SelectLocalizationsDelegate` and that the delegate loads the expected
// localization object.
//
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

void main() {
  const delegate = SelectLocalizationsDelegate();

  group('SelectLocalizationsDelegate', () {
    test('supports the primary language codes', () {
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('zh')), isTrue);
      expect(delegate.isSupported(const Locale('de')), isTrue);
      expect(delegate.isSupported(const Locale('xx')), isFalse);
    });

    test('does not reload on locale changes', () {
      expect(
        delegate.shouldReload(
          delegate as LocalizationsDelegate<SelectLocalizations>,
        ),
        isFalse,
      );
    });

    test('loads a SelectLocalizations instance', () async {
      final loaded = await delegate.load(const Locale('en'));
      expect(loaded, isA<SelectLocalizations>());
      expect(loaded.locale, const Locale('en'));
    });

    test('exposes the supported locale list', () {
      expect(SelectLocalizationsDelegate.supportedLocales, isNotEmpty);
      expect(
        SelectLocalizationsDelegate.supportedLocales,
        contains(const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        )),
      );
    });

    test(
        'deprecated SelectorLocalizationsDelegate alias resolves to '
        'SelectLocalizationsDelegate', () {
      const SelectLocalizationsDelegate newName = SelectLocalizationsDelegate();
      const SelectorLocalizationsDelegate oldName =
          SelectorLocalizationsDelegate();
      expect(oldName, same(newName));
    });
  });
}
