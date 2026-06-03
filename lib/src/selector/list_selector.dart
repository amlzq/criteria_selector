import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector.dart';
import '../selector_entry.dart';
import '../selector_utils.dart';
import 'selector_controller.dart';
import 'widgets/widgets.dart';

/// Standard list view
/// One-dimensional structured data
///
/// Suitable for "sorting", etc.
class ListSelectorView extends StatefulWidget {
  final List<SelectorEntry> entries;
  final Set<SelectorEntry>? previousSelected;

  const ListSelectorView({
    super.key,
    required this.entries,
    required this.previousSelected,
  });

  @override
  State<ListSelectorView> createState() => ListSelectorViewState();
}

class ListSelectorViewState extends State<ListSelectorView> {
  /// Focused category entry
  int _tempSelectedCategoryIndex = 0;

  final List<SelectorEntries> _selectedEntriesPerLevel = [];

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectorController(context);
  }

  @override
  void didUpdateWidget(covariant ListSelectorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSelectorController(context);
  }

  void _updateSelectorController(BuildContext context) {
    if (controller == null) {
      controller = SelectorController.of(context)!;
      controller?.addListener(_handleSelectorControllerTick);
    }
  }

  ListSelector? get selector => controller?.selector as ListSelector;

  void _handleSelectorControllerTick() {}

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
    final isCategoryTree = widget.entries.firstOrNull is SelectorCategoryEntry;
    final requiredLevel = isCategoryTree ? 2 : 1;
    while (_selectedEntriesPerLevel.length < requiredLevel) {
      _selectedEntriesPerLevel.add({});
    }

    if (!isCategoryTree) {
      final selectedEntries = _selectedEntriesPerLevel[0];
      final selectionMode = controller?.selectionMode ?? SelectionMode.single;

      if (item.isAny) {
        selectedEntries
          ..clear()
          ..add(item);
      } else {
        selectedEntries.removeWhere((e) => e is SelectorChildEntry && e.isAny);
        if (SelectionMode.single == selectionMode) {
          if (selectedEntries.contains(item)) {
            return;
          }
          selectedEntries
            ..clear()
            ..add(item);
        } else {
          if (selectedEntries.contains(item)) {
            selectedEntries.remove(item);
          } else {
            selectedEntries.add(item);
          }
        }
      }

      _setStateOrImmediateApply(item);
      return;
    }

    final categoryEntry =
        widget.entries.singleWhereOrNull((e) => e.id == item.parentId);
    if (categoryEntry is! SelectorCategoryEntry) {
      return;
    }
    final category = categoryEntry;

    final childrenSelectionMode = category.selectionMode;
    final selectedEntries = _selectedEntriesPerLevel[1];

    if (item.isAny) {
      selectedEntries
          .removeWhere((e) => testSameParentElement(e, item.parentId));
      selectedEntries.add(item);
    } else if (item is SelectorRangeEntry && item.isCustom) {
      selectedEntries
          .removeWhere((e) => testSameParentElement(e, item.parentId));
      selectedEntries.add(item);
    } else {
      selectedEntries.removeWhere((e) =>
          (e as SelectorChildEntry).parentId == item.parentId && e.isAny);

      if (SelectionMode.single == childrenSelectionMode) {
        if (selectedEntries.contains(item)) {
          return;
        }
        selectedEntries
            .removeWhere((e) => testSameParentElement(e, item.parentId));
        selectedEntries.add(item);
      } else {
        if (selectedEntries.contains(item)) {
          selectedEntries.remove(item);
        } else {
          selectedEntries.add(item);
        }
      }
    }

    final hasSelectionInCategory =
        selectedEntries.any((e) => testSameParentElement(e, category.id));
    if (hasSelectionInCategory) {
      _selectedEntriesPerLevel[0].add(category);
    } else {
      final anyItem = category.children?.singleWhereOrNull(testAnyElement);
      if (anyItem != null) {
        selectedEntries.add(anyItem);
        _selectedEntriesPerLevel[0].add(category);
      } else {
        _selectedEntriesPerLevel[0].remove(category);
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
    final selectionMode = controller?.selectionMode;

    // final listTileTheme = selector?.listTileTheme;
    // final gridTileTheme = selector?.gridTileTheme;
    final chipBarTheme = selector?.chipBarTheme;

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
                          _selectedEntriesPerLevel.elementAtOrNull(1) ?? {};
                      final entries = category.children?.toList() ?? [];
                      final listConfig = category.listConfig;
                      final gridConfig = category.gridConfig;
                      final chipConfig = category.chipConfig;
                      return SelectorExpansionTile(
                        title: Text(category.name ?? ''),
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
                                // focusListener: _focusListener,
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
                                        selector?.gridTileTheme?.variant,
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
                  selectedEntries:
                      _selectedEntriesPerLevel.elementAtOrNull(0) ?? {},
                  onItemTap: (_, entry) =>
                      _onTerminalItemTap(entry as SelectorChildEntry),
                  radioBuilder: selector?.radioBuilder,
                  checkboxBuilder: selector?.checkboxBuilder,
                ),
        ),
        if (SelectionMode.multiple == selectionMode)
          selector?.actionBarBuilder?.call(
                context,
                onResetTap: _onResetTap,
                onApplyTap: _onApplyTap,
              ) ??
              SelectorActionBar(
                resetText: selector?.resetText,
                applyText: selector?.applyText,
                resetFlex: selector?.actionBarTheme?.resetFlex,
                applyFlex: selector?.actionBarTheme?.applyFlex,
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
