import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector.dart';
import '../selector_entry.dart';
import '../selector_utils.dart';
import 'selector_controller.dart';
import 'selector_theme.dart';
import 'widgets/widgets.dart';

/// Horizontal layout: category navigation on the left and a flattened item list on the right.
/// Tapping the left side drives scrolling on the right; scrolling the right side highlights the left side.
/// Two-dimensional structured data.
///
/// Suitable for "layout type", "more", etc.
///
/// Behavior notes:
/// - This selector is fixed to a two-level structure: category -> children.
/// - Child selection mode is determined per category by [SelectorCategoryEntry.selectionMode].
/// - The right-side content is scroll-synced with the left category list.
/// - Custom range entries ([SelectorRangeEntry.custom]) are rendered as an input
///   row; typing clears existing child selections for that category.
/// - When an entry's `immediate` is true, selection is applied immediately
///   without requiring the action bar.
/// - In multi-selection mode, the action bar is shown and "Apply" produces the
///   final clipped selection tree.
class FlattenSelectorView extends StatefulWidget {
  const FlattenSelectorView({
    super.key,
    required this.entries,
    required this.previousSelected,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
  });

  final List<SelectorEntry> entries;
  final Set<SelectorEntry>? previousSelected;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  @override
  State<FlattenSelectorView> createState() => FlattenSelectorViewState();
}

class FlattenSelectorViewState extends State<FlattenSelectorView> {
  /// Focused category entry
  // SelectorCategoryEntry? _selectedCategory;
  int _tempSelectedCategoryIndex = 0;

  /// Selected entries per level, fixed to two levels
  final List<SelectorEntries> _selectedEntriesPerLevel = [];

  var _isScrollingProgrammatically = false;
  final GlobalKey _scrollViewKey = GlobalKey();

  SelectorController? controller;

  final level = 2;

  @override
  void initState() {
    super.initState();

    if (widget.previousSelected != null &&
        (widget.previousSelected?.isNotEmpty ?? false)) {
      // Restore previous selection
      _selectedEntriesPerLevel.addAll(SelectorUtils.restorePreviousSelected(
          widget.entries, widget.previousSelected));
    } else {
      // Check whether there is an "Any" entry; if so, select it by default
      _selectAnyItemIfHas();
    }

    _tempSelectedCategoryIndex = 0;

    // _selectedCategory =
    //     _selectedEntriesPerLevel[0].first as SelectorCategoryEntry;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectorController(context);
  }

  @override
  void didUpdateWidget(covariant FlattenSelectorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectorController(context);
  }

  void _updateSelectorController(BuildContext context) {
    if (controller == null) {
      controller = SelectorController.of(context)!;
      controller?.addListener(_handleSelectorControllerTick);
    }
  }

  FlattenSelector? get selector => controller?.selector as FlattenSelector;

  void _handleSelectorControllerTick() {}

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

  /// Selection Mode for category entries
  SelectionMode? get categorySelectionMode => selector?.selectionMode;

  /// Checks whether the selected category has an "Any" item
  void _selectAnyItemIfHas() {
    _selectedEntriesPerLevel.clear();
    while (_selectedEntriesPerLevel.length < level) {
      _selectedEntriesPerLevel.add({});
    }
    for (var category in widget.entries) {
      final anyItem = category.children?.singleWhereOrNull(testAnyElement);
      if (anyItem != null) {
        // If there is an "Any" entry, select it.
        _selectedEntriesPerLevel[0].add(category);
        _selectedEntriesPerLevel[1].add(anyItem);
      }
    }
  }

  SelectorCategoryEntry? get selectedCategory =>
      widget.entries.elementAtOrNull(_tempSelectedCategoryIndex)
          as SelectorCategoryEntry;

  bool _onScrollNotification(ScrollNotification notification) {
    // If this scroll was triggered programmatically, ignore it
    if (_isScrollingProgrammatically) return false;

    // Only handle scroll update notifications
    // Only handle scroll update notifications
    if (notification is! ScrollUpdateNotification) return false;

    _observeVisibleItems();

    return false;
  }

