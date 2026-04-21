import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector.dart';
import '../selector_entry.dart';
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
  final SelectorEntries _selectedItems = {};

  SelectorController? controller;

  @override
  void initState() {
    super.initState();

    if (widget.previousSelected != null &&
        (widget.previousSelected?.isNotEmpty ?? false)) {
      for (var selectedItem in widget.previousSelected ?? {}) {
        final item =
            widget.entries.singleWhereOrNull((e) => e.id == selectedItem.id);
        if (item != null) {
          _selectedItems.add(item);
        }
      }
    }
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

  SelectionMode? get categorySelectionMode => controller?.selectionMode;

  void _onItemTap(int index, SelectorChildEntry item) {
    if (item.isAny) {
      // "Any" entry
      if (SelectionMode.single == categorySelectionMode) {
        // Single-select mode
        if (_selectedItems.contains(item)) {
          return;
        } else {
          // Clear selected list
          _selectedItems
            ..clear()
            ..add(item);
        }
      } else {
        // Multi-select mode
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          // Remove items that share the same parent from the selected list
          _selectedItems.removeWhere(
              (e) => (e as SelectorChildEntry).parentId == item.parentId);
          _selectedItems.add(item);
        }
      }
    } else {
      // Normal entry

      // If there is an "Any" entry, remove it
      _selectedItems.removeWhere((e) => e is SelectorChildEntry && e.isAny);

      if (SelectionMode.single == categorySelectionMode) {
        // Single-select mode
        if (_selectedItems.contains(item)) {
          return;
        } else {
          _selectedItems
            ..clear()
            ..add(item);
        }
      } else {
        // Multi-select mode
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          _selectedItems.add(item);
        }
      }
    }

    _setStateOrImmediateApply(item);
  }

  void _setStateOrImmediateApply(SelectorChildEntry item) {
    if (SelectionMode.single == selector?.selectionMode || item.immediate) {
      // No need to tap "Apply"; return result immediately
      _onApplyTap();
    } else {
      // Update UI state
      setState(() {});

      final entries = widget.entries.toSet();
      entries.removeWhere((e) => !_selectedItems.contains(e));
      controller?.change(entries);
    }
  }

  void _onResetTap() {
    _selectedItems.clear();

    final selectedItems = controller?.resetSelected;
    if (selectedItems != null && selectedItems.isNotEmpty) {
      for (var selectedItem in selectedItems) {
        final item =
            widget.entries.singleWhereOrNull((e) => e.id == selectedItem.id);
        if (item != null) {
          _selectedItems.add(item);
        }
      }
    }

    // _selectedCategory =
    //     _selectedItemsPerLevel[0].first as SelectorCategoryEntry;

    setState(() {});
    controller?.reset();
  }

  void _onApplyTap() {
    final entries = widget.entries.toSet();
    entries.removeWhere((e) => !_selectedItems.contains(e));
    controller?.apply(entries);
  }

  @override
  Widget build(BuildContext context) {
    final selectionMode = controller?.selectionMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SelectorListView(
            items: widget.entries,
            selectedItems: _selectedItems,
            onItemTap: (index, item) =>
                _onItemTap(index, item as SelectorChildEntry),
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
