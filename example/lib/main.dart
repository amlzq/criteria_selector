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
    final theme = baseTheme.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        // 全局筛选条样式
        // 通过 Theme.of(context).extension<DropselectTabBarTheme>()! 获取
        DropselectTabBarTheme(
          // labelColor: Colors.yellow,
          // overlayStyle: DropdownOverlayStyle(
          // backgroundColor: Colors.yellow[100],
          // maxHeightFactor: 0.7,
          // ),
          //  DropdownOverlayStyle(),
          selectorTheme: SelectorThemeData(
            baseTheme,
            actionBarTheme: SelectorActionBarTheme(
              resetText: '重置',
              applyText: '确认',
            ),
            // backgroundColor: Colors.amber[300],
            // radioTheme: RadioThemeData(
            //   fillColor: MaterialStateProperty.all(Colors.orange),
            // ),
            // checkboxTheme: CheckboxThemeData(
            //   fillColor: MaterialStateProperty.all(Colors.orange),
            // ),
          ),
        ),
      ],
    );
    return MaterialApp(
      title: AppLocalizations.of(context)?.appName ?? '',
      theme: theme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)?.appName ?? ''),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)?.realEstate ?? '',
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
                  child: const Text('Zillow'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LeyoujiaPage()),
                    );
                  },
                  child: Text(AppLocalizations.of(context)?.leyoujia ?? ''),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
