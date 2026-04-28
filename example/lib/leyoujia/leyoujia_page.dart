import 'package:flutter/material.dart';

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
        title: const Text('Leyoujia'),
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
          ],
        ),
      ),
    );
  }
}
