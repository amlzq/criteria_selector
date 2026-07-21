import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector_entry.dart';
import 'field_tile.dart';
import 'list_tile.dart';
import 'skeleton_box.dart';

/// A list view that can include a single input item.
/// Must be a terminal-node list.
/// Only used in tabs or flatten; uses AutomaticKeepAliveClientMixin.
class SelectorListView<T extends SelectorEntry> extends StatefulWidget {
  const SelectorListView({
    super.key,
    this.category,
    required this.entries,
    this.selectedEntries,
    required this.onItemTap,
    this.inputListener,
    this.padding = EdgeInsets.zero,
    this.selectionMode = SelectionMode.single,
    this.radioBuilder,
    this.checkboxBuilder,
    this.showTitle = true,
  });

  /// The category this list belongs to, used to render its title.
  ///
  /// If provided and [showTitle] is true, the category's name is displayed as
  /// a header above the list. Otherwise no header is shown.
  final SelectorEntry? category;

  /// The terminal-node entries to display as selectable list items.
  ///
  /// This list must be a terminal-node list (no further sub-categories). If it
  /// contains a range/custom entry, an input field is rendered at the header or
  /// footer.
  final List<T> entries;

  /// The set of currently selected entries.
  ///
  /// An item is rendered as selected when it is contained in this set; the
  /// selection is reflected by the radio or checkbox tile.
  final SelectorEntries? selectedEntries;

  /// Called when an item is tapped.
  ///
  /// The callback receives the tapped item's index and its [SelectorEntry].
  final ItemTapCallback onItemTap;

  /// Called when the value of the optional range input field changes.
  ///
  /// Receives the category id along with the current minimum and maximum input
  /// values. Only used when [entries] contains a custom range entry.
  final Function(String? categoryId, String minValue, String maxValue)?
      inputListener;

  /// The padding around the list content, including the title and input field.
  ///
  /// Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry padding;

  /// Determines whether a single or multiple items can be selected.
  ///
  /// Defaults to [SelectionMode.single], which renders radio tiles; when set to
  /// [SelectionMode.multiple], checkbox tiles are used instead.
  final SelectionMode selectionMode;

  /// Optional builder for the radio widget shown in [SelectionMode.single].
  final ToggleWidgetBuilder? radioBuilder;

  /// Optional builder for the checkbox widget shown in [SelectionMode.multiple].
  final ToggleWidgetBuilder? checkboxBuilder;

  /// Whether to show the [category] name as a header above the list.
  ///
  /// Defaults to true. Has no effect when [category] is null.
  final bool showTitle;

  @override
  State<SelectorListView<T>> createState() => SelectorListViewState<T>();
}

class SelectorListViewState<T extends SelectorEntry>
    extends State<SelectorListView<T>> with AutomaticKeepAliveClientMixin {
  SelectorRangeEntry? firstCustomEntry;
  SelectorRangeEntry? lastCustomEntry;

  late List<T> entriesWithoutCustom;

  TextEditingController? _minController;
  TextEditingController? _maxController;

  FocusNode? _minFocusNode;
  FocusNode? _maxFocusNode;

  late SelectorEntries _selectedEntries;

  @override
  void initState() {
    super.initState();

    _selectedEntries = widget.selectedEntries ?? {};

    firstCustomEntry = widget.entries.firstCustomOrNull;
    lastCustomEntry = widget.entries.lastCustomOrNull;

    entriesWithoutCustom = widget.entries;
    if (firstCustomEntry != null || lastCustomEntry != null) {
      entriesWithoutCustom = widget.entries.where(testNotCustomItem).toList();
      _initializeInput();
      _restoreCustomSelectionToInputs();
    }
  }

  @override
  void didUpdateWidget(covariant SelectorListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectedEntries = widget.selectedEntries ?? {};

    firstCustomEntry = widget.entries.firstCustomOrNull;
    lastCustomEntry = widget.entries.lastCustomOrNull;

    entriesWithoutCustom = widget.entries;
    if (firstCustomEntry != null || lastCustomEntry != null) {
      entriesWithoutCustom = widget.entries.where(testNotCustomItem).toList();
      _initializeInput();
      _restoreCustomSelectionToInputs();
    }

    // When the custom range was selected and is now removed (e.g. tapping a
    // preset or clicking reset), clear the input fields so stale values are not
    // left behind, mirroring [SelectorGridViewState.didUpdateWidget]. We only
    // react to this transition (not every rebuild) to avoid clobbering text the
    // user is actively typing.
    final oldHadCustom = (oldWidget.selectedEntries ?? {})
        .any((e) => e is SelectorRangeEntry && e.isCustom);
    final newHasCustom =
        _selectedEntries.any((e) => e is SelectorRangeEntry && e.isCustom);
    if (oldHadCustom && !newHasCustom) {
      _clearAllInput();
      _unfocusAllInput();
    }
  }

  void _restoreCustomSelectionToInputs() {
    final selectedCustom = _selectedEntries
        .whereType<SelectorRangeEntry>()
        .firstWhereOrNull((e) => e.isCustom);
    _minController?.text = selectedCustom?.min?.toString() ?? '';
    _maxController?.text = selectedCustom?.max?.toString() ?? '';
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
    if (widget.selectedEntries?.isNotEmpty ?? false) {
      setState(() {
        widget.selectedEntries?.clear();
      });
    }
    widget.inputListener
        ?.call(widget.category?.id, _minController!.text, _maxController!.text);
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

  void _onItemTap(int index, T entry) {
    // Clear custom input
    _clearAllInput();
    _unfocusAllInput();
    widget.onItemTap(index, entry);
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
          if (firstCustomEntry != null)
            SelectorFieldTile(
              firstCustomEntry!,
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
            itemCount: entriesWithoutCustom.length,
            itemBuilder: (context, index) {
              final entry = entriesWithoutCustom[index];
              final selected = widget.selectedEntries?.contains(entry) ?? false;
              if (SelectionMode.single == widget.selectionMode) {
                return SelectorRadioListTile(
                  onTap: () => _onItemTap(index, entry),
                  label: entry.name ?? '',
                  selected: selected,
                  radioBuilder: widget.radioBuilder,
                );
              } else {
                return SelectorCheckboxListTile(
                  onTap: () => _onItemTap(index, entry),
                  label: entry.name ?? '',
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
          if (lastCustomEntry != null)
            SelectorFieldTile(
              lastCustomEntry!,
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

  /// The number of placeholder items to render in the skeleton.
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
