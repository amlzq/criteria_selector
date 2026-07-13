import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';

import 'house_filters_repository.dart';

class ButtonDemoPage extends StatefulWidget {
  const ButtonDemoPage({super.key});

  @override
  State<ButtonDemoPage> createState() => _ButtonDemoPageState();
}

class _ButtonDemoPageState extends State<ButtonDemoPage> {
  late final HouseFiltersRepository _filtersRepo;

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
  void initState() {
    super.initState();
    _filtersRepo = HouseFiltersRepository();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DropdownSelectorButton')),
      body: Column(
        children: [
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DropdownSelectorButton(
                label: 'Filled',
                selectorDelegate: _delegate(),
                onChanged: (result) {
                  print('onChanged: $result');
                },
                onApplied: (result) {
                  print('onApplied: $result');
                },
                onReset: () {
                  print('onReset');
                },
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
        ],
      ),
    );
  }
}
