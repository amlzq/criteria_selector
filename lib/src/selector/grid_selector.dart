import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'selector_controller.dart';
import 'selector_delegate.dart';
import 'selector_entry.dart';
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
class GridSelector extends StatefulWidget {
  final GridSelectorDelegate delegate;
  final List<SelectorEntry> entries;
  final Set<SelectorEntry>? previousSelected;

  const GridSelector({
    super.key,
    required this.delegate,
    required this.entries,
    required this.previousSelected,
  });

  @override
  State<GridSelector> createState() => GridSelectorState();
}

class GridSelectorState extends State<GridSelector> {
  /// Focused category entry
  late SelectorCategoryEntry _tempSelectedCategory;

  SelectorController? controller;
  bool _didInitCategoryFromState = false;

  @override
  void initState() {
    super.initState();
    _tempSelectedCategory = widget.entries.first as SelectorCategoryEntry;
  }

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
  void didUpdateWidget(covariant GridSelector oldWidget) {
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
    if (!_didInitCategoryFromState) {
      final selectedCategory = controller
          ?.selectedEntriesAtLevel(0)
          .whereType<SelectorCategoryEntry>()
          .firstOrNull;
      if (selectedCategory != null) {
        _tempSelectedCategory = selectedCategory;
      }
      _didInitCategoryFromState = true;
    }
  }

  GridSelectorDelegate get delegate => widget.delegate;

  void _handleSelectorControllerTick() {
    if (mounted) setState(() {});
  }

  /// Selection Mode for category entries
  SelectionMode? get categorySelectionMode => delegate.selectionMode;

  /// Selection Mode for the selected category sub-items
  SelectionMode get childrenSelectionMode =>
      _tempSelectedCategory.selectionMode;

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

  void _onCategoryItemTap(SelectorCategoryEntry entry) {
    if (entry == _tempSelectedCategory) return;
    _tempSelectedCategory = entry;
    controller?.focusCategoryEntry(
      entry,
      selectionMode: categorySelectionMode ?? SelectionMode.single,
    );
    setState(() {});
  }

  void _onTerminalItemTap(SelectorChildEntry entry) {
    final category = widget.entries
        .whereType<SelectorCategoryEntry>()
        .singleWhereOrNull((e) => e.id == entry.parentId);
    if (category == null) return;

    controller?.toggleFlatEntry(
      entry,
      selectorSelectionMode: selectorSelectionMode ?? SelectionMode.single,
      isCategoryTree: true,
      category: category,
    );

    _setStateOrImmediateApply(entry);
  }

  void _setStateOrImmediateApply(SelectorChildEntry entry) {
    if (SelectionMode.single == selectorSelectionMode || entry.immediate) {
      // No need to tap "Apply"; return result immediately
      _onApplyTap();
    } else {
      setState(() {});
      controller?.emitChangeFromState();
    }
  }

  void _onResetTap() {
    controller?.resetState(initializeAnyIfEmpty: true);
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

  void _onApplyTap() {
    controller?.applyFromState();
  }

  @override
  Widget build(BuildContext context) {
    final gridviews = List.generate(widget.entries.length, (int index) {
      final category = widget.entries[index];
      final entries = category.children?.toList() ?? [];
      final selectedEntries =
          controller?.selectedEntriesForParent(category.id, level: 1) ?? {};
      return SelectorGridView(
        key: ValueKey('category_$index'),
        crossAxisCount: delegate.crossAxisCount,
        childAspectRatio: delegate.childAspectRatio,
        mainAxisSpacing: delegate.mainAxisSpacing,
        crossAxisSpacing: delegate.crossAxisSpacing,
        tileVariant: delegate.gridTileTheme?.variant,
        fieldVariant: delegate.fieldTileTheme?.variant,
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
          SelectorTabBar(
            isScrollable: false,
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

class GridSelectorSkeleton extends StatelessWidget {
  /// Loading skeleton for [GridSelector].
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
        const SelectorTabBarSkeleton(),
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
