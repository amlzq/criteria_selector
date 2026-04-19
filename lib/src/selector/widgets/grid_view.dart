import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../selector_entry.dart';
import 'field_tile.dart';
import 'grid_tile.dart';
import 'grid_tile_theme.dart';
import 'skeleton_box.dart';

/// A grid view that can include a single input item.
/// Only used in tabs or flatten; uses AutomaticKeepAliveClientMixin.
class SelectorGridView<T extends SelectorEntry> extends StatefulWidget {
  const SelectorGridView({
    super.key,
    // required this.index,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.category,
    required this.items,
    this.selectedItems,
    required this.onItemTap,
    this.inputListener,
    this.padding,
    this.tileVariant,
  });

  // final int index;
  final SelectorCategoryEntry? category;
  final List<T> items;
  final SelectorEntries? selectedItems;

  final ItemTapCallback onItemTap;

  final Function(String categoryId, String minValue, String maxValue)?
      inputListener;

  final EdgeInsetsGeometry? padding;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  final SelectorGridTileVariant? tileVariant;

  @override
  State<SelectorGridView<T>> createState() => SelectorGridViewState<T>();
}

class SelectorGridViewState<T extends SelectorEntry>
    extends State<SelectorGridView<T>> with AutomaticKeepAliveClientMixin {
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
    if (inputNotEmpty) {
      if (widget.selectedItems?.isNotEmpty ?? false) {
        setState(() {
          widget.selectedItems?.clear();
        });
      }
      final categoryId = widget.category?.id ??
          (widget.items.first as SelectorChildEntry).parentId;
      widget.inputListener
          ?.call(categoryId, _minController!.text, _maxController!.text);
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

  void _onItemTap(int index, T item) {
    // Clear custom input
    _clearAllInput();
    _unfocusAllInput();
    widget.onItemTap(index, item);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category title
          if (widget.category != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                widget.category?.name ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          if (firstCustomItem != null)
            SelectorFieldTile(
              firstCustomItem!,
              padding: const EdgeInsets.only(top: 10.0),
              minController: _minController,
              maxController: _maxController,
              minFocusNode: _minFocusNode,
              maxFocusNode: _maxFocusNode,
            ),
          // Grid of items (3 columns)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount,
              childAspectRatio: widget.childAspectRatio,
              mainAxisSpacing: widget.mainAxisSpacing,
              crossAxisSpacing: widget.crossAxisSpacing,
            ),
            itemCount: itemsWithoutCustom.length,
            itemBuilder: (context, index) {
              final item = itemsWithoutCustom[index];
              final selected = widget.selectedItems?.contains(item) ?? false;
              return SelectorGridTile(
                onTap: () => _onItemTap.call(index, item),
                enabled: item.enabled,
                label: item.name ?? '',
                selected: selected,
                variant: widget.tileVariant,
              );
            },
          ),
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

/// Loading skeleton for [SelectorGridView].
class SelectorGridSkeleton extends StatelessWidget {
  const SelectorGridSkeleton({
    super.key,
    required this.itemCount,
    this.padding,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
  });

  final int itemCount;

  final EdgeInsetsGeometry? padding;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final random = Random();
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: SkeletonBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SkeletonTile(random: random, height: 24),
            ),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                ),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  return SkeletonTile(
                    borderRadius: BorderRadius.circular(4),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
