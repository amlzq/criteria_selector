[简体中文](https://github.com/amlzq/criteria_selector/blob/main/README_ZH_HANS.md)

# CriteriaSelector
A multi-dimensional Condition Selector.
A typical use case is a list filtering selector.

## Features

- TabBar-like filter bar that shows a dropdown overlay panel for each tab.
- Built-in selector layouts: CascadingSelector, GridSelector, FlattenSelector, and ListSelector.
- Supports single & multiple selection, an "Any" entry, and immediate-apply entries.
- Supports custom range inputs (min/max) via `SelectorRangeEntry.custom`.
- Async data loading with optional skeleton placeholders (`dataFetcher` + `skeletonBuilder`).
- Customizable UI via `DropselectTabBarTheme` and `SelectorThemeData`, plus custom action bars and tile themes.

### Selector Types

| GridSelector | FlattenSelector | ListSelector | ListSelector |
| --- | --- | --- | --- |
| ![GridSelector](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/atx/price.gif) | ![GridSelector](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/atx/rooms.gif) | ![FlattenSelector](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/atx/more.gif) | ![SortSelector](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/atx/sort.gif) |

## Getting started

### Install

Add the dependency:

```bash
flutter pub add criteria_selector
```

Then fetch packages:

```bash
flutter pub get
```

### Import

```dart
import 'package:criteria_selector/criteria_selector.dart';
```

## Usage

```dart
import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: CriteriaSelectorDemoPage()));
}

class CriteriaSelectorDemoPage extends StatefulWidget {
  const CriteriaSelectorDemoPage({super.key});

  @override
  State<CriteriaSelectorDemoPage> createState() => _CriteriaSelectorDemoPageState();
}

class _CriteriaSelectorDemoPageState extends State<CriteriaSelectorDemoPage> {
  DropselectResult? _lastApplied;

  Future<SelectorEntries> _fetchPrice() async {
    return {
      SelectorCategoryEntry(
        id: 'price',
        name: 'Price',
        children: {
          SelectorRangeEntry<int, void>.any(parentId: 'price', name: 'Any'),
          SelectorRangeEntry<int, void>(
            parentId: 'price',
            id: '0-100',
            name: '0-100',
            min: 0,
            max: 100,
          ),
          SelectorRangeEntry<int, void>.custom(parentId: 'price', name: 'Custom'),
        },
      ),
    };
  }

  Future<SelectorEntries> _fetchMore() async {
    return {
      SelectorCategoryEntry(
        id: 'more',
        name: 'More',
        selectionMode: SelectionMode.multiple,
        children: {
          SelectorTextEntry.any(parentId: 'more', name: 'Any'),
          SelectorTextEntry(parentId: 'more', id: 'near_subway', name: 'Near subway'),
          SelectorTextEntry(parentId: 'more', id: 'pet_friendly', name: 'Pet friendly'),
        },
      ),
    };
  }

  Future<SelectorEntries> _fetchSort() async {
    return {
      SelectorTextEntry.name(id: 'default', name: 'Default'),
      SelectorTextEntry.name(id: 'price_low', name: 'Price: low to high'),
      SelectorTextEntry.name(id: 'price_high', name: 'Price: high to low'),
    };
  }

  String _resultText(DropselectResult? result) {
    final selected = result?.selected;
    if (selected == null || selected.isEmpty) return '';
    final flattened = selected.flatten();
    final leaf = (flattened != null && flattened.isNotEmpty) ? flattened.last : selected;
    return leaf.map((e) => e.name ?? e.id).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DropselectTabBar(
        tabs: const [
          DropselectTab(label: 'Price'),
          DropselectTab(label: 'More'),
          DropselectTab(label: 'Sort'),
        ],
        selectors: [
          GridSelector(crossAxisCount: 3, dataFetcher: _fetchPrice),
          FlattenSelector(
            crossAxisCount: 3,
            selectionMode: SelectionMode.multiple,
            dataFetcher: _fetchMore,
          ),
          ListSelector(dataFetcher: _fetchSort),
        ],
        onApplied: (result) => setState(() => _lastApplied = result),
      ),
      body: Center(child: Text(_resultText(_lastApplied))),
    );
  }
}
```
