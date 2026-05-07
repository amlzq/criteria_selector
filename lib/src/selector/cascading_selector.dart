import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector.dart';
import '../selector_entry.dart';
import '../selector_utils.dart';
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

  /// Selected entries per level (actual selections)
  final List<SelectorEntries> _selectedEntriesPerLevel = [];

  final Map<String, SelectorEntries> _selectedHeaderEntries = {};
  final Map<String, SelectorEntries> _selectedFooterEntries = {};

  /// Temporarily selected (focused) item per level (usually a parent node)
  /// Terminal nodes do not need to be included in the temporary selection list
  final List<SelectorEntry> _tempSelectedEntryPerLevel = [];

  /// Cascading lists: index0 is first-level children, index1 is second-level children, and so on
  final List<List<SelectorEntry>> _cascadingList = [];

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
    _selectedEntriesPerLevel.clear();
    _tempSelectedEntryPerLevel.clear();
    _currentLevel = 0;
    _cascadingList.clear();
    _disposeScrollControllers();
    _selectedHeaderEntries.clear();
    _selectedFooterEntries.clear();

    // Restore selections from selected data
    if (selected?.isNotEmpty == true) {
      _initializeSelectedEntriesPerLevel(widget.entries.toSet(), selected, 0);
      _restoreHeaderFooterSelected(widget.entries, selected!);
    }

    _initializeTempSelectedEntryPerLevel(0);

    // Scroll to selected list item after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedItem();
    });
  }

  SelectorEntries _headerSelectedFor(String categoryId) =>
      _selectedHeaderEntries.putIfAbsent(categoryId, () => <SelectorEntry>{});

  SelectorEntries _footerSelectedFor(String categoryId) =>
      _selectedFooterEntries.putIfAbsent(categoryId, () => <SelectorEntry>{});

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

  void _initializeSelectedEntriesPerLevel(Set<SelectorEntry>? entries,
      Set<SelectorEntry>? selectedEntries, int level) {
    if (entries == null ||
        entries.isEmpty ||
        selectedEntries == null ||
        selectedEntries.isEmpty) {
      return;
    }
    _selectedEntriesPerLevel.add({});
    for (var selectedEntry in selectedEntries) {
      final item = entries.singleWhereOrNull((e) => e.id == selectedEntry.id);
      if (item != null) {
        _selectedEntriesPerLevel[level].add(item);
      }
      if (selectedEntry.children?.isNotEmpty == true) {
        _initializeSelectedEntriesPerLevel(
            item?.children, selectedEntry.children, level + 1);
      }
    }
  }

  /// Builds _tempSelectedEntryPerLevel from _selectedEntriesPerLevel
  void _initializeTempSelectedEntryPerLevel(int level) {
    if (level >= _selectedEntriesPerLevel.length) {
      return;
    }
    final selectedEntries = _selectedEntriesPerLevel[level];
    if (selectedEntries.isEmpty) {
      return;
    }
    final selectedEntry = selectedEntries.first;
    _tempSelectedEntryPerLevel.add(selectedEntry);
    if (selectedEntry.hasChildren) {
      _cascadingList.add(selectedEntry.children?.toList() ?? []);
      _currentLevel = level;
      _scrollControllers.add(ScrollController());
    }
    _initializeTempSelectedEntryPerLevel(level + 1);
  }

  void _scrollToSelectedItem() {
    for (int level = 0; level < _scrollControllers.length; level++) {
      if (_selectedEntriesPerLevel[level].isEmpty) continue;
      if (level >= _cascadingList.length) continue;

      final entries = _cascadingList[level];
      final firstSelected = _selectedEntriesPerLevel[level].first;
      final selectedIndex = entries.toList().indexOf(firstSelected);

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
  int _calculateMaxDepth(Set<SelectorEntry>? entries, int currentDepth) {
    int maxDepth = currentDepth;
    for (SelectorEntry entry in entries ?? []) {
      if (entry.hasChildren) {
        final childDepth =
            _calculateMaxDepth(entry.children!, currentDepth + 1);
        if (childDepth > maxDepth) {
          maxDepth = childDepth;
        }
      }
    }
    return maxDepth;
  }

  /// Focused Category Item
  SelectorCategoryEntry get tempSelectedCategory =>
      _tempSelectedEntryPerLevel.first as SelectorCategoryEntry;

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
    if (widget.entries.firstWhereOrNull(testMultipleElement) != null) {
      return SelectionMode.multiple;
    }
    return SelectionMode.single;
  }

  void _ensureAnySelected(SelectorCategoryEntry category) {
    final anyItem = category.children?.singleWhereOrNull(testAnyElement);
    if (anyItem == null) {
      return;
    }

    while (_selectedEntriesPerLevel.isEmpty) {
      _selectedEntriesPerLevel.add({});
    }

    final rootSelected = _selectedEntriesPerLevel[0];
    rootSelected.add(category);

    while (_selectedEntriesPerLevel.length < 2) {
      _selectedEntriesPerLevel.add({});
    }

    final firstLevel = _selectedEntriesPerLevel[1];
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
  void _onCategoryItemTap(SelectorCategoryEntry newCategoryEntry) {
    final selectionMode = controller?.selectionMode;
    if (SelectionMode.single == selectionMode) {
      // Single-select mode: reset previous selection when switching categories
      _selectedEntriesPerLevel.clear();
      _tempSelectedEntryPerLevel.clear();
      _cascadingList.clear();
      _disposeScrollControllers();
      _selectedHeaderEntries.clear();
      _selectedFooterEntries.clear();

      // Select the new category
      _tempSelectedEntryPerLevel.add(newCategoryEntry);
      _cascadingList.add(tempSelectedCategory.children?.toList() ?? []);
      _currentLevel = 1;
      _scrollControllers.add(ScrollController());

      _ensureAnySelected(newCategoryEntry);
    } else {
      // Multi-select mode: keep previous selection and only switch the focused category
      if (_tempSelectedEntryPerLevel.isEmpty ||
          _tempSelectedEntryPerLevel.firstOrNull is! SelectorCategoryEntry) {
        _tempSelectedEntryPerLevel
          ..clear()
          ..add(newCategoryEntry);
      } else {
        _tempSelectedEntryPerLevel[0] = newCategoryEntry;
      }

      while (_selectedEntriesPerLevel.isEmpty) {
        _selectedEntriesPerLevel.add({});
      }

      final rootSelected = _selectedEntriesPerLevel[0];
      if (!rootSelected.contains(newCategoryEntry)) {
        rootSelected.add(newCategoryEntry);
      }

      _cascadingList
        ..clear()
        ..add(newCategoryEntry.children?.toList() ?? []);
      _currentLevel = 1;
      _disposeScrollControllers();
      _scrollControllers.add(ScrollController());
      _ensureAnySelected(newCategoryEntry);
    }
    setState(() {});
  }

  /// Tap handler for a middle node
  /// Only selecting a terminal node is an actual selection; otherwise it just expands children
  void _onMiddleItemTap(int cascadeIndex, SelectorEntry entry) {
    if (entry == _tempSelectedEntryPerLevel.lastOrNull) {
      // Re-tapping the same node: no-op
      return;
    }

    final level = cascadeIndex + 1;

    // items.firstWhere((e) => e.isAny).selected = false;

    while (_tempSelectedEntryPerLevel.length > level) {
      _tempSelectedEntryPerLevel.removeLast();
    }
    _tempSelectedEntryPerLevel.add(entry);

    // Remove all levels after the current level
    while (_cascadingList.length > level) {
      _cascadingList.removeLast();
      if (_scrollControllers.length > level) {
        _scrollControllers.removeLast().dispose();
      }
    }

    // Expand child nodes
    _cascadingList.add(entry.children?.toList() ?? []);
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
  void _onTerminalItemTap(int cascadeIndex, SelectorChildEntry entry) {
    // Jump-level selection for an "Any" entry (e.g., selecting the category's "Any" entry)
    final level = cascadeIndex + 1;
    if (level < _currentLevel && entry.isAny) {
      // Remove all levels after the current level
      while (_selectedEntriesPerLevel.length > level) {
        _selectedEntriesPerLevel.removeLast();
      }
      while (_cascadingList.length > level) {
        _cascadingList.removeLast();
      }
      while (_tempSelectedEntryPerLevel.length > level) {
        _tempSelectedEntryPerLevel.removeLast();
      }
      _selectedEntriesPerLevel.add({});
      _selectedEntriesPerLevel[level].add(entry);
      _tempSelectedEntryPerLevel.add(entry);
      // _deselectedAllChildren(_selectedCategory.children);
      // item.selected = true;

      _currentLevel = level;
      _setStateOrImmediateApply(entry);
      return;
    }

    // Ensure the selected-items set for the current level exists
    while ((level) - _selectedEntriesPerLevel.length >= 0) {
      _selectedEntriesPerLevel.add({});
    }

    final selectedItems = _selectedEntriesPerLevel[
        level]; // Selected entries for the current level
    if (entry.isAny) {
      // "Any" entry
      if (SelectionMode.single == childrenSelectionMode) {
        // Single-select mode
        if (selectedItems.contains(entry)) {
        } else {
          // Clear selected list
          selectedItems
            ..clear()
            ..add(entry);
        }
      } else {
        // Multi-select mode
        if (selectedItems.contains(entry)) {
          selectedItems.remove(entry);
        } else {
          // Remove items that share the same parent from the selected list
          selectedItems.removeWhere(
              (e) => (e as SelectorTextEntry).parentId == entry.parentId);
          selectedItems.add(entry);
        }
      }
    } else {
      // Normal entry

      // If there is an "Any" entry, remove it
      _selectedEntriesPerLevel
          .elementAtOrNull(1)
          ?.removeWhere((e) => e is SelectorChildEntry && e.isAny);

      selectedItems.removeWhere((e) =>
          e is SelectorChildEntry && e.parentId == entry.parentId && e.isAny);

      if (SelectionMode.single == childrenSelectionMode) {
        // Single-select mode
        if (selectedItems.contains(entry)) {
        } else {
          selectedItems
            ..clear()
            ..add(entry);
        }
      } else {
        // Multi-select mode
        if (selectedItems.contains(entry)) {
          selectedItems.remove(entry);
        } else {
          selectedItems.add(entry);
        }
      }
    }

    // Keep parent selection state consistent
    if (selectedItems.contains(entry)) {
      // If it was a select action, select the parent chain as well
      for (var i = cascadeIndex; i >= 0; i--) {
        _selectedEntriesPerLevel[i].add(_tempSelectedEntryPerLevel[i]);
      }
    } else {
      // If it was a deselect action and no children are selected, deselect parents as needed
      for (var i = cascadeIndex; i >= 0; i--) {
        final parent = _tempSelectedEntryPerLevel[i];
        final sameParentSelected = _selectedEntriesPerLevel[i + 1]
            .where((e) => (e as SelectorTextEntry).parentId == parent.id);
        if (sameParentSelected.isEmpty) {
          _selectedEntriesPerLevel[i].remove(parent);
        }
      }
      // If the category has no selected children and it has an "Any" child, select that "Any" entry
      if (_selectedEntriesPerLevel.elementAtOrNull(1)?.isEmpty == true) {
        _selectedEntriesPerLevel.elementAtOrNull(0)?.add(tempSelectedCategory);
        final anyItem =
            tempSelectedCategory.children?.singleWhereOrNull(testAnyElement);
        if (anyItem != null) {
          _selectedEntriesPerLevel.elementAtOrNull(1)?.add(anyItem);
        }
      }
      // Remove empty levels from the selected-items list
      while (_selectedEntriesPerLevel.lastOrNull != null &&
          _selectedEntriesPerLevel.lastOrNull!.isEmpty) {
        _selectedEntriesPerLevel.removeLast();
      }
    }

    _setStateOrImmediateApply(entry);
  }

  void _setStateOrImmediateApply(SelectorChildEntry entry) {
    if (SelectionMode.single == selectorSelectionMode || entry.immediate) {
      // No need to tap "Apply"; return result immediately
      _onApplyTap();
    } else {
      // Update UI state
      setState(() {});

      final newEntries = SelectorUtils.cloneTree(
        widget.entries,
        _selectedEntriesPerLevel,
        deepCloneSelectedSubtree: false,
        selectedHeaderEntries: _selectedHeaderEntries,
        selectedFooterEntries: _selectedFooterEntries,
      );
      controller?.change(newEntries);
    }
  }

  void _onHeaderOrFooterItemTap(
    bool isHeader,
    int chipIndex,
    SelectorChildEntry entry,
  ) {
    final selectionMode = isHeader
        ? tempSelectedCategory.headerSelectionMode
        : tempSelectedCategory.footerSelectionMode;
    final selectedItems = isHeader
        ? _headerSelectedFor(tempSelectedCategory.id)
        : _footerSelectedFor(tempSelectedCategory.id);

    final contains = selectedItems.any((e) => e.id == entry.id);
    if (SelectionMode.single == selectionMode) {
      if (contains) {
        selectedItems.removeWhere((e) => e.id == entry.id);
      } else {
        selectedItems
          ..clear()
          ..add(entry);
      }
    } else {
      if (contains) {
        selectedItems.removeWhere((e) => e.id == entry.id);
      } else {
        selectedItems.add(entry);
      }
    }

    _setStateOrImmediateApply(entry);
  }

  void _onApplyTap() {
    final entries = widget.entries.toSet();
    SelectorUtils.clippingTree(
      entries,
      _selectedEntriesPerLevel,
      0,
      _selectedHeaderEntries,
      _selectedFooterEntries,
    );
    controller?.apply(entries);
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

    final theme = SelectorTheme.of(context);

    /// Maximum level for the current category
    final maxLevel = tempSelectedCategory.maxLevel;
    final isMultipleSelectionMode =
        SelectionMode.multiple == tempSelectedCategory.selectionMode;

    final categoryHeader = tempSelectedCategory.header;
    final categoryFooter = tempSelectedCategory.footer;
    final headerSelected = _headerSelectedFor(tempSelectedCategory.id);
    final footerSelected = _footerSelectedFor(tempSelectedCategory.id);

    final categoryBackgroundColor =
        _backgroundColors.firstOrNull ?? Colors.white;
    // Get selected item color (background color of next level)
    final selectedTileColor = 0 + 1 < _backgroundColors.length
        ? _backgroundColors[0 + 1]
        : Colors.white;

    final effectiveSelectedColor =
        selector?.selectedColor ?? theme.selectedColor;

    final tempSelectedCategoryIndex =
        widget.entries.indexOf(tempSelectedCategory);

    final selectedCategories = _selectedEntriesPerLevel.firstOrNull ?? {};

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category list (left)
              SelectorCategoryBar(
                scrollDirection: Axis.vertical,
                size: selector?.categoryBarTheme?.size,
                backgroundColor: categoryBackgroundColor,
                selectedColor: effectiveSelectedColor,
                selectedTileColor: selectedTileColor,
                entries: widget.entries,
                selectedCategories: selectedCategories,
                focusedIndex: tempSelectedCategoryIndex,
                onTap: (_, entry) =>
                    _onCategoryItemTap(entry as SelectorCategoryEntry),
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
                        entries: categoryHeader.children!.toList(),
                        selectedEntries: headerSelected,
                        onItemTap: (index, entry) => _onHeaderOrFooterItemTap
                            .call(true, index, entry as SelectorChildEntry),
                      ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(_cascadingList.length,
                            (cascadeIndex) {
                          final entries = _cascadingList[cascadeIndex];
                          final level = cascadeIndex + 1;
                          final selectedItems =
                              _selectedEntriesPerLevel.elementAtOrNull(level) ??
                                  {};
                          final isMiddleLevel = level < _currentLevel;
                          // Focused item at the current level
                          final focusedItem =
                              _tempSelectedEntryPerLevel.elementAtOrNull(level);
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
                                itemCount: entries.length,
                                itemBuilder: (context, index) {
                                  final entry =
                                      entries[index] as SelectorTextEntry;
                                  if (!entry.hasChildren && entry.enabled) {
                                    // && level == maxLevel - 1
                                    final selected =
                                        selectedItems.contains(entry);
                                    if (SelectionMode.single ==
                                        childrenSelectionMode) {
                                      return SelectorRadioListTile(
                                        label: entry.name ?? '',
                                        selected: selected,
                                        radioBuilder: selector?.radioBuilder,
                                        enabled: entry.enabled,
                                        onTap: () {
                                          _onTerminalItemTap.call(
                                              cascadeIndex, entry);
                                        },
                                      );
                                    } else {
                                      return SelectorCheckboxListTile(
                                        label: entry.name ?? '',
                                        checked: selected,
                                        checkboxBuilder:
                                            selector?.checkboxBuilder,
                                        enabled: entry.enabled,
                                        onTap: () => _onTerminalItemTap.call(
                                            cascadeIndex, entry),
                                      );
                                    }
                                  } else {
                                    final selected = _tempSelectedEntryPerLevel
                                        .contains(entry);
                                    final selectedCount =
                                        _selectedEntriesPerLevel
                                                .elementAtOrNull(level + 1)
                                                ?.where((e) =>
                                                    e is SelectorChildEntry &&
                                                    e.parentId == entry.id)
                                                .length ??
                                            0;
                                    return SelectorListTile(
                                      label: entry.name ?? '',
                                      selected: selected,
                                      // selectedColor: selectedColor,
                                      selectedTileColor: selectedColor,
                                      badge: selectedCount > 0
                                          ? selectedCount.toString()
                                          : null,
                                      enabled: entry.enabled,
                                      onTap: () => _onMiddleItemTap.call(
                                          cascadeIndex, entry),
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
                        entries: categoryFooter.children!.toList(),
                        selectedEntries: footerSelected,
                        onItemTap: (index, entry) => _onHeaderOrFooterItemTap
                            .call(false, index, entry as SelectorChildEntry),
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
