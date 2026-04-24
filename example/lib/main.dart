import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'house/buy_page.dart';
import 'house/map_page.dart';
import 'house/rent_page.dart';
import 'house/sell_page.dart';
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
      title: 'Criteria Selector Example',
      theme: theme,
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
        title: const Text('Criteria Selector Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuyPage()),
                );
              },
              child: const Text('Buy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SellPage()),
                );
              },
              child: const Text('Sell'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RentPage()),
                );
              },
              child: const Text('Rent'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );
              },
              child: const Text('On Map'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text('Zillow'),
            ),
          ],
        ),
      ),
    );
  }
}
