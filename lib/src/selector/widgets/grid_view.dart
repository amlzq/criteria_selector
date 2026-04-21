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
    this.focusListener,
    this.padding,
    this.tileVariant,
  });

  // final int index;
  final SelectorCategoryEntry? category;
  final List<T> items;
  final SelectorEntries? selectedItems;

  final ItemTapCallback onItemTap;

  final CustomRangeListener? inputListener;

  final CustomRangeListener? focusListener;

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
  SelectorRangeEntry? _firstCustomItem;
  SelectorRangeEntry? _lastCustomItem;

  late List<T> _itemsWithoutCustom;

  TextEditingController? _minController;
  TextEditingController? _maxController;

  FocusNode? _minFocusNode;
  FocusNode? _maxFocusNode;

  late SelectorEntries _selectedItems;

  late String _categoryId;

  @override
  void initState() {
    super.initState();

    _selectedItems = widget.selectedItems ?? {};

    _firstCustomItem = widget.items.firstCustomOrNull;
    _lastCustomItem = widget.items.lastCustomOrNull;
    _itemsWithoutCustom = widget.items;
    if (_firstCustomItem != null || _lastCustomItem != null) {
      _itemsWithoutCustom = widget.items.where(testNotCustomItem).toList();
      _minController ??= TextEditingController();
      _maxController ??= TextEditingController();
      _minFocusNode ??= FocusNode();
      _maxFocusNode ??= FocusNode();
    }

    // 恢复自定义项的选中状态
    for (var selectedItem in _selectedItems) {
      if (selectedItem is SelectorRangeEntry && selectedItem.isCustom) {
        _minController?.text = selectedItem.min?.toString() ?? '';
        _maxController?.text = selectedItem.max?.toString() ?? '';
      }
    }

    _categoryId = widget.category?.id ??
        (widget.items.first as SelectorChildEntry).parentId;

    _minController?.addListener(_inputListener);
    _maxController?.addListener(_inputListener);
    _minFocusNode?.addListener(_focusListener);
    _maxFocusNode?.addListener(_focusListener);
  }

  @override
  void didUpdateWidget(covariant SelectorGridView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    _selectedItems = widget.selectedItems ?? {};
    debugPrint('didUpdateWidget _selectedItems=${_selectedItems.length}');

    _firstCustomItem = widget.items.firstCustomOrNull;
    _lastCustomItem = widget.items.lastCustomOrNull;
    _itemsWithoutCustom = widget.items;
    if (_firstCustomItem != null || _lastCustomItem != null) {
      _itemsWithoutCustom = widget.items.where(testNotCustomItem).toList();
    }

    // 恢复自定义项的选中状态
    for (var selectedItem in _selectedItems) {
      if (selectedItem is SelectorRangeEntry && selectedItem.isCustom) {
        _minController?.text = selectedItem.min?.toString() ?? '';
        _maxController?.text = selectedItem.max?.toString() ?? '';
      }
    }

    if (!inputNotEmpty) {
      _unfocusAllInput();
    }
  }

  @override
  void dispose() {
    _minController?.removeListener(_inputListener);
    _maxController?.removeListener(_inputListener);
    _minFocusNode?.removeListener(_focusListener);
    _maxFocusNode?.removeListener(_focusListener);

    _minController?.dispose();
    _maxController?.dispose();
    _minFocusNode?.dispose();
    _maxFocusNode?.dispose();

    super.dispose();
  }

  /// Listens to input fields; once the user types, clears selected items
  void _inputListener() {
    // debugPrint('_inputListener $_minController $_maxController');
    // if (_selectedItems.isNotEmpty) {
    //   setState(() {
    //     _selectedItems.clear();
    //   });
    // }
    // widget.inputListener
    //     ?.call(_categoryId, _minController!.text, _maxController!.text);
  }

  void _focusListener() {
    debugPrint('_focusListener $_minFocusNode $_maxFocusNode');
    if (!(_minFocusNode?.hasFocus == true) &&
        !(_maxFocusNode?.hasFocus == true)) {
      widget.focusListener
          ?.call(_categoryId, _minController!.text, _maxController!.text);
    }
    // if (!(_maxFocusNode?.hasFocus == true)) {
    //   widget.focusListener
    //       ?.call(_categoryId, _minController!.text, _maxController!.text);
    // }
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
    _inputListener();
    widget.onItemTap(index, item);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    debugPrint('_selectedItems=${_selectedItems.length}');
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
          if (_firstCustomItem != null)
            SelectorFieldTile(
              _firstCustomItem!,
              padding: const EdgeInsets.only(bottom: 10.0),
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
            itemCount: _itemsWithoutCustom.length,
            itemBuilder: (context, index) {
              final item = _itemsWithoutCustom[index];
              final selected = _selectedItems.contains(item);
              debugPrint('$item $selected');
              return SelectorGridTile(
                onTap: () => _onItemTap.call(index, item),
                enabled: item.enabled,
                label: item.name ?? '',
                selected: selected,
                variant: widget.tileVariant,
              );
            },
          ),
          if (_lastCustomItem != null)
            SelectorFieldTile(
              _lastCustomItem!,
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
