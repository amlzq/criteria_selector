import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'selector_controller.dart';
import 'selector_delegate.dart';
import 'selector_entry.dart';
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
class FlattenSelector extends StatefulWidget {
  const FlattenSelector({
    super.key,
    required this.delegate,
    required this.entries,
    required this.previousSelected,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
  });

  final FlattenSelectorDelegate delegate;

  final List<SelectorEntry> entries;

  final Set<SelectorEntry>? previousSelected;

  final int crossAxisCount;

  final double mainAxisSpacing;

  final double crossAxisSpacing;

  final double childAspectRatio;

  @override
  State<FlattenSelector> createState() => FlattenSelectorState();
}

class FlattenSelectorState extends State<FlattenSelector> {
  /// Focused category entry
  int _tempSelectedCategoryIndex = 0;

  var _isScrollingProgrammatically = false;

  final GlobalKey _scrollViewKey = GlobalKey();

  SelectorController? controller;

  @override
  void dispose() {
    controller?.removeListener(_handleSelectorControllerTick);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectorController(context);
  }

  @override
  void didUpdateWidget(covariant FlattenSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectorController(context);
  }

  void _updateSelectorController(BuildContext context) {
    if (controller == null) {
      controller = SelectorController.of(context)!;
      controller?.addListener(_handleSelectorControllerTick);
    }
    controller?.bindState(
      widget.entries,
      initializeAnyIfEmpty: true,
      previousSelectedOverride: widget.previousSelected,
    );
  }

  FlattenSelectorDelegate get delegate => widget.delegate;

  void _handleSelectorControllerTick() {
    if (mounted) setState(() {});
  }

  /// Selection Mode for delegate.
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
  SelectionMode? get categorySelectionMode => delegate.selectionMode;

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

    final category = widget.entries[index] as SelectorCategoryEntry;
    controller?.focusCategoryEntry(
      category,
      selectionMode: categorySelectionMode ?? SelectionMode.single,
    );

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
    if (minInt > maxInt) {
      final temp = minInt;
      minInt = maxInt;
      maxInt = temp;
    }
    controller?.setCustomRangeForParent(
      parentId: categoryId,
      min: (minInt == 0) ? null : minInt,
      max: (maxInt == 0) ? null : maxInt,
      applyIfImmediate: true,
    );
  }

  void _onTerminalItemTap(SelectorChildEntry item) {
    final category =
        widget.entries.singleWhereOrNull((e) => e.id == item.parentId)
            as SelectorCategoryEntry;
    controller?.toggleFlatEntry(
      item,
      selectorSelectionMode: selectorSelectionMode ?? SelectionMode.single,
      isCategoryTree: true,
      category: category,
    );

    _setStateOrImmediateApply(item);
  }

  void _setStateOrImmediateApply(SelectorChildEntry item) {
    if (SelectionMode.single == selectorSelectionMode || item.immediate) {
      // No need to tap "Apply"; return result immediately
      _onApplyTap();
    } else {
      setState(() {});
      controller?.emitChangeFromState();
    }
  }

  void _onResetTap() {
    controller?.resetState(initializeAnyIfEmpty: true);
    _tempSelectedCategoryIndex = 0;
    setState(() {});
    controller?.reset();
  }

  void _onApplyTap() {
    controller?.applyFromState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SelectorTheme.of(context);

    final selectedCategories = controller?.selectedEntriesAtLevel(0) ?? {};

    final categoryBackgroundColor = theme.backgroundColor;
    final terminalBackgroundColor = theme.backgroundColorHigh;

    final effectiveSelectedColor =
        delegate.selectedColor ?? theme.selectedColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left category list
              SelectorSideBar(
                isScrollable: true,
                width: delegate.sideBarTheme?.width,
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
                          .onDrag, // Automatically dismiss the soft keyboard while dragging.
                      children: widget.entries.mapIndexed((index, item) {
                        final category =
                            widget.entries[index] as SelectorCategoryEntry;
                        final entries = category.children?.toList() ?? [];
                        final selectedEntries =
                            controller?.selectedEntriesForParent(category.id,
                                    level: 1) ??
                                {};
                        final isLast = item == widget.entries.last;
                        return SelectorGridView(
                          key: ValueKey('category_$index'),
                          crossAxisCount: widget.crossAxisCount,
                          childAspectRatio: widget.childAspectRatio,
                          mainAxisSpacing: widget.mainAxisSpacing,
                          crossAxisSpacing: widget.crossAxisSpacing,
                          tileVariant: delegate.gridTileTheme?.variant,
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
          delegate.actionBarBuilder?.call(
                context,
                onResetTap: _onResetTap,
                onApplyTap: _onApplyTap,
              ) ??
              SelectorActionBar(
                resetText: delegate.resetText,
                applyText: delegate.applyText,
                resetFlex: delegate.actionBarTheme?.resetFlex,
                applyFlex: delegate.actionBarTheme?.applyFlex,
                onResetTap: _onResetTap,
                onApplyTap: _onApplyTap,
              ),
      ],
    );
  }
}

class PlattenSelectorSkeleton extends StatelessWidget {
  /// Loading skeleton for [FlattenSelector].
  const PlattenSelectorSkeleton({
    super.key,
    this.sideBarWidth,
    this.categoryBackgroundColor,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
  });

  final double? sideBarWidth;

  final Color? categoryBackgroundColor;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final theme = SelectorTheme.of(context);

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
                SelectorSideBarSkeleton(
                  width: sideBarWidth,
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
