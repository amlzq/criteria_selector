import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'leyoujia/leyoujia_page.dart';
import 'playground/playground_page.dart';
import 'zillow/zillow.dart';

void main() {
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    const seedColor = Colors.deepPurple;
    final lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
    final darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appName ?? '',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
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
        final baseTheme = Theme.of(context);
        final theme = baseTheme.copyWith(
          extensions: <ThemeExtension<dynamic>>[
            DropdownSelectorBarTheme(
              overlayStyle:
                  const DropdownOverlayStyle(barrierColor: Colors.black54),
              selectorTheme: SelectorThemeData(baseTheme),
            ),
          ],
        );
        return Theme(
          data: theme,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: MyHomePage(
        themeMode: _themeMode,
        onThemeModeChanged: (mode) {
          setState(() {
            _themeMode = mode;
          });
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

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
        actions: [
          PopupMenuButton<ThemeMode>(
            initialValue: widget.themeMode,
            onSelected: widget.onThemeModeChanged,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ThemeMode.system,
                child: Text(l10n?.themeSystem ?? 'System'),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: Text(l10n?.themeLight ?? 'Light'),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Text(l10n?.themeDark ?? 'Dark'),
              ),
            ],
            icon: const Icon(Icons.brightness_6_outlined),
            tooltip: l10n?.themeMode ?? 'Theme',
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlaygroundPage(),
                  ),
                );
              },
              icon: const Icon(Icons.tune),
              label: const Text('Playground'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                final locale = Localizations.localeOf(context);
                final isZhHans =
                    locale.languageCode == 'zh' && locale.scriptCode == 'Hans';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        isZhHans ? const LeyoujiaPage() : const ZillowPage(),
                  ),
                );
              },
              child: Text(l10n?.realEstate ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
