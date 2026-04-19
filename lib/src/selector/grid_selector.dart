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
  /// Selected category entry
  int _selectedCategoryIndex = 0;
  late SelectorCategoryEntry _tempSelectedCategory;

  /// Selected entries per level (actual selections), fixed to two levels
  final List<SelectorEntries> _selectedItemsPerLevel = [];

  TextEditingController? _minController;
  TextEditingController? _maxController;

  FocusNode? _minFocusNode;
  FocusNode? _maxFocusNode;

  SelectorController? controller;

  final level = 2;

  @override
  void initState() {
    super.initState();

    // assert(widget.entries.maxLevel == 2);

    if (widget.previousSelected != null &&
        (widget.previousSelected?.isNotEmpty ?? false)) {
      // Previous selection
      _initializeSelectedItemsPerLevel(
          widget.entries, widget.previousSelected, 0);
      _tempSelectedCategory =
          (_selectedItemsPerLevel.elementAtOrNull(0)?.firstOrNull ??
              widget.entries.first) as SelectorCategoryEntry;
      _checkCustomItem();
    } else {
      // Default selection
      _tempSelectedCategory = widget.entries.first as SelectorCategoryEntry;
      _checkCustomItem();
      _checkHasAnyItem();
    }
  }

  @override
  void dispose() {
    _minController?.dispose();
    _maxController?.dispose();
    _minFocusNode?.dispose();
    _maxFocusNode?.dispose();
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
          // If it's a custom option, restore the previous input values.
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

  /// Checks whether the current category has a custom item
  SelectorRangeEntry? _checkCustomItem() {
    final customItem =
        _tempSelectedCategory.children?.singleWhereOrNull(testCustomItem);
    if (customItem != null) {
      // If there is a custom option, initialize the input fields.
      _initializeInput();
      customItem as SelectorRangeEntry;
      _minController?.text = customItem.min?.toString() ?? '';
      _maxController?.text = customItem.max?.toString() ?? '';
      return customItem;
    }
    return null;
  }

  /// Checks whether the selected category has an "Any" item
  SelectorChildEntry? _checkHasAnyItem() {
    final anyItem =
        _tempSelectedCategory.children?.singleWhereOrNull(testAnyItem);
    if (anyItem != null) {
      // If there is an "Any" option, select it.
      _selectedItemsPerLevel.clear();
      while (_selectedItemsPerLevel.length < level) {
        _selectedItemsPerLevel.add({});
      }
      _selectedItemsPerLevel[0].add(_tempSelectedCategory);
      _selectedItemsPerLevel[1].add(anyItem);
    }
  }

  void _initializeInput() {
    if (_minController == null) {
      _minController = TextEditingController();
      _minController?.addListener(_inputListener);
    }
    if (_maxController == null) {
      _maxController = TextEditingController();
      _maxController?.addListener(_inputListener);
    }
    _minFocusNode ??= FocusNode();
    _maxFocusNode ??= FocusNode();
  }

  /// Listens to input fields; once the user types, clears selected items
  void _inputListener() {
    if (inputNotEmpty) {
      final selectedItems = _selectedItemsPerLevel[1];
      if (selectedItems.isNotEmpty) {
        setState(() {
          selectedItems.clear();
        });
      }
    }
  }

  bool get inputNotEmpty =>
      (_minController?.text.isNotEmpty ?? false) ||
      (_maxController?.text.isNotEmpty ?? false);

  void _clearAllInput() {
    if (inputNotEmpty) {
      _minController?.clear();
      _maxController?.clear();
    }
  }

  bool get inputHasFocus =>
      (_minFocusNode?.hasFocus ?? false) || (_maxFocusNode?.hasFocus ?? false);

  void _unfocusAllInput() {
    if (inputHasFocus) {
      _minFocusNode?.unfocus();
      _maxFocusNode?.unfocus();
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
    if (widget.entries.firstWhereOrNull(testMultipleItem) != null) {
      return SelectionMode.multiple;
    }
    return SelectionMode.single;
  }

  void _onCategoryItemTap(int index) {
    _selectedCategoryIndex = index;
    final item = widget.entries[index] as SelectorCategoryEntry;

    if (SelectionMode.single == categorySelectionMode) {
      // Single-select mode: reset previous selection when switching category.
      _selectedItemsPerLevel.clear();

      _tempSelectedCategory = item;

      // If there is a custom range option
      final customItem = _checkCustomItem();

      if (customItem == null || !inputNotEmpty) {
        _checkHasAnyItem();
      }
    } else {
      // Multi-select mode: keep previous selection when switching categories.
      // TODO: Implement multi-category selection logic.
    }
    setState(() {});
  }

  void _onChildrenItemTap(int index, SelectorChildEntry item) {
    while (_selectedItemsPerLevel.length < level) {
      _selectedItemsPerLevel.add({});
    }
    final selectedItems = _selectedItemsPerLevel[1];

    // Clear custom input
    _clearAllInput();

    // Handle "Any" logic
    if (item.isAny) {
      // "Any" node
      if (SelectionMode.single == childrenSelectionMode) {
        // Single-select mode
        if (selectedItems.contains(item)) {
          return;
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
              (e) => (e as SelectorChildEntry).parentId == item.parentId);
          selectedItems.add(item);
        }
      }
    } else {
      // Normal node

      // If there is an "Any" node, remove it
      selectedItems.removeWhere((e) =>
          (e as SelectorRangeEntry).parentId == item.parentId && e.isAny);

      if (SelectionMode.single == childrenSelectionMode) {
        // Single-select mode
        if (selectedItems.contains(item)) {
          return;
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
      // If it was a select action, select the parent as well
      _selectedItemsPerLevel[0].add(_tempSelectedCategory);
    } else if (selectedItems.isEmpty) {
      // If it was a deselect action and no children are selected, deselect the parent as well
      _selectedItemsPerLevel[0].remove(_tempSelectedCategory);
      // If there is an "Any" child node, select it
      final anyItem =
          _tempSelectedCategory.children?.singleWhereOrNull(testAnyItem);
      if (anyItem != null) {
        selectedItems.add(anyItem);
      }
    }

    _unfocusAllInput();
    _setStateOrImmediateApply(item);
  }

  void _setStateOrImmediateApply(SelectorChildEntry item) {
    if (item.immediate) {
      // No need to tap "Apply"; return result immediately
      _onApplyTap();
    } else {
      // Update UI state
      setState(() {});

      _customRangeSelection();
      final options = widget.entries.toSet();
      SelectorUtils.clippingTree(options, _selectedItemsPerLevel, 0);
      controller?.change(options);
    }
  }

  void _onResetTap() {
    _minController?.clear();
    _maxController?.clear();

    _selectedItemsPerLevel.clear();

    _initializeSelectedItemsPerLevel(
        widget.entries, controller?.resetSelected, 0);

    _tempSelectedCategory =
        _selectedItemsPerLevel[0].first as SelectorCategoryEntry;

    setState(() {});
    controller?.reset();
  }

  void _customRangeSelection() {
    var minValue = int.tryParse(_minController?.text ?? '') ?? 0;
    var maxValue = int.tryParse(_maxController?.text ?? '') ?? 0;
    if (minValue != 0 || maxValue != 0) {
      // Valid custom input provided
      if (minValue > maxValue) {
        int temp = minValue;
        minValue = maxValue;
        maxValue = temp;
      }
      //
      final customItem =
          _tempSelectedCategory.children?.singleWhereOrNull(testCustomItem);
      if (customItem != null && customItem is SelectorRangeEntry) {
        customItem.min = minValue;
        customItem.max = maxValue;
      }
      // Select the custom item and its parent category
      while (_selectedItemsPerLevel.length < level) {
        _selectedItemsPerLevel.add({});
      }
      _selectedItemsPerLevel[1].add(customItem!);
      _selectedItemsPerLevel[0].add(_tempSelectedCategory);
    }
  }

  void _onApplyTap() {
    _customRangeSelection();
    final options = widget.entries.toSet();
    SelectorUtils.clippingTree(options, _selectedItemsPerLevel, 0);
    controller?.apply(options);
  }

  @override
  Widget build(BuildContext context) {
    final childrenItems = _tempSelectedCategory.children?.toList() ?? [];
    var childrenItemsWithoutCustom = childrenItems;
    SelectorRangeEntry? firstCustomItem =
        _tempSelectedCategory.firstCustomOrNull;
    SelectorRangeEntry? lastCustomItem = _tempSelectedCategory.lastCustomOrNull;
    if (firstCustomItem != null || lastCustomItem != null) {
      childrenItemsWithoutCustom =
          childrenItems.where(testNotCustomItem).toList();
    }

    final gridviews = List.generate(widget.entries.length, (int index) {
      return SelectorGridView(
        key: ValueKey('category_$index'),
        crossAxisCount: selector!.crossAxisCount,
        childAspectRatio: selector!.childAspectRatio,
        mainAxisSpacing: selector!.mainAxisSpacing,
        crossAxisSpacing: selector!.crossAxisSpacing,
        tileVariant: selector!.tileVariant,
        items: childrenItemsWithoutCustom,
        selectedItems: _selectedItemsPerLevel[1],
        onItemTap: (index, item) =>
            _onChildrenItemTap(index, item as SelectorChildEntry),
      );
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectorCategoryBar(
          onTap: (index, item) => _onCategoryItemTap(index),
          entries: widget.entries,
          selectedCategoryIndex: _selectedCategoryIndex,
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: gridviews[_selectedCategoryIndex],
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
