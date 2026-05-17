import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'leyoujia/leyoujia_page.dart';
import 'zillow/house_page.dart';

void main() {
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appName ?? '',
      theme: baseTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        CriteriaSelectorLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale('en'),
        Locale.fromSubtags(languageCode: 'zh'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        ),
        Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'HK',
        ),
      ],
      builder: (context, child) {
        final theme = baseTheme.copyWith(
          extensions: <ThemeExtension<dynamic>>[
            DropselectTabBarTheme(
              selectorTheme: SelectorThemeData(baseTheme),
            ),
          ],
        );
        return Theme(
          data: theme,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n?.appName ?? ''),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              l10n?.realEstate ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HousePage()),
                    );
                  },
                  child: Text(l10n?.zillow ?? ''),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LeyoujiaPage()),
                    );
                  },
                  child: Text(l10n?.leyoujia ?? ''),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
