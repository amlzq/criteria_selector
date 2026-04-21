import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../selector_entry.dart';
import 'field_tile.dart';
import 'list_tile.dart';
import 'skeleton_box.dart';

/// A list view that can include a single input item.
/// Must be a terminal-node list.
/// Only used in tabs or flatten; uses AutomaticKeepAliveClientMixin.
class SelectorListView<T extends SelectorEntry> extends StatefulWidget {
  const SelectorListView({
    super.key,
    this.categoryId,
    this.categoryName,
    required this.items,
    this.selectedItems,
    required this.onItemTap,
    this.inputListener,
    this.padding,
    this.selectionMode = SelectionMode.single,
    this.radioBuilder,
    this.checkboxBuilder,
  });

  final String? categoryId;
  final String? categoryName;

  final List<T> items;
  final SelectorEntries? selectedItems;

  final ItemTapCallback onItemTap;

  final Function(String? categoryId, String minValue, String maxValue)?
      inputListener;

  final EdgeInsetsGeometry? padding;

  final SelectionMode selectionMode;

  final ToggleWidgetBuilder? radioBuilder;
  final ToggleWidgetBuilder? checkboxBuilder;

  @override
  State<SelectorListView<T>> createState() => SelectorListViewState<T>();
}

class SelectorListViewState<T extends SelectorEntry>
    extends State<SelectorListView<T>> with AutomaticKeepAliveClientMixin {
  SelectorRangeEntry? firstCustomItem;
  SelectorRangeEntry? lastCustomItem;

  late List<T> itemsWithoutCustom;

  TextEditingController? _minController;
  TextEditingController? _maxController;

  FocusNode? _minFocusNode;
  FocusNode? _maxFocusNode;

  @override
  void initState() {
    super.initState();

    firstCustomItem = widget.items.firstCustomOrNull;
    lastCustomItem = widget.items.lastCustomOrNull;

    itemsWithoutCustom = widget.items;
    if (firstCustomItem != null || lastCustomItem != null) {
      itemsWithoutCustom = widget.items.where(testNotCustomItem).toList();
      _initializeInput();
      _minController?.text =
          (firstCustomItem ?? lastCustomItem)!.min?.toString() ?? '';
      _maxController?.text =
          (firstCustomItem ?? lastCustomItem)!.max?.toString() ?? '';
    }
  }

  @override
  void didUpdateWidget(covariant SelectorListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _minController?.text =
        (firstCustomItem ?? lastCustomItem)!.min?.toString() ?? '';
    _maxController?.text =
        (firstCustomItem ?? lastCustomItem)!.max?.toString() ?? '';
  }

  @override
  void dispose() {
    _minController?.removeListener(_inputListener);
    _maxController?.removeListener(_inputListener);

    _minController?.dispose();
    _maxController?.dispose();

    _minFocusNode?.dispose();
    _maxFocusNode?.dispose();

    super.dispose();
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
    if (widget.selectedItems?.isNotEmpty ?? false) {
      setState(() {
        widget.selectedItems?.clear();
      });
    }
    widget.inputListener
        ?.call(widget.categoryId, _minController!.text, _maxController!.text);
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

  void _onItemTap(int index, T item) {
    // Clear custom input
    _clearAllInput();
    _unfocusAllInput();
    widget.onItemTap(index, item);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category title
          if (widget.categoryName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                widget.categoryName ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          // An input item at header
          if (firstCustomItem != null)
            SelectorFieldTile(
              firstCustomItem!,
              padding: const EdgeInsets.only(top: 10.0),
              minController: _minController,
              maxController: _maxController,
              minFocusNode: _minFocusNode,
              maxFocusNode: _maxFocusNode,
            ),
          // List of items
          ListView.separated(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: itemsWithoutCustom.length,
            itemBuilder: (context, index) {
              final item = itemsWithoutCustom[index];
              final selected = widget.selectedItems?.contains(item) ?? false;
              if (SelectionMode.single == widget.selectionMode) {
                return SelectorRadioListTile(
                  onTap: () => _onItemTap(index, item),
                  label: item.name ?? '',
                  selected: selected,
                  radioBuilder: widget.radioBuilder,
                );
              } else {
                return SelectorCheckboxListTile(
                  onTap: () => _onItemTap(index, item),
                  label: item.name ?? '',
                  checked: selected,
                  checkboxBuilder: widget.checkboxBuilder,
                );
              }
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 6);
            },
          ),
          // An input item at footer
          if (lastCustomItem != null)
            SelectorFieldTile(
              lastCustomItem!,
              padding: const EdgeInsets.only(top: 10.0),
              minController: _minController,
              maxController: _maxController,
              minFocusNode: _minFocusNode,
              maxFocusNode: _maxFocusNode,
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// Loading skeleton for [SelectorListView].
class SelectorListSkeleton extends StatelessWidget {
  const SelectorListSkeleton({super.key, required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final random = Random();
    return SkeletonBox(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return SkeletonTile(
            random: random,
            widthUsed: 30,
            height: kSelectorListTileHeight,
            borderRadius: BorderRadius.circular(4),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 6);
        },
      ),
    );
  }
}
