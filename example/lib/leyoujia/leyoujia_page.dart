import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'buy_page.dart';
import 'map_page.dart';
import 'rent_page.dart';
import 'sell_page.dart';

class LeyoujiaPage extends StatelessWidget {
  const LeyoujiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.leyoujia ?? ''),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuyPage()),
                );
              },
              child: Text(AppLocalizations.of(context)?.buy ?? ''),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SellPage()),
                );
              },
              child: Text(AppLocalizations.of(context)?.sell ?? ''),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RentPage()),
                );
              },
              child: Text(AppLocalizations.of(context)?.rent ?? ''),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );
              },
              child: Text(AppLocalizations.of(context)?.onMap ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
