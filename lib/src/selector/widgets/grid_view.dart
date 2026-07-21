import 'dart:math';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector_entry.dart';
import 'field_tile.dart';
import 'field_tile_theme.dart';
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
    this.fieldVariant,
    this.showTitle = true,
  });

  // final int index;
  /// The category this grid belongs to, used to render its title.
  ///
  /// If provided and [showTitle] is true, the category's name is displayed as
  /// a header above the grid. Otherwise no header is shown.
  final SelectorEntry? category;

  /// The terminal-node entries to display as grid tiles.
  ///
  /// This list must be a terminal-node list (no further sub-categories). When
  /// it contains a custom range entry, an input field is rendered at the header
  /// or footer of the grid.
  final List<T> entries;

  /// The set of currently selected entries.
  ///
  /// A tile is rendered as selected when it is contained in this set.
  final SelectorEntries? selectedEntries;

  /// Called when a tile is tapped.
  ///
  /// The callback receives the tapped tile's index and its [SelectorEntry].
  final ItemTapCallback onItemTap;

  /// Called with the latest range input values when the input fields lose
  /// focus.
  ///
  /// Receives the category id along with the current minimum and maximum input
  /// values. Only used when [entries] contains a custom range entry.
  final CustomRangeListener? focusListener;

  /// The padding around the grid, including the title and any range input.
  ///
  /// Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry? padding;

  /// The number of grid columns.
  final int crossAxisCount;

  /// The vertical spacing between grid rows.
  ///
  /// Defaults to 0.0.
  final double mainAxisSpacing;

  /// The horizontal spacing between grid columns.
  ///
  /// Defaults to 0.0.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each tile.
  ///
  /// Defaults to 1.0, which makes each tile square.
  final double childAspectRatio;

  /// The visual variant used to render the non-custom grid tiles.
  final SelectorGridTileVariant? tileVariant;

  /// The visual variant used to render the optional range input field.
  final SelectorFieldTileVariant? fieldVariant;

  /// Whether to show the [category] name as a header above the grid.
  ///
  /// Defaults to true. Has no effect when [category] is null.
  final bool showTitle;

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

    // Restore selection state for custom items.
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

    // Restore selection state for custom items.
    for (var selectedEntry in _selectedEntries) {
      if (selectedEntry is SelectorRangeEntry && selectedEntry.isCustom) {
        _minController?.text = selectedEntry.min?.toString() ?? '';
        _maxController?.text = selectedEntry.max?.toString() ?? '';
      }
    }

    _categoryId = widget.category?.id ??
        (widget.entries.first as SelectorChildEntry).parentId;

    // When the custom range was selected and is now removed (e.g. tapping a
    // preset or clicking reset), clear the input fields so stale values are not
    // left behind. We only react to this transition (not every rebuild) to
    // avoid clobbering text the user is actively typing.
    final oldHadCustom = (oldWidget.selectedEntries ?? {})
        .any((e) => e is SelectorRangeEntry && e.isCustom);
    final newHasCustom =
        _selectedEntries.any((e) => e is SelectorRangeEntry && e.isCustom);
    if (oldHadCustom && !newHasCustom) {
      _clearAllInput();
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
          // Category label
          if (widget.category != null && widget.showTitle)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                widget.category?.name ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          // An input item at header
          if (_firstCustomEntry != null)
            SelectorFieldTile(
              _firstCustomEntry!,
              padding: const EdgeInsets.only(bottom: 10.0),
              minController: _minController,
              maxController: _maxController,
              minFocusNode: _minFocusNode,
              maxFocusNode: _maxFocusNode,
              variant: widget.fieldVariant,
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
          // An input item at footer
          if (_lastCustomEntry != null)
            SelectorFieldTile(
              _lastCustomEntry!,
              padding: const EdgeInsets.only(top: 10.0),
              minController: _minController,
              maxController: _maxController,
              minFocusNode: _minFocusNode,
              maxFocusNode: _maxFocusNode,
              variant: widget.fieldVariant,
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

  /// The number of placeholder tiles to render in the skeleton grid.
  final int itemCount;

  /// The padding around the skeleton, including the title and grid.
  ///
  /// Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry? padding;

  /// The number of grid columns in the skeleton.
  final int crossAxisCount;

  /// The vertical spacing between skeleton rows.
  ///
  /// Defaults to 0.0.
  final double mainAxisSpacing;

  /// The horizontal spacing between skeleton columns.
  ///
  /// Defaults to 0.0.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each placeholder
  /// tile.
  ///
  /// Defaults to 1.0.
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
