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
  final List<SelectorEntries> _selectedEntriesPerLevel = [];

  SelectorController? controller;

  final level = 2;

  @override
  void initState() {
    super.initState();

    if (widget.previousSelected != null &&
        (widget.previousSelected?.isNotEmpty ?? false)) {
      // Previous selection
      _initializeSelectedEntriesPerLevel(
          widget.entries, widget.previousSelected, 0);
      _tempSelectedCategory =
          (_selectedEntriesPerLevel.elementAtOrNull(0)?.firstOrNull ??
              widget.entries.first) as SelectorCategoryEntry;
    } else {
      // Default selection
      _tempSelectedCategory = widget.entries.first as SelectorCategoryEntry;
      _selectAnyEntryIfHas();
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

  void _initializeSelectedEntriesPerLevel(List<SelectorEntry>? entries,
      Set<SelectorEntry>? selectedEntries, int level) {
    if (entries == null ||
        entries.isEmpty ||
        selectedEntries == null ||
        selectedEntries.isEmpty) {
      return;
    }
    _selectedEntriesPerLevel.add({});
    for (var selectedEntry in selectedEntries) {
      final entry = entries.singleWhereOrNull((e) => e.id == selectedEntry.id);
      if (entry != null) {
        _selectedEntriesPerLevel[level].add(entry);
        if (entry is SelectorRangeEntry && entry.isCustom) {
          // If it's a custom entry, restore the previous input values.
          selectedEntry as SelectorRangeEntry;
          entry.min = selectedEntry.min;
          entry.max = selectedEntry.max;
        }
      }
      if (selectedEntry.children?.isNotEmpty == true) {
        _initializeSelectedEntriesPerLevel(
            entry?.children?.toList(), selectedEntry.children, level + 1);
      }
    }
  }

  /// Checks whether the selected category has an "Any" entry
  void _selectAnyEntryIfHas() {
    _selectedEntriesPerLevel.clear();
    while (_selectedEntriesPerLevel.length < level) {
      _selectedEntriesPerLevel.add({});
    }
    for (var category in widget.entries) {
      final anyEntry = category.children?.singleWhereOrNull(testAnyElement);
      if (anyEntry != null) {
        // If there is an "Any" entry, select it.
        _selectedEntriesPerLevel[0].add(category);
        _selectedEntriesPerLevel[1].add(anyEntry);
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

  void _onCategoryItemTap(SelectorCategoryEntry entry) {
    if (entry == _tempSelectedCategory) return;
    _tempSelectedCategory = entry;

    if (SelectionMode.single == categorySelectionMode) {
      // Single-select mode: reset previous selection when switching category.

      _selectedEntriesPerLevel.clear();
      while (_selectedEntriesPerLevel.length < level) {
        _selectedEntriesPerLevel.add({});
      }

      _selectAnyEntryIfHas();
    } else {
      // Multi-select mode: keep previous selection when switching categories.

      // // Sync custom input state for the newly focused category.
      // final customItem = _checkCustomItem();

      // while (_selectedEntriesPerLevel.length < level) {
      //   _selectedEntriesPerLevel.add({});
      // }

      // final selectedChildren = _selectedEntriesPerLevel[1];
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
      //     _selectedEntriesPerLevel[0].add(item);
      //   }
      // } else if (hasChildOfCategory) {
      //   _selectedEntriesPerLevel[0].add(item);
      // }
    }
    setState(() {});
  }

  void _onTerminalItemTap(SelectorChildEntry entry) {
    while (_selectedEntriesPerLevel.length < level) {
      _selectedEntriesPerLevel.add({});
    }
    final selectedItems = _selectedEntriesPerLevel[1];

    if (entry.isAny) {
      // "Any" entry
      // Remove items that share the same parent from the selected list
      selectedItems
          .removeWhere((e) => testSameParentElement(e, entry.parentId));
      selectedItems.add(entry);
    } else if (entry is SelectorRangeEntry && entry.isCustom) {
      // Custom range entry

      // Remove other entry in the same category
      selectedItems
          .removeWhere((e) => testSameParentElement(e, entry.parentId));
      selectedItems.add(entry);
    } else {
      // Normal entry

      // If there is an "Any" entry or an custom range entry, remove it
      selectedItems.removeWhere(
          (e) => testSameParentAnyOrCustomElement(e, entry.parentId));

      if (SelectionMode.single == childrenSelectionMode) {
        // Single-select mode
        if (selectedItems.contains(entry)) {
        } else {
          selectedItems
              .removeWhere((e) => testSameParentElement(e, entry.parentId));
          selectedItems.add(entry);
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
      // If it was a select action, select the parent as well
      _selectedEntriesPerLevel[0].add(_tempSelectedCategory);
    } else if (selectedItems.isEmpty) {
      // If it was a deselect action and no children are selected, deselect the parent as well
      _selectedEntriesPerLevel[0].remove(_tempSelectedCategory);
      // If there is an "Any" child entry, select it
      _selectAnyEntryIfHas();
    }

    _setStateOrImmediateApply(entry);
  }

  void _setStateOrImmediateApply(SelectorChildEntry entry) {
    if (SelectionMode.single == selectorSelectionMode || entry.immediate) {
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
        _selectedEntriesPerLevel,
        deepCloneSelectedSubtree: false,
      );
      controller?.change(newEntries);
    }
  }

  void _onResetTap() {
    _selectedEntriesPerLevel.elementAtOrNull(1)?.removeWhere(
        (e) => testSameParentElement(e, _tempSelectedCategory.id));

    final index = widget.entries.indexOf(_tempSelectedCategory);
    final resetSelected = controller?.resetSelected?.elementAtOrNull(index);
    final selectedEntries = resetSelected != null ? {resetSelected} : null;

    if (selectedEntries != null && selectedEntries.isNotEmpty) {
      // Specific reset selection
      _initializeSelectedEntriesPerLevel(widget.entries, selectedEntries, 0);
    } else {
      // Default selection
      for (var category in widget.entries) {
        final customEntry =
            category.children?.singleWhereOrNull(testCustomElement);
        if (customEntry != null && customEntry is SelectorRangeEntry) {
          customEntry.min = null;
          customEntry.max = null;
        }
      }
      final anyEntry =
          _tempSelectedCategory.children?.singleWhereOrNull(testAnyElement);
      if (anyEntry != null) {
        _selectedEntriesPerLevel[1].add(anyEntry);
      }
    }

    setState(() {});
    controller?.reset();
  }

  void _focusListener(String categoryId, String minValue, String maxValue) {
    debugPrint('_focusListener $categoryId: $minValue,$maxValue');
    _customEntrySelection(categoryId, minValue, maxValue);
  }

  void _customEntrySelection(
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
      final customEntry =
          category?.children?.singleWhereOrNull(testCustomElement);
      if (customEntry != null && customEntry is SelectorRangeEntry) {
        customEntry.min = minInt;
        customEntry.max = maxInt;
        customEntry.name = '$minInt-$maxInt';
        _onTerminalItemTap(customEntry);
      }
    }
  }

  void _onApplyTap() {
    final entries = widget.entries.toSet();
    SelectorUtils.clippingTree(entries, _selectedEntriesPerLevel, 0);
    controller?.apply(entries);
  }

  @override
  Widget build(BuildContext context) {
    final gridviews = List.generate(widget.entries.length, (int index) {
      final category = widget.entries[index];
      final entries = category.children?.toList() ?? [];
      final selectedEntries = _selectedEntriesPerLevel[1]
          .where((e) => e is SelectorChildEntry && e.parentId == category.id)
          .toSet();
      return SelectorGridView(
        key: ValueKey('category_$index'),
        crossAxisCount: selector!.crossAxisCount,
        childAspectRatio: selector!.childAspectRatio,
        mainAxisSpacing: selector!.mainAxisSpacing,
        crossAxisSpacing: selector!.crossAxisSpacing,
        tileVariant: selector!.tileVariant,
        entries: entries,
        selectedEntries: selectedEntries,
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
            selectedCategories: {_tempSelectedCategory},
            focusedIndex: tempSelectedCategoryIndex,
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
