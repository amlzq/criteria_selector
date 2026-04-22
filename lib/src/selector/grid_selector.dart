import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector.dart';
import '../selector_entry.dart';
import '../selector_utils.dart';
import 'selector_controller.dart';
import 'widgets/widgets.dart';

/// Vertical layout: category tabs on top and a grid of items below.
/// Two-dimensional structured data.
///
/// Suitable for "price range", etc.
///
/// Behavior notes:
/// - This selector is fixed to a two-level structure: category -> children.
/// - If a category contains an "Any" child entry, it may be selected by default.
/// - If a category contains a custom range entry ([SelectorRangeEntry.custom]),
///   two numeric fields are shown for min/max input.
/// - When an entry's `immediate` is true, selection is applied immediately
///   without requiring the action bar.
/// - In multi-selection mode, the action bar is shown and "Apply" produces the
///   final clipped selection tree.
class GridSelectorView extends StatefulWidget {
  final List<SelectorEntry> entries;
  final Set<SelectorEntry>? previousSelected;

  const GridSelectorView({
    super.key,
    required this.entries,
    required this.previousSelected,
  });

  @override
  State<GridSelectorView> createState() => GridSelectorViewState();
}

class GridSelectorViewState extends State<GridSelectorView> {
  /// Focused category entry
  late SelectorCategoryEntry _tempSelectedCategory;

  /// Selected entries per level (actual selections), fixed to two levels
  final List<SelectorEntries> _selectedItemsPerLevel = [];

  SelectorController? controller;

  final level = 2;

