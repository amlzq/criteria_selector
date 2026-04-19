import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector.dart';
import '../selector_entry.dart';
import 'selector_controller.dart';
import 'selector_theme.dart';
import 'widgets/widgets.dart';

/// Horizontal layout: category list on the left and cascading item lists on the right.
/// Tree-structured data with unlimited cascading levels.
///
/// Suitable for multi-level structures like "district" and "subway".
///
/// Behavior notes:
/// - Supports arbitrary depth (category -> child -> grandchild -> ...).
/// - Maintains a focused item per level to drive the cascade columns.
/// - Selection state is stored per level; in multi-selection mode an action bar
///   may be used to apply the final selection.
/// - If an entry's `immediate` is true, selection is applied immediately
///   without requiring the action bar.
class CascadingSelectorView extends StatefulWidget {
  const CascadingSelectorView({
    super.key,
    required this.entries,
    required this.previousSelected,
  });

  final List<SelectorEntry> entries;

  final Set<SelectorEntry>? previousSelected;

  @override
  State<CascadingSelectorView> createState() => CascadingSelectorViewState();
}

class CascadingSelectorViewState extends State<CascadingSelectorView> {
  /// Selected category entry
  // late SelectorCategoryEntry _selectedCategory;

  /// Selected items per level (actual selections)
  final List<SelectorEntries> _selectedItemsPerLevel = [];

  final Map<String, SelectorEntries> _headerSelectedByCategory = {};
  final Map<String, SelectorEntries> _footerSelectedByCategory = {};

  /// Temporarily selected (focused) item per level (usually a parent node)
  /// Terminal nodes do not need to be included in the temporary selection list
  final List<SelectorEntry> _tempSelectedItemPerLevel = [];

  /// Cascading lists: index0 is first-level children, index1 is second-level children, and so on
  final List<List<SelectorEntry>> _cascadeList = [];

  /// Current focused level
  /// 0 means only category nodes are shown; 1 means category + first-level children are shown; and so on
  int _currentLevel = 0;

  final List<ScrollController> _scrollControllers = [];

  SelectorController? controller;

  /// Gradient colors for each level
  late List<Color> _backgroundColors;
  late List<Color> _textColors;

  @override
  void initState() {
    super.initState();
    _initializeSelected(widget.previousSelected);
  }

  @override
  void dispose() {
    _disposeScrollControllers();
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectorController(context);
  }

  @override
  void didUpdateWidget(covariant CascadingSelectorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectorController(context);
  }

  void _updateSelectorController(BuildContext context) {
    if (controller == null) {
      controller = SelectorController.of(context)!;
      controller?.addListener(_handleSelectorControllerTick);

      final theme = SelectorTheme.of(context);

      final categoryBackgroundColor =
          selector?.categoryBackgroundColor ?? theme.backgroundColor;

      final terminalBackgroundColor =
          selector?.terminalBackgroundColor ?? theme.backgroundColorHighest;

      // Calculate max depth and gradient colors
      final maxDepth = _calculateMaxDepth(widget.entries.toSet(), 1);

      _backgroundColors = _calculateGradientColors(
          maxDepth, categoryBackgroundColor, terminalBackgroundColor);
    }
  }

  void _handleSelectorControllerTick() {}

  CascadingSelector? get selector => controller?.selector as CascadingSelector;