  void _observeVisibleItems() {
    // 1. Get the RenderBox of the ListView
    final RenderBox? scrollBox =
        _scrollViewKey.currentContext?.findRenderObject() as RenderBox?;
    if (scrollBox == null || !scrollBox.attached) return;

    // 2. Get the viewport's absolute position on screen (for coordinate conversion)
    final scrollOffset = scrollBox.localToGlobal(Offset.zero);

    int? firstVisibleIndex;
    // double minTopGap = double.infinity;

    // 3. Traverse children (based on the core idea of scrollview_observer)
    // Each child is given a ValueKey('category_$index') so we can find it.
    for (int i = 0; i < widget.entries.length; i++) {
      // Key point: find the child's RenderObject directly from the current context.
      // This has overhead for huge lists, but is efficient and robust for a category selector (limited size).
      final childKey = ValueKey('category_$i');

      // Note: due to ListView caching, off-screen children may not be found via context.
      // This matches our requirement: we only need visible items.
      final childElement = _findChildElement(scrollBox, childKey);
      if (childElement == null) continue;

      final RenderBox? childRenderBox = childElement.renderObject as RenderBox?;
      if (childRenderBox == null || !childRenderBox.attached) continue;

      // 4. Compute the child's distance relative to the viewport top
      final childOffset = childRenderBox.localToGlobal(Offset.zero);
      final relativeTop = childOffset.dy - scrollOffset.dy;

      // Idea: find the first item that is closest to the viewport top and not fully out of bounds.
      // Threshold: the item's top is within 5px above the viewport top, or inside the viewport.
      if (relativeTop <= 5 && relativeTop > -childRenderBox.size.height + 5) {
        firstVisibleIndex = i;
        break;
      }
    }

    if (firstVisibleIndex != null &&
        firstVisibleIndex != _tempSelectedCategoryIndex) {
      setState(() {
        _tempSelectedCategoryIndex = firstVisibleIndex!;
      });
    }
  }

  /// Helper: find an Element with a specific Key in the RenderObject tree
  /// Note: visitChildElements has a performance cost
  Element? _findChildElement(RenderObject parent, Key key) {
    Element? target;
    _scrollViewKey.currentContext?.visitChildElements((element) {
      // This visit traverses direct children of the ListView (i.e., SelectorGridView)
      void visitor(Element e) {
        if (e.widget.key == key) {
          target = e;
          return;
        }
        e.visitChildElements(visitor);
      }

      visitor(element);
    });
    return target;
  }

