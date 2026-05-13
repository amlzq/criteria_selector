[English](https://github.com/amlzq/criteria_selector/blob/main/README.md)

# CriteriaSelector
一个多维度的条件选择器。
典型使用场景是用于列表筛选的条件选择器。

## 功能特性

- 类似 TabBar 的筛选条：每个 Tab 点击后展示对应的下拉浮层面板。
- 内置多种选择器布局：CascadingSelector、GridSelector、FlattenSelector、ListSelector。
- 支持单选/多选、“不限（Any）”选项，以及即点即应用的选项。
- 通过 `SelectorRangeEntry.custom` 支持自定义区间输入（min/max）。
- 支持异步数据加载，并可选骨架屏占位（`dataFetcher` + `skeletonBuilder`）。
- 通过 `DropselectTabBarTheme` 与 `SelectorThemeData` 定制 UI，同时支持自定义操作栏与 tile 主题。

### 选择器类型

| CascadingSelector | GridSelector | FlattenSelector | ListSelector |
| --- | --- | --- | --- |
| ![CascadingSelector](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/sz/region.gif) | ![GridSelector](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/sz/price.gif) | ![FlattenSelector](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/sz/floor_plan.gif) | ![SortSelector](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/sz/sort.gif) |

## 快速开始

### 安装

添加依赖：

```bash
flutter pub add criteria_selector
```

然后拉取依赖：

```bash
flutter pub get
```

### 引入

```dart
import 'package:criteria_selector/criteria_selector.dart';
```

## 使用示例

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