  void _initializeSelected(Set<SelectorEntry>? selected) {
    _selectedItemsPerLevel.clear();
    _tempSelectedItemPerLevel.clear();
    _currentLevel = 0;
    _cascadeList.clear();
    _disposeScrollControllers();
    _headerSelectedByCategory.clear();
    _footerSelectedByCategory.clear();

    // Restore selections from selected data
    if (selected?.isNotEmpty == true) {
      _initializeSelectedItemsPerLevel(widget.entries.toSet(), selected, 0);
      _restoreHeaderFooterSelected(widget.entries, selected!);
    }

    _initializeTempSelectedItemPerLevel(0);

    // Scroll to selected items after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedItems();
    });
  }

  SelectorEntries _headerSelectedFor(String categoryId) =>
      _headerSelectedByCategory.putIfAbsent(
          categoryId, () => <SelectorEntry>{});

  SelectorEntries _footerSelectedFor(String categoryId) =>
      _footerSelectedByCategory.putIfAbsent(
          categoryId, () => <SelectorEntry>{});

  void _restoreHeaderFooterSelected(
    List<SelectorEntry> entries,
    Set<SelectorEntry> selected,
  ) {
    final categories = entries.whereType<SelectorCategoryEntry>().toList();
    for (final selectedEntry in selected) {
      if (selectedEntry is! SelectorCategoryEntry) continue;
      final category =
          categories.singleWhereOrNull((e) => e.id == selectedEntry.id);
      if (category == null) continue;

      final selectedHeaderChildren = selectedEntry.header?.children ?? {};
      if (selectedHeaderChildren.isNotEmpty) {
        final restoredHeader = _headerSelectedFor(category.id);
        restoredHeader.clear();
        for (final selectedChild in selectedHeaderChildren) {
          final match = category.header?.children
              ?.singleWhereOrNull((e) => e.id == selectedChild.id);
          if (match != null) restoredHeader.add(match);
        }
      }

      final selectedFooterChildren = selectedEntry.footer?.children ?? {};
      if (selectedFooterChildren.isNotEmpty) {
        final restoredFooter = _footerSelectedFor(category.id);
        restoredFooter.clear();
        for (final selectedChild in selectedFooterChildren) {
          final match = category.footer?.children
              ?.singleWhereOrNull((e) => e.id == selectedChild.id);
          if (match != null) restoredFooter.add(match);
        }
      }
    }
  }

  void _disposeScrollControllers() {
    for (var scrollController in _scrollControllers) {
      scrollController.dispose();
    }
    _scrollControllers.clear();
  }

  void _initializeSelectedItemsPerLevel(
      Set<SelectorEntry>? items, Set<SelectorEntry>? selectedItems, int level) {
    if (items == null ||
        items.isEmpty ||
        selectedItems == null ||
        selectedItems.isEmpty) {
      return;
    }
    _selectedItemsPerLevel.add({});
    for (var selectedItem in selectedItems) {
      final item = items.singleWhereOrNull((e) => e.id == selectedItem.id);
      if (item != null) {
        _selectedItemsPerLevel[level].add(item);
      }
      if (selectedItem.children?.isNotEmpty == true) {
        _initializeSelectedItemsPerLevel(
            item?.children, selectedItem.children, level + 1);
      }
    }
  }

  /// Builds _tempSelectedItemPerLevel from _selectedItemsPerLevel
  void _initializeTempSelectedItemPerLevel(int level) {
    if (level >= _selectedItemsPerLevel.length) {
      return;
    }
    final selectedItems = _selectedItemsPerLevel[level];
    if (selectedItems.isEmpty) {
      return;
    }
    final selectedItem = selectedItems.first;
    _tempSelectedItemPerLevel.add(selectedItem);
    if (selectedItem.hasChildren) {
      _cascadeList.add(selectedItem.children?.toList() ?? []);
      _currentLevel = level;
      _scrollControllers.add(ScrollController());
    }
    _initializeTempSelectedItemPerLevel(level + 1);
  }

  void _scrollToSelectedItems() {
    for (int level = 0; level < _scrollControllers.length; level++) {
      if (_selectedItemsPerLevel[level].isEmpty) continue;
      if (level >= _cascadeList.length) continue;

      final items = _cascadeList[level];
      final firstSelected = _selectedItemsPerLevel[level].first;
      final selectedIndex = items.toList().indexOf(firstSelected);

      if (selectedIndex != -1 && _scrollControllers[level].hasClients) {
        final itemHeight = kSelectorListTileHeight; // Approximate item height
        final targetOffset = selectedIndex * itemHeight;
        final maxScroll = _scrollControllers[level].position.maxScrollExtent;
        final scrollOffset =
            targetOffset > maxScroll ? maxScroll : targetOffset;

        _scrollControllers[level].jumpTo(
          scrollOffset,
          // duration: const Duration(milliseconds: 300),
          // curve: Curves.easeInOut,
        );
      }
    }
  }

  /// Calculate gradient colors for cascade levels
  List<Color> _calculateGradientColors(
      int depth, Color beginColor, Color endColor) {
    if (depth <= 1) {
      return [beginColor];
    }
    final colors = <Color>[];
    for (int i = 0; i < depth; i++) {
      final t = depth == 1 ? 0.0 : i / (depth - 1);
      colors.add(Color.lerp(beginColor, endColor, t)!);
    }
    return colors;
  }

  /// Calculate maximum depth of the tree structure
  int _calculateMaxDepth(Set<SelectorEntry>? items, int currentDepth) {
    int maxDepth = currentDepth;
    for (SelectorEntry item in items ?? []) {
      if (item.hasChildren) {
        final childDepth = _calculateMaxDepth(item.children!, currentDepth + 1);
        if (childDepth > maxDepth) {
          maxDepth = childDepth;
        }
      }
    }
    return maxDepth;
  }

  /// Focused Category Item
  SelectorCategoryEntry get tempSelectedCategory =>
      _tempSelectedItemPerLevel.first as SelectorCategoryEntry;

  /// Selection Mode for category entries
  SelectionMode? get categorySelectionMode => selector?.selectionMode;

  /// Selection Mode for the selected category sub-items
  SelectionMode get childrenSelectionMode => tempSelectedCategory.selectionMode;

  /// Selection Mode for selector.
  /// It is jointly determined by the category selection mode and the sub-item selection mode.
  SelectionMode? get selectorSelectionMode {
    if (SelectionMode.multiple == categorySelectionMode) {
      return SelectionMode.multiple;
    }
    if (widget.entries.firstWhereOrNull(testMultipleItem) != null) {
      return SelectionMode.multiple;
    }
    return SelectionMode.single;
  }

  void _ensureAnySelected(SelectorCategoryEntry category) {
    final anyItem = category.children?.singleWhereOrNull(testAnyItem);
    if (anyItem == null) {
      return;
    }

    while (_selectedItemsPerLevel.isEmpty) {
      _selectedItemsPerLevel.add({});
    }

    final rootSelected = _selectedItemsPerLevel[0];
    rootSelected.add(category);

    while (_selectedItemsPerLevel.length < 2) {
      _selectedItemsPerLevel.add({});
    }

    final firstLevel = _selectedItemsPerLevel[1];
    final hasChildOfCategory = firstLevel.any(
      (e) => e is SelectorChildEntry && e.parentId == category.id,
    );
    if (!hasChildOfCategory) {
      firstLevel.removeWhere(
        (e) => e is SelectorChildEntry && e.parentId == category.id,
      );
      firstLevel.add(anyItem);
    }
  }

  /// Tap handler for a category item
  void _onCategoryItemTap(SelectorCategoryEntry newCategory) {
    final selectionMode = controller?.selectionMode;
    if (SelectionMode.single == selectionMode) {
      // Single-select mode: reset previous selection when switching categories
      _selectedItemsPerLevel.clear();
      _tempSelectedItemPerLevel.clear();
      _cascadeList.clear();
      _disposeScrollControllers();
      _headerSelectedByCategory.clear();
      _footerSelectedByCategory.clear();

      // Select the new category
      _tempSelectedItemPerLevel.add(newCategory);
      _cascadeList.add(tempSelectedCategory.children?.toList() ?? []);
      _currentLevel = 1;
      _scrollControllers.add(ScrollController());

      _ensureAnySelected(newCategory);
    } else {
      // Multi-select mode: keep previous selection and only switch the focused category
      if (_tempSelectedItemPerLevel.isEmpty ||
          _tempSelectedItemPerLevel.firstOrNull is! SelectorCategoryEntry) {
        _tempSelectedItemPerLevel
          ..clear()
          ..add(newCategory);
      } else {
        _tempSelectedItemPerLevel[0] = newCategory;
      }

      while (_selectedItemsPerLevel.isEmpty) {
        _selectedItemsPerLevel.add({});
      }

      final rootSelected = _selectedItemsPerLevel[0];
      if (!rootSelected.contains(newCategory)) {
        rootSelected.add(newCategory);
      }

      _cascadeList
        ..clear()
        ..add(newCategory.children?.toList() ?? []);
      _currentLevel = 1;
      _disposeScrollControllers();
      _scrollControllers.add(ScrollController());
      _ensureAnySelected(newCategory);
    }
    setState(() {});
  }

  /// Tap handler for a middle node
  /// Only selecting a terminal node is an actual selection; otherwise it just expands children
  void _onMiddleItemTap(int cascadeIndex, SelectorEntry item) {
    if (item == _tempSelectedItemPerLevel.lastOrNull) {
      // Re-tapping the same node: no-op
      return;
    }

    final level = cascadeIndex + 1;

    // items.firstWhere((e) => e.isAny).selected = false;

    while (_tempSelectedItemPerLevel.length > level) {
      _tempSelectedItemPerLevel.removeLast();
    }
    _tempSelectedItemPerLevel.add(item);

    // Remove all levels after the current level
    while (_cascadeList.length > level) {
      _cascadeList.removeLast();
      if (_scrollControllers.length > level) {
        _scrollControllers.removeLast().dispose();
      }
    }

    // Expand child nodes
    _cascadeList.add(item.children?.toList() ?? []);
    _currentLevel = level + 1;
    _scrollControllers.add(ScrollController());

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (_scrollControllers.last.hasClients) {
    //     _scrollControllers.last.jumpTo(x);
    //   }
    // });

    setState(() {});
  }

  /// Tap handler for a terminal node
  /// Only selecting a terminal node is an actual selection; otherwise it just expands children
  void _onTerminalItemTap(int cascadeIndex, SelectorChildEntry item) {
    // Jump-level selection for an "Any" node (e.g., selecting the category's "Any" node)
    final level = cascadeIndex + 1;
    if (level < _currentLevel && item.isAny) {
      // Remove all levels after the current level
      while (_selectedItemsPerLevel.length > level) {
        _selectedItemsPerLevel.removeLast();
      }
      while (_cascadeList.length > level) {
        _cascadeList.removeLast();
      }
      while (_tempSelectedItemPerLevel.length > level) {
        _tempSelectedItemPerLevel.removeLast();
      }
      _selectedItemsPerLevel.add({});
      _selectedItemsPerLevel[level].add(item);
      _tempSelectedItemPerLevel.add(item);
      // _deselectedAllChildren(_selectedCategory.children);
      // item.selected = true;

      _currentLevel = level;
      _setStateOrImmediateApply(item);
      return;
    }

    // Ensure the selected-items set for the current level exists
    while ((level) - _selectedItemsPerLevel.length >= 0) {
      _selectedItemsPerLevel.add({});
    }

    final selectedItems =
        _selectedItemsPerLevel[level]; // Selected items for the current level
    if (item.isAny) {
      // "Any" node
      if (SelectionMode.single == childrenSelectionMode) {
        // Single-select mode
        if (selectedItems.contains(item)) {
        } else {
          // Clear selected list
          selectedItems
            ..clear()
            ..add(item);
        }
      } else {
        // Multi-select mode
        if (selectedItems.contains(item)) {
          selectedItems.remove(item);
        } else {
          // Remove items that share the same parent from the selected list
          selectedItems.removeWhere(
              (e) => (e as SelectorTextEntry).parentId == item.parentId);
          selectedItems.add(item);
        }
      }
    } else {
      // Normal node

      // If there is an "Any" node, remove it
      _selectedItemsPerLevel
          .elementAtOrNull(1)
          ?.removeWhere((e) => e is SelectorChildEntry && e.isAny);

      selectedItems.removeWhere((e) =>
          e is SelectorChildEntry && e.parentId == item.parentId && e.isAny);

      if (SelectionMode.single == childrenSelectionMode) {
        // Single-select mode
        if (selectedItems.contains(item)) {
        } else {
          selectedItems
            ..clear()
            ..add(item);
        }
      } else {
        // Multi-select mode
        if (selectedItems.contains(item)) {
          selectedItems.remove(item);
        } else {
          selectedItems.add(item);
        }
      }
    }

    // Keep parent selection state consistent
    if (selectedItems.contains(item)) {
      // If it was a select action, select the parent chain as well
      for (var i = cascadeIndex; i >= 0; i--) {
        _selectedItemsPerLevel[i].add(_tempSelectedItemPerLevel[i]);
      }
    } else {
      // If it was a deselect action and no children are selected, deselect parents as needed
      for (var i = cascadeIndex; i >= 0; i--) {
        final parent = _tempSelectedItemPerLevel[i];
        final sameParentSelected = _selectedItemsPerLevel[i + 1]
            .where((e) => (e as SelectorTextEntry).parentId == parent.id);
        if (sameParentSelected.isEmpty) {
          _selectedItemsPerLevel[i].remove(parent);
        }
      }
      // If the category has no selected children and it has an "Any" child, select that "Any" node
      if (_selectedItemsPerLevel.elementAtOrNull(1)?.isEmpty == true) {
        _selectedItemsPerLevel.elementAtOrNull(0)?.add(tempSelectedCategory);
        final anyItem =
            tempSelectedCategory.children?.singleWhereOrNull(testAnyItem);
        if (anyItem != null) {
          _selectedItemsPerLevel.elementAtOrNull(1)?.add(anyItem);
        }
      }
      // Remove empty levels from the selected-items list
      while (_selectedItemsPerLevel.lastOrNull != null &&
          _selectedItemsPerLevel.lastOrNull!.isEmpty) {
        _selectedItemsPerLevel.removeLast();
      }
    }

    _setStateOrImmediateApply(item);
  }

  void _setStateOrImmediateApply(SelectorChildEntry item) {
    if (item.immediate) {
      // No need to tap "Apply"; return result immediately
      _onApplyTap();
    } else {
      // Update UI state
      setState(() {});

      final entries = widget.entries.toSet();
      if (_selectedItemsPerLevel.isNotEmpty) {
        _clippingTree(entries, _selectedItemsPerLevel[0], 0);
      }
      _applyHeaderFooterSelections(entries);
      controller?.change(entries);
    }
  }

  void _onHeaderOrFooterItemTap(
    bool isHeader,
    int chipIndex,
    SelectorChildEntry item,
  ) {
    final selectionMode = isHeader
        ? tempSelectedCategory.headerSelectionMode
        : tempSelectedCategory.footerSelectionMode;
    final selectedItems = isHeader
        ? _headerSelectedFor(tempSelectedCategory.id)
        : _footerSelectedFor(tempSelectedCategory.id);

    final contains = selectedItems.any((e) => e.id == item.id);
    if (SelectionMode.single == selectionMode) {
      if (contains) {
        selectedItems.removeWhere((e) => e.id == item.id);
      } else {
        selectedItems
          ..clear()
          ..add(item);
      }
    } else {
      if (contains) {
        selectedItems.removeWhere((e) => e.id == item.id);
      } else {
        selectedItems.add(item);
      }
    }

    _setStateOrImmediateApply(item);
  }

  /// Removes unselected nodes from the tree (clipping)
  void _clippingTree(
    Set<SelectorEntry>? items,
    Set<SelectorEntry>? selectedItems,
    int level,
  ) {
    if (items == null ||
        items.isEmpty ||
        selectedItems == null ||
        selectedItems.isEmpty) {
      return;
    }
    items.removeWhere((e) => !selectedItems.contains(e));
    if (level + 1 >= _selectedItemsPerLevel.length) return;
    for (var item in items) {
      _clippingTree(
        item.children,
        _selectedItemsPerLevel[level + 1],
        level + 1,
      );
    }
  }

  void _onApplyTap() {
    final entries = widget.entries.toSet();
    if (_selectedItemsPerLevel.isNotEmpty) {
      _clippingTree(entries, _selectedItemsPerLevel[0], 0);
    }
    _applyHeaderFooterSelections(entries);
    controller?.apply(entries);
  }

  void _applyHeaderFooterSelections(Set<SelectorEntry> entries) {
    for (final entry in entries) {
      if (entry is! SelectorCategoryEntry) continue;
      final category = entry;

      final headerSelected = _headerSelectedByCategory[category.id] ?? {};
      final headerChildren = category.header?.children;
      if (headerChildren != null) {
        if (headerSelected.isEmpty) {
          headerChildren.clear();
        } else {
          headerChildren
              .removeWhere((e) => !headerSelected.any((s) => s.id == e.id));
        }
      }

      final footerSelected = _footerSelectedByCategory[category.id] ?? {};
      final footerChildren = category.footer?.children;
      if (footerChildren != null) {
        if (footerSelected.isEmpty) {
          footerChildren.clear();
        } else {
          footerChildren
              .removeWhere((e) => !footerSelected.any((s) => s.id == e.id));
        }
      }
    }
  }

  void _onResetTap() {
    final previousSelectedCategoryId = tempSelectedCategory.id;
    _initializeSelected(controller?.resetSelected);
    final newCategory =
        widget.entries.firstWhere((e) => e.id == previousSelectedCategoryId)
            as SelectorCategoryEntry;
    _onCategoryItemTap(newCategory);
    setState(() {});
    controller?.reset();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('_currentLevel=$_currentLevel');

    /// Maximum level for the current category
    final maxLevel = tempSelectedCategory.maxLevel;
    final isMultipleSelectionMode =
        SelectionMode.multiple == tempSelectedCategory.selectionMode;

    final categoryHeader = tempSelectedCategory.header;
    final categoryFooter = tempSelectedCategory.footer;
    final headerSelected = _headerSelectedFor(tempSelectedCategory.id);
    final footerSelected = _footerSelectedFor(tempSelectedCategory.id);

    final backgroundColor =
        _backgroundColors.isNotEmpty ? _backgroundColors[0] : Colors.white;
    // Get selected item color (background color of next level)
    final selectedColor = 0 + 1 < _backgroundColors.length
        ? _backgroundColors[0 + 1]
        : Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category list (left)
              Container(
                width: kSelectorCategoryTileWidth,
                color: backgroundColor,
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: widget.entries.length,
                  itemBuilder: (context, index) {
                    final item = widget.entries[index] as SelectorCategoryEntry;
                    final selected = item.id == tempSelectedCategory.id;
                    return SelectorListTile(
                      label: item.name ?? '',
                      onTap: () => _onCategoryItemTap(item),
                      selected: selected,
                      selectedTileColor: selectedColor,
                      enabled: item.enabled,
                    );
                  },
                ),
              ),
              // Children lists (right)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (categoryHeader != null &&
                        categoryHeader.children != null)
                      SelectorChipBar(
                        label: categoryHeader.name,
                        items: categoryHeader.children!.toList(),
                        selectedItems: headerSelected,
                        onItemTap: (index, item) => _onHeaderOrFooterItemTap
                            .call(true, index, item as SelectorChildEntry),
                      ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            List.generate(_cascadeList.length, (cascadeIndex) {
                          final items = _cascadeList[cascadeIndex];
                          final level = cascadeIndex + 1;
                          final selectedItems =
                              _selectedItemsPerLevel.elementAtOrNull(level) ??
                                  {};
                          final isMiddleLevel = level < _currentLevel;
                          // Focused item at the current level
                          final focusedItem =
                              _tempSelectedItemPerLevel.elementAtOrNull(level);
                          // Get background color for this level
                          final bgColor = level < _backgroundColors.length
                              ? _backgroundColors[level]
                              : Colors.white;
                          // Get selected item color (background color of next level)
                          final selectedColor =
                              level + 1 < _backgroundColors.length
                                  ? _backgroundColors[level + 1]
                                  : Colors.white;
                          return Flexible(
                            child: ColoredBox(
                              color: bgColor,
                              child: ListView.builder(
                                physics: const ClampingScrollPhysics(),
                                controller: _scrollControllers[cascadeIndex],
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item =
                                      items[index] as SelectorTextEntry;
                                  if (!item.hasChildren && item.enabled) {
                                    // && level == maxLevel - 1
                                    final selected =
                                        selectedItems.contains(item);
                                    if (SelectionMode.single ==
                                        childrenSelectionMode) {
                                      return SelectorRadioListTile(
                                        label: item.name ?? '',
                                        selected: selected,
                                        radioBuilder: selector?.radioBuilder,
                                        enabled: item.enabled,
                                        onTap: () {
                                          _onTerminalItemTap.call(
                                              cascadeIndex, item);
                                        },
                                      );
                                    } else {
                                      return SelectorCheckboxListTile(
                                        label: item.name ?? '',
                                        checked: selected,
                                        checkboxBuilder:
                                            selector?.checkboxBuilder,
                                        enabled: item.enabled,
                                        onTap: () => _onTerminalItemTap.call(
                                            cascadeIndex, item),
                                      );
                                    }
                                  } else {
                                    final selected = _tempSelectedItemPerLevel
                                        .contains(item);
                                    final selectedCount = _selectedItemsPerLevel
                                            .elementAtOrNull(level + 1)
                                            ?.where((e) =>
                                                e is SelectorChildEntry &&
                                                e.parentId == item.id)
                                            .length ??
                                        0;
                                    return SelectorListTile(
                                      label: item.name ?? '',
                                      selected: selected,
                                      // selectedColor: selectedColor,
                                      selectedTileColor: selectedColor,
                                      badge: selectedCount > 0
                                          ? selectedCount.toString()
                                          : null,
                                      enabled: item.enabled,
                                      onTap: () => _onMiddleItemTap.call(
                                          cascadeIndex, item),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    if (categoryFooter != null &&
                        categoryFooter.children != null)
                      SelectorChipBar(
                        label: categoryFooter.name,
                        items: categoryFooter.children!.toList(),
                        selectedItems: footerSelected,
                        onItemTap: (index, item) => _onHeaderOrFooterItemTap
                            .call(false, index, item as SelectorChildEntry),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (SelectionMode.multiple == selectorSelectionMode)
          selector?.actionBarBuilder?.call(
                context,
                onResetTap: _onResetTap,
                onApplyTap: _onApplyTap,
              ) ??
              SelectorActionBar(
                resetText: selector?.actionBarTheme?.resetText,
                applyText: selector?.actionBarTheme?.applyText,
                resetFlex: selector?.actionBarTheme?.resetFlex,
                applyFlex: selector?.actionBarTheme?.applyFlex,
                onResetTap: _onResetTap,
                onApplyTap: _onApplyTap,
              ),
      ],
    );
  }
}

// class _CascadingSelectorDefaults extends SelectorThemeData {
//   _CascadingSelectorDefaults(this.context) : super();

//   final BuildContext context;
//   late final ColorScheme _colors = Theme.of(context).colorScheme;
//   late final TextTheme _textTheme = Theme.of(context).textTheme;

//   @override
//   Color? get selectedColor => _colors.primary;

//   @override
//   Color? get categoryBackgroundColor => _colors.surfaceContainer;

//   @override
//   Color? get terminalBackgroundColor => _colors.surfaceContainerHighest;
// }

class CascadingSelectorSkeleton extends StatelessWidget {
  const CascadingSelectorSkeleton({
    super.key,
    this.backgroundColor,
  });

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        backgroundColor ?? SelectorTheme.of(context).backgroundColor;
    final random = Random();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: kSelectorCategoryTileWidth,
                color: effectiveBackgroundColor,
                child: SkeletonBox(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 10,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return SkeletonTile(
                        height: kSelectorListTileHeight,
                        borderRadius: BorderRadius.circular(4),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 6);
                    },
                  ),
                ),
              ),
              Flexible(
                child: ColoredBox(
                  color: effectiveBackgroundColor,
                  child: SkeletonBox(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 15,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return SkeletonTile(
                          random: random,
                          widthUsed: kSelectorCategoryTileWidth + 30,
                          height: kSelectorListTileHeight,
                          borderRadius: BorderRadius.circular(4),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 6);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SelectorActionBarSkeleton(),
      ],
    );
  }
}