  @override
  void initState() {
    super.initState();

    if (widget.previousSelected != null &&
        (widget.previousSelected?.isNotEmpty ?? false)) {
      // Previous selection
      _initializeSelectedItemsPerLevel(
          widget.entries, widget.previousSelected, 0);
      _tempSelectedCategory =
          (_selectedItemsPerLevel.elementAtOrNull(0)?.firstOrNull ??
              widget.entries.first) as SelectorCategoryEntry;
    } else {
      // Default selection
      _tempSelectedCategory = widget.entries.first as SelectorCategoryEntry;
      _selectAnyItemIfHas();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectorController(context);
  }

  @override
  void didUpdateWidget(covariant GridSelectorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectorController(context);
  }

  void _updateSelectorController(BuildContext context) {
    if (controller == null) {
      controller = SelectorController.of(context)!;
      controller?.addListener(_handleSelectorControllerTick);
    }
  }

  GridSelector? get selector => controller?.selector as GridSelector;

  void _handleSelectorControllerTick() {}

  void _initializeSelectedItemsPerLevel(List<SelectorEntry>? items,
      Set<SelectorEntry>? selectedItems, int level) {
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
        if (item is SelectorRangeEntry && item.isCustom) {
          // If it's a custom entry, restore the previous input values.
          selectedItem as SelectorRangeEntry;
          item.min = selectedItem.min;
          item.max = selectedItem.max;
        }
      }
      if (selectedItem.children?.isNotEmpty == true) {
        _initializeSelectedItemsPerLevel(
            item?.children?.toList(), selectedItem.children, level + 1);
      }
    }
  }

  /// Checks whether the selected category has an "Any" item
  void _selectAnyItemIfHas() {
    _selectedItemsPerLevel.clear();
    while (_selectedItemsPerLevel.length < level) {
      _selectedItemsPerLevel.add({});
    }
    for (var category in widget.entries) {
      final anyItem = category.children?.singleWhereOrNull(testAnyElement);
      if (anyItem != null) {
        // If there is an "Any" entry, select it.
        _selectedItemsPerLevel[0].add(category);
        _selectedItemsPerLevel[1].add(anyItem);
      }
    }
  }

  /// Selection Mode for category entries
  SelectionMode? get categorySelectionMode => selector?.selectionMode;

  /// Selection Mode for the selected category sub-items
  SelectionMode get childrenSelectionMode =>
      _tempSelectedCategory.selectionMode;

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

  void _onCategoryItemTap(SelectorCategoryEntry item) {
    if (item == _tempSelectedCategory) return;
    _tempSelectedCategory = item;

    if (SelectionMode.single == categorySelectionMode) {
      // Single-select mode: reset previous selection when switching category.

      _selectedItemsPerLevel.clear();
      while (_selectedItemsPerLevel.length < level) {
        _selectedItemsPerLevel.add({});
      }

      _selectAnyItemIfHas();
    } else {
      // Multi-select mode: keep previous selection when switching categories.

      // // Sync custom input state for the newly focused category.
      // final customItem = _checkCustomItem();

      // while (_selectedItemsPerLevel.length < level) {
      //   _selectedItemsPerLevel.add({});
      // }

      // final selectedChildren = _selectedItemsPerLevel[1];
      // final hasChildOfCategory = selectedChildren.any(
      //   (e) => e is SelectorChildEntry && e.parentId == item.id,
      // );

      // // For a category without selection yet, default to its "Any" entry
      // // without clearing selections from other categories.
      // if (!hasChildOfCategory && (customItem == null || !inputNotEmpty)) {
      //   final anyItem = item.children?.singleWhereOrNull(testAnyElement);
      //   if (anyItem != null) {
      //     selectedChildren.removeWhere(
      //       (e) => e is SelectorChildEntry && e.parentId == item.id,
      //     );
      //     selectedChildren.add(anyItem);
      //     _selectedItemsPerLevel[0].add(item);
      //   }
      // } else if (hasChildOfCategory) {
      //   _selectedItemsPerLevel[0].add(item);
      // }
    }
    setState(() {});
  }

  void _onTerminalItemTap(SelectorChildEntry item) {
    while (_selectedItemsPerLevel.length < level) {
      _selectedItemsPerLevel.add({});
    }
    final selectedItems = _selectedItemsPerLevel[1];

    if (item.isAny) {
      // "Any" entry
      // Remove items that share the same parent from the selected list
      selectedItems.removeWhere((e) => testSameParentElement(e, item.parentId));
      selectedItems.add(item);
    } else if (item is SelectorRangeEntry && item.isCustom) {
      // Custom range entry

      // Remove other entry in the same category
      selectedItems.removeWhere((e) => testSameParentElement(e, item.parentId));
      selectedItems.add(item);
    } else {
      // Normal entry

      // If there is an "Any" entry or an custom range entry, remove it
      selectedItems.removeWhere(
          (e) => testSameParentAnyOrCustomElement(e, item.parentId));

      if (SelectionMode.single == childrenSelectionMode) {
        // Single-select mode
        if (selectedItems.contains(item)) {
        } else {
          selectedItems
              .removeWhere((e) => testSameParentElement(e, item.parentId));
          selectedItems.add(item);
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
      // If it was a select action, select the parent as well
      _selectedItemsPerLevel[0].add(_tempSelectedCategory);
    } else if (selectedItems.isEmpty) {
      // If it was a deselect action and no children are selected, deselect the parent as well
      _selectedItemsPerLevel[0].remove(_tempSelectedCategory);
      // If there is an "Any" child entry, select it
      _selectAnyItemIfHas();
    }

    _setStateOrImmediateApply(item);
  }

  void _setStateOrImmediateApply(SelectorChildEntry item) {
    if (SelectionMode.single == selectorSelectionMode || item.immediate) {
      // No need to tap "Apply"; return result immediately
      _onApplyTap();
    } else {
      // if (item is SelectorRangeEntry && item.isCustom) {
      // } else {
      // Update UI state
      setState(() {});
      // }

      final newEntries = SelectorUtils.cloneTree(
        widget.entries,
        _selectedItemsPerLevel,
        deepCloneSelectedSubtree: false,
      );
      controller?.change(newEntries);
    }
  }

  void _onResetTap() {
    _selectedItemsPerLevel.elementAtOrNull(1)?.removeWhere(
        (e) => testSameParentElement(e, _tempSelectedCategory.id));

    final index = widget.entries.indexOf(_tempSelectedCategory);
    final resetSelected = controller?.resetSelected?.elementAtOrNull(index);
    final selectedItems = resetSelected != null ? {resetSelected} : null;

    if (selectedItems != null && selectedItems.isNotEmpty) {
      // Specific reset selection
      _initializeSelectedItemsPerLevel(widget.entries, selectedItems, 0);
    } else {
      // Default selection
      for (var category in widget.entries) {
        final customItem =
            category.children?.singleWhereOrNull(testCustomElement);
        if (customItem != null && customItem is SelectorRangeEntry) {
          customItem.min = null;
          customItem.max = null;
        }
      }
      final anyItem =
          _tempSelectedCategory.children?.singleWhereOrNull(testAnyElement);
      if (anyItem != null) {
        _selectedItemsPerLevel[1].add(anyItem);
      }
    }

    setState(() {});
    controller?.reset();
  }

  void _focusListener(String categoryId, String minValue, String maxValue) {
    debugPrint('_focusListener $categoryId: $minValue,$maxValue');
    _customItemSelection(categoryId, minValue, maxValue);
  }

  void _customItemSelection(
      String categoryId, String minValue, String maxValue) {
    var minInt = int.tryParse(minValue) ?? 0;
    var maxInt = int.tryParse(maxValue) ?? 0;
    if (minInt != 0 || maxInt != 0) {
      // Valid custom input provided
      if (minInt > maxInt) {
        final temp = minInt;
        minInt = maxInt;
        maxInt = temp;
      }
      // Update the custom item
      final category =
          widget.entries.singleWhereOrNull((e) => e.id == categoryId);
      debugPrint('target category: $category');
      final customItem =
          category?.children?.singleWhereOrNull(testCustomElement);
      if (customItem != null && customItem is SelectorRangeEntry) {
        customItem.min = minInt;
        customItem.max = maxInt;
        customItem.name = '$minInt-$maxInt';
        _onTerminalItemTap(customItem);
      }
    }
  }

  void _onApplyTap() {
    final entries = widget.entries.toSet();
    SelectorUtils.clippingTree(entries, _selectedItemsPerLevel, 0);
    controller?.apply(entries);
  }

  @override
  Widget build(BuildContext context) {
    final gridviews = List.generate(widget.entries.length, (int index) {
      final category = widget.entries[index];
      final items = category.children?.toList() ?? [];
      final selectedItems = _selectedItemsPerLevel[1]
          .where((e) => e is SelectorChildEntry && e.parentId == category.id)
          .toSet();
      return SelectorGridView(
        key: ValueKey('category_$index'),
        crossAxisCount: selector!.crossAxisCount,
        childAspectRatio: selector!.childAspectRatio,
        mainAxisSpacing: selector!.mainAxisSpacing,
        crossAxisSpacing: selector!.crossAxisSpacing,
        tileVariant: selector!.tileVariant,
        items: items,
        selectedItems: selectedItems,
        // inputListener: _inputListener,
        focusListener: _focusListener,
        onItemTap: (index, item) =>
            _onTerminalItemTap(item as SelectorChildEntry),
      );
    });

    /// Focused category index
    final tempSelectedCategoryIndex =
        widget.entries.indexOf(_tempSelectedCategory);

    debugPrint('tempSelectedCategoryIndex: $tempSelectedCategoryIndex');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.entries.length > 1)
          SelectorCategoryBar(
            onTap: (index, item) =>
                _onCategoryItemTap(item as SelectorCategoryEntry),
            entries: widget.entries,
            selectedCategoryIndex: tempSelectedCategoryIndex,
          ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: gridviews[tempSelectedCategoryIndex],
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

class GridSelectorSkeleton extends StatelessWidget {
  /// Loading skeleton for [GridSelectorView].
  const GridSelectorSkeleton({
    super.key,
    required this.itemCount,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
  });

  final int itemCount;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SelectorCategoryBarSkeleton(),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: SelectorGridSkeleton(
              itemCount: itemCount,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              childAspectRatio: childAspectRatio,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const SelectorActionBarSkeleton(),
      ],
    );
  }
}
