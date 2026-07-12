import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector_delegate.dart';
import '../selector_entry.dart';
import 'selector_controller.dart';
import 'widgets/widgets.dart';

/// Standard list view
/// One-dimensional structured data
///
/// Suitable for "sorting", etc.
class ListSelector extends StatefulWidget {
  final ListSelectorDelegate delegate;
  final List<SelectorEntry> entries;
  final Set<SelectorEntry>? previousSelected;

  const ListSelector({
    super.key,
    required this.delegate,
    required this.entries,
    required this.previousSelected,
  });

  @override
  State<ListSelector> createState() => ListSelectorState();
}

class ListSelectorState extends State<ListSelector> {
  /// Focused category entry
  int _tempSelectedCategoryIndex = 0;

  SelectorController? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectorController(context);
  }

  @override
  void didUpdateWidget(covariant ListSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectorController(context);
  }

  @override
  void dispose() {
    controller?.removeListener(_handleSelectorControllerTick);
    super.dispose();
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

  ListSelectorDelegate get delegate => widget.delegate;

  void _handleSelectorControllerTick() {
    if (mounted) setState(() {});
  }

  SelectionMode? get selectorSelectionMode {
    if (SelectionMode.multiple == categorySelectionMode) {
      return SelectionMode.multiple;
    }
    if (widget.entries.firstWhereOrNull(testMultipleElement) != null) {
      return SelectionMode.multiple;
    }
    return SelectionMode.single;
  }

  SelectionMode? get categorySelectionMode => controller?.selectionMode;

  SelectorCategoryEntry? get selectedCategory =>
      widget.entries.elementAtOrNull(_tempSelectedCategoryIndex)
          as SelectorCategoryEntry;

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
    final isCategoryTree = widget.entries.firstOrNull is SelectorCategoryEntry;
    if (!isCategoryTree) {
      controller?.toggleFlatEntry(
        item,
        selectorSelectionMode: selectorSelectionMode ?? SelectionMode.single,
        isCategoryTree: false,
      );
      _setStateOrImmediateApply(item);
      return;
    }

    final categoryEntry =
        widget.entries.singleWhereOrNull((e) => e.id == item.parentId);
    if (categoryEntry is! SelectorCategoryEntry) {
      return;
    }
    final category = categoryEntry;
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
      // Update UI state
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
    final selectionMode = controller?.selectionMode;

    // final listTileTheme = selector?.listTileTheme;
    // final gridTileTheme = selector?.gridTileTheme;
    final chipBarTheme = delegate.chipBarTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: widget.entries.first is SelectorCategoryEntry
              ? SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(widget.entries.length, (index) {
                      final category =
                          widget.entries[index] as SelectorCategoryEntry;
                      final selectedEntries =
                          controller?.selectedEntriesAtLevel(1) ?? {};
                      final entries = category.children?.toList() ?? [];
                      final listConfig = category.listConfig;
                      final gridConfig = category.gridConfig;
                      final chipConfig = category.chipConfig;
                      return SelectorExpansionTile(
                        title: category.name ?? '',
                        titlePadding: const EdgeInsets.symmetric(vertical: 10),
                        initiallyExpanded: true,
                        child: listConfig != null
                            ? SelectorListView(
                                key: ValueKey('category_$index'),
                                category: category,
                                showTitle: false,
                                entries: entries,
                                selectedEntries: selectedEntries,
                                onItemTap: (index, item) => _onTerminalItemTap(
                                    item as SelectorChildEntry),
                                inputListener:
                                    (categoryId, minValue, maxValue) {
                                  _customItemSelection(
                                    categoryId ?? category.id,
                                    minValue,
                                    maxValue,
                                  );
                                },
                              )
                            : gridConfig != null
                                ? SelectorGridView(
                                    key: ValueKey('category_$index'),
                                    crossAxisCount: gridConfig.crossAxisCount,
                                    mainAxisSpacing: gridConfig.mainAxisSpacing,
                                    crossAxisSpacing:
                                        gridConfig.crossAxisSpacing,
                                    childAspectRatio:
                                        gridConfig.childAspectRatio,
                                    tileVariant:
                                        delegate.gridTileTheme?.variant,
                                    category: category,
                                    showTitle: false,
                                    entries: entries,
                                    selectedEntries: selectedEntries,
                                    onItemTap: (index, item) =>
                                        _onTerminalItemTap(
                                            item as SelectorChildEntry),
                                    focusListener: _focusListener,
                                  )
                                : chipConfig != null
                                    ? SelectorChipBar(
                                        key: ValueKey('category_$index'),
                                        category: category,
                                        entries: entries,
                                        selectedEntries: selectedEntries,
                                        showTitle: false,
                                        isWrapable: true,
                                        backgroundColor:
                                            chipBarTheme?.backgroundColor,
                                        padding: chipBarTheme?.padding,
                                        variant: chipBarTheme?.variant,
                                        chipColor: chipBarTheme?.chipColor,
                                        selectedChipColor:
                                            chipBarTheme?.selectedChipColor,
                                        labelStyle: chipBarTheme?.labelStyle,
                                        selectedLabelStyle:
                                            chipBarTheme?.selectedLabelStyle,
                                        onItemTap: (index, item) =>
                                            _onTerminalItemTap(
                                                item as SelectorChildEntry),
                                        // focusListener: _focusListener,
                                      )
                                    : const SizedBox.shrink(),
                      );
                    }),
                  ),
                )
              : SelectorListView(
                  entries: widget.entries,
                  selectedEntries: controller?.selectedEntriesAtLevel(0) ?? {},
                  onItemTap: (_, entry) =>
                      _onTerminalItemTap(entry as SelectorChildEntry),
                  radioBuilder: delegate.radioBuilder,
                  checkboxBuilder: delegate.checkboxBuilder,
                ),
        ),
        if (SelectionMode.multiple == selectionMode)
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

class ListSelectorSkeleton extends StatelessWidget {
  final SelectionMode selectionMode;

  const ListSelectorSkeleton({
    super.key,
    this.selectionMode = SelectionMode.single,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Flexible(child: SelectorListSkeleton(itemCount: 6)),
        if (SelectionMode.multiple == selectionMode)
          const SelectorActionBarSkeleton(),
      ],
    );
  }
}