  void _onCategoryItemTap(int index) {
    if (_tempSelectedCategoryIndex == index) return;

    setState(() {
      _tempSelectedCategoryIndex = index;
    });

    final childKey = ValueKey('category_$index');
    final targetElement = _findChildElement(
        _scrollViewKey.currentContext!.findRenderObject()!, childKey);

    if (targetElement == null) return;

    _isScrollingProgrammatically = true;

    // Scroll safely
    Scrollable.ensureVisible(
      targetElement,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.0,
    ).then((_) {
      // After scrolling ends, reset the flag with a short delay
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _isScrollingProgrammatically = false;
        }
      });
    }).catchError((error) {
      // Handle any errors during scrolling
      if (mounted) {
        _isScrollingProgrammatically = false;
      }
    });
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

  void _onTerminalItemTap(SelectorChildEntry item) {
    while (_selectedEntriesPerLevel.length < level) {
      _selectedEntriesPerLevel.add({});
    }

    final category =
        widget.entries.singleWhereOrNull((e) => e.id == item.parentId)
            as SelectorCategoryEntry;

    final childrenSelectionMode = category.selectionMode;

    final selectedItems = _selectedEntriesPerLevel[1];

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

      // If there is an "Any" entry, remove it
      selectedItems.removeWhere((e) =>
          (e as SelectorChildEntry).parentId == item.parentId && e.isAny);

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
      _selectedEntriesPerLevel[0].add(category);
    } else if (selectedItems.isEmpty) {
      // If it was a deselect action and no children are selected, deselect the parent as well
      _selectedEntriesPerLevel[0].remove(category);
      // If there is an "Any" child entry, select it
      final anyItem = category.children?.singleWhereOrNull(testAnyElement);
      if (anyItem != null) {
        selectedItems.add(anyItem);
      }
    }

    _setStateOrImmediateApply(item);
  }

  void _setStateOrImmediateApply(SelectorChildEntry item) {
    if (SelectionMode.single == selectorSelectionMode || item.immediate) {
      // No need to tap "Apply"; return result immediately
      _onApplyTap();
    } else {
      // Update UI state
      setState(() {});

      final newEntries = SelectorUtils.cloneTree(
        widget.entries,
        _selectedEntriesPerLevel,
        deepCloneSelectedSubtree: false,
      );
      controller?.change(newEntries);
    }
  }

  void _onResetTap() {
    _selectedEntriesPerLevel.clear();
    _selectedEntriesPerLevel.addAll(SelectorUtils.restorePreviousSelected(
        widget.entries, controller?.resetSelected));

    _tempSelectedCategoryIndex = 0;

    // _selectedCategory =
    //     _selectedEntriesPerLevel[0].first as SelectorCategoryEntry;

    setState(() {});
    controller?.reset();
  }

  void _onApplyTap() {
    if (_selectedEntriesPerLevel.isEmpty) {
      controller?.apply({});
      return;
    }

    final entries = widget.entries.toSet();
    SelectorUtils.clippingTree(entries, _selectedEntriesPerLevel, 0);
    controller?.apply(entries);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SelectorTheme.of(context);

    final selectedCategories =
        _selectedEntriesPerLevel.elementAtOrNull(0) ?? {};

    final categoryBackgroundColor = theme.backgroundColor;
    final terminalBackgroundColor = theme.backgroundColorHigh;

    final effectiveSelectedColor =
        selector?.selectedColor ?? theme.selectedColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left category list
              SelectorCategoryBar(
                scrollDirection: Axis.vertical,
                size: selector?.categoryBarTheme?.size,
                backgroundColor: categoryBackgroundColor,
                selectedColor: effectiveSelectedColor,
                selectedTileColor: terminalBackgroundColor,
                entries: widget.entries,
                selectedCategories: selectedCategories,
                focusedIndex: _tempSelectedCategoryIndex,
                onTap: (index, entry) => _onCategoryItemTap(index),
              ),
              // Right content area with NotificationListener
              Expanded(
                child: ColoredBox(
                  color: terminalBackgroundColor,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScrollNotification,
                    child: ListView(
                      key:
                          _scrollViewKey, // Add key to get scroll view position
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      // shrinkWrap: true,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
                          .onDrag, // 滑动时自动收起软键盘
                      children: widget.entries.mapIndexed((index, item) {
                        final category =
                            widget.entries[index] as SelectorCategoryEntry;
                        final entries = category.children?.toList() ?? [];
                        final selectedEntries =
                            _selectedEntriesPerLevel.elementAtOrNull(1) ?? {};
                        final isLast = item == widget.entries.last;
                        return SelectorGridView(
                          key: ValueKey('category_$index'),
                          crossAxisCount: widget.crossAxisCount,
                          childAspectRatio: widget.childAspectRatio,
                          mainAxisSpacing: widget.mainAxisSpacing,
                          crossAxisSpacing: widget.crossAxisSpacing,
                          category: category,
                          entries: entries,
                          selectedEntries: selectedEntries,
                          onItemTap: (index, item) =>
                              _onTerminalItemTap(item as SelectorChildEntry),
                          focusListener: _focusListener,
                          padding:
                              EdgeInsets.only(top: 18, bottom: isLast ? 18 : 0),
                        );
                      }).toList(),
                    ),
                  ),
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

class PlattenSelectorSkeleton extends StatelessWidget {
  /// Loading skeleton for [FlattenSelectorView].
  const PlattenSelectorSkeleton({
    super.key,
    this.categoryBackgroundColor,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
  });

  final Color? categoryBackgroundColor;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final theme = SelectorTheme.of(context);
    final controller = SelectorController.of(context);
    final selector = controller?.selector as FlattenSelector;

    final categoryBackgroundColor = theme.backgroundColor;

    return ColoredBox(
      color: categoryBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectorCategoryBarSkeleton(
                  scrollDirection: Axis.vertical,
                  size: selector.categoryBarTheme?.size,
                  backgroundColor: categoryBackgroundColor,
                ),
                Flexible(
                  child: SelectorGridSkeleton(
                    itemCount: 16,
                    padding: const EdgeInsets.all(15),
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    mainAxisSpacing: mainAxisSpacing,
                    crossAxisSpacing: crossAxisSpacing,
                  ),
                ),
              ],
            ),
          ),
          const SelectorActionBarSkeleton(),
        ],
      ),
    );
  }
}
