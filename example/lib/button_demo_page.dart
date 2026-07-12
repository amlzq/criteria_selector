import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';

/// Demo page showcasing [DropdownSelectorButton] in its three variants.
class ButtonDemoPage extends StatelessWidget {
  const ButtonDemoPage({super.key});

  static ListSelectorDelegate _delegate() {
    return ListSelectorDelegate(
      entriesLoader: () async => <SelectorEntry<dynamic>>{
        SelectorTextEntry<dynamic>.name(id: 'all', name: 'All'),
        SelectorTextEntry<dynamic>.name(id: 'sale', name: 'For sale'),
        SelectorTextEntry<dynamic>.name(id: 'rent', name: 'For rent'),
        SelectorTextEntry<dynamic>.name(id: 'sold', name: 'Sold'),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DropdownSelectorButton')),
      body: Center(
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownSelectorButton(
              label: 'Filled',
              selectorDelegate: _delegate(),
            ),
            DropdownSelectorButton.elevated(
              label: 'Elevated',
              selectorDelegate: _delegate(),
            ),
            DropdownSelectorButton.outlined(
              label: 'Outlined',
              selectorDelegate: _delegate(),
            ),
            DropdownSelectorButton(
              label: 'With icon',
              icon: const Icon(Icons.filter_alt_outlined),
              selectorDelegate: _delegate(),
            ),
          ],
        ),
      ),
    );
  }
}
