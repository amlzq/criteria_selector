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
    required this.entries,
    this.selectedEntries,
    required this.onItemTap,
    this.focusListener,
    this.padding,
    this.tileVariant,
  });

  // final int index;
  final SelectorCategoryEntry? category;
  final List<T> entries;
  final SelectorEntries? selectedEntries;

  final ItemTapCallback onItemTap;

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
  SelectorRangeEntry? _firstCustomEntry;
  SelectorRangeEntry? _lastCustomEntry;

  late List<T> _entriesWithoutCustom;

  TextEditingController? _minController;
  TextEditingController? _maxController;

  FocusNode? _minFocusNode;
  FocusNode? _maxFocusNode;

  late SelectorEntries _selectedEntries;

  late String _categoryId;

  @override
  void initState() {
    super.initState();

    _selectedEntries = widget.selectedEntries ?? {};

    _firstCustomEntry = widget.entries.firstCustomOrNull;
    _lastCustomEntry = widget.entries.lastCustomOrNull;
    _entriesWithoutCustom = widget.entries;
    if (_firstCustomEntry != null || _lastCustomEntry != null) {
      _entriesWithoutCustom = widget.entries.where(testNotCustomItem).toList();
      _minController ??= TextEditingController();
      _maxController ??= TextEditingController();
      _minFocusNode ??= FocusNode();
      _maxFocusNode ??= FocusNode();
    }

    // 恢复自定义项的选中状态
    for (var selectedEntry in _selectedEntries) {
      if (selectedEntry is SelectorRangeEntry && selectedEntry.isCustom) {
        _minController?.text = selectedEntry.min?.toString() ?? '';
        _maxController?.text = selectedEntry.max?.toString() ?? '';
      }
    }

    _categoryId = widget.category?.id ??
        (widget.entries.first as SelectorChildEntry).parentId;

    _minFocusNode?.addListener(_focusListener);
    _maxFocusNode?.addListener(_focusListener);
  }

  @override
  void didUpdateWidget(covariant SelectorGridView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    _selectedEntries = widget.selectedEntries ?? {};

    _firstCustomEntry = widget.entries.firstCustomOrNull;
    _lastCustomEntry = widget.entries.lastCustomOrNull;
    _entriesWithoutCustom = widget.entries;
    if (_firstCustomEntry != null || _lastCustomEntry != null) {
      _entriesWithoutCustom = widget.entries.where(testNotCustomItem).toList();
    }

    // 恢复自定义项的选中状态
    for (var selectedEntry in _selectedEntries) {
      if (selectedEntry is SelectorRangeEntry && selectedEntry.isCustom) {
        _minController?.text = selectedEntry.min?.toString() ?? '';
        _maxController?.text = selectedEntry.max?.toString() ?? '';
      }
    }

    _categoryId = widget.category?.id ??
        (widget.entries.first as SelectorChildEntry).parentId;

    if (!inputNotEmpty) {
      _unfocusAllInput();
    }
  }

  @override
  void dispose() {
    _minFocusNode?.removeListener(_focusListener);
    _maxFocusNode?.removeListener(_focusListener);

    _minController?.dispose();
    _maxController?.dispose();
    _minFocusNode?.dispose();
    _maxFocusNode?.dispose();

    super.dispose();
  }

  void _focusListener() {
    if (!(_minFocusNode?.hasFocus == true) &&
        !(_maxFocusNode?.hasFocus == true)) {
      widget.focusListener
          ?.call(_categoryId, _minController!.text, _maxController!.text);
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
          if (_firstCustomEntry != null)
            SelectorFieldTile(
              _firstCustomEntry!,
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
            itemCount: _entriesWithoutCustom.length,
            itemBuilder: (context, index) {
              final entry = _entriesWithoutCustom[index];
              final selected = _selectedEntries.contains(entry);
              return SelectorGridTile(
                onTap: () => _onItemTap.call(index, entry),
                enabled: entry.enabled,
                label: entry.name ?? '',
                selected: selected,
                variant: widget.tileVariant,
              );
            },
          ),
          if (_lastCustomEntry != null)
            SelectorFieldTile(
              _lastCustomEntry!,
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
