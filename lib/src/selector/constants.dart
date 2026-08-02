import 'package:flutter/material.dart';

import '../selector/selector_controller.dart';
import '../selector_label_state.dart';
import 'selector_entry.dart';
import 'selector_utils.dart';

/// Callback invoked with the currently selected entries.
typedef SelectorCallback = void Function(SelectorEntries selected);

/// Tab-agnostic change callback used internally by [DropdownSelectorController].
///
/// Suitable for [DropdownSelectorButton], which has no tab concept, as well as
/// multi-tab [DropdownSelectorBar].
typedef SelectorLabelChangeCallback = void Function(
    SelectorLabelState labelState, SelectorEntries selected);

/// Builds a custom label for a selector / tab from the applied selection.
///
/// Receives only the [selected] entries. This is the canonical label-loader type
/// and is used by [DropdownTabData.labelLoader] / [DropdownTab.labelLoader] /
/// [DropdownSelectorButton.labelLoader].
typedef SelectorLabelLoader = String Function(SelectorEntries selected);

/// Badge rendering style.
enum BadgeStyle {
  number,
  dot,
}

/// Selection mode for a category or selector.
enum SelectionMode {
  single,
  multiple,
}

/// Default horizontal padding for selector labels.
const EdgeInsets kSelectorLabelPadding = EdgeInsets.symmetric(horizontal: 16.0);

/// Default width for the category tile column.
const kSelectorCategoryTileWidth = 80.0;

/// Builds a selector widget from async data and its controller.
typedef SelectorBuilder = Widget Function(
  BuildContext context,
  Future<SelectorEntries>? asyncData,
  SelectorController selectorController,
);

/// Builds a custom toggle widget (radio/checkbox).
typedef ToggleWidgetBuilder = Widget Function(
    BuildContext context, bool selected);

/// Builds a skeleton widget while selector data is loading.
typedef SkeletonBuilder = Widget Function(BuildContext context);

/// Returns true if the entry is a multi-selection category.
bool testMultipleElement(e) =>
    e is SelectorCategoryEntry && e.selectionMode == SelectionMode.multiple;

/// Returns true if the entry is an "Any" child entry.
bool testAnyElement(e) => e is SelectorChildEntry && e.isAny;

/// Returns true if the entry is a custom range entry.
bool testCustomElement(e) => e is SelectorRangeEntry && e.isCustom;

/// Returns true if the entry is not a custom range entry.
bool testNotCustomItem(e) => e is! SelectorRangeEntry || (!e.isCustom);

/// Returns true if the entry has the same parent as the given [parentId].
bool testSameParentElement(e, parentId) =>
    (e as SelectorChildEntry).parentId == parentId;

/// Returns true if the entry has the same parent as the given [parentId] and is an "Any" or a custom range entry.
bool testSameParentAnyOrCustomElement(e, parentId) =>
    (e as SelectorChildEntry).parentId == parentId &&
    (e.isAny || (e is SelectorRangeEntry && e.isCustom));

extension SelectorEntriesExtension on SelectorEntries {
  /// Inserts [entry] at the given [index] while preserving set iteration order.
  void insert(int index, SelectorEntry entry) {
    final temp = toList();
    temp.insert(index, entry);
    clear();
    addAll(temp);
  }

  /// Flattens a selection tree into a list of selections per depth level.
  List<SelectorEntries>? flatten() {
    if (isEmpty) return null;

    List<SelectorEntries> result = [];
    void traverse(SelectorEntries entries, int level) {
      if (result.length <= level) {
        result.add({});
      }
      for (var entry in entries) {
        result[level].add(entry);
        if (entry is SelectorCategoryEntry) {
          final header = entry.header;
          final headerChildren = header?.children;
          if (header != null &&
              headerChildren != null &&
              headerChildren.isNotEmpty) {
            traverse({header}, level + 1);
          }

          final footer = entry.footer;
          final footerChildren = footer?.children;
          if (footer != null &&
              footerChildren != null &&
              footerChildren.isNotEmpty) {
            traverse({footer}, level + 1);
          }
        }
        if (entry.children != null && entry.children!.isNotEmpty) {
          traverse(entry.children!, level + 1);
        }
      }
    }

    traverse(this, 0);
    return result;
  }

  /// Finds the first selected top-level entry (category) whose [id] matches
  /// [categoryId], or `null` if no such category is selected.
  ///
  /// This is the entry point for most of the convenience query helpers below.
  /// Because it lives on this extension it is available on a bare
  /// [SelectorEntries] — e.g. the return value of `showSelector` /
  /// `showModalBottomSelector`.
  SelectorEntry? findCategory(String categoryId) =>
      where((e) => e.id == categoryId).firstOrNull;

  /// Returns the ids of all direct children of the category with [categoryId].
  ///
  /// Returns an empty list when the category is not selected or has no
  /// children. Equivalent to iterating `category.children` and collecting
  /// each `e.id`.
  List<String> childIdsOf(String categoryId) {
    final category = findCategory(categoryId);
    if (category?.children == null) return const [];
    return category!.children!.map((e) => e.id).toList(growable: false);
  }

  /// Returns all direct children of the category with [categoryId] that are
  /// [SelectorRangeEntry] values (e.g. price/area ranges carrying `min`/`max`).
  ///
  /// Returns an empty list when the category is not selected or has no range
  /// children. The returned entries expose `min`/`max` as `dynamic`, so
  /// callers can cast them to the expected numeric type as needed.
  List<SelectorRangeEntry> childRangesOf(String categoryId) {
    final category = findCategory(categoryId);
    if (category?.children == null) return const [];
    return category!.children!
        .whereType<SelectorRangeEntry>()
        .toList(growable: false);
  }

  /// Returns parent → child-id pairs for a cascading category
  /// (e.g. region/metro with districts and sub-districts).
  ///
  /// Each record carries the parent's [id] and a [childIds] list of the ids of
  /// its direct children. Returns an empty list when the category is not
  /// selected or has no children.
  List<({String id, List<String> childIds})> cascadingPairsOf(
    String categoryId,
  ) {
    final category = findCategory(categoryId);
    if (category?.children == null) return const [];
    return category!.children!.map((parent) {
      final childIds = (parent.children ?? const <SelectorEntry>[])
          .map((c) => c.id)
          .toList(growable: false);
      return (id: parent.id, childIds: childIds);
    }).toList(growable: false);
  }

  /// Returns the child entries of [entry] located at the given tree [level].
  ///
  /// A level of `0` returns [entry] itself; level `1` returns its direct
  /// children; deeper levels walk further down the tree.
  Set<SelectorEntry> findChildrenAtLevel(SelectorEntry entry, int level) =>
      SelectorUtils.findChildrenAtLevel(entry, level);

  /// Returns the ids of the children of [entry] located at the given tree [level].
  ///
  /// See [findChildrenAtLevel] for the level semantics.
  Set<String> findIdsAtLevel(SelectorEntry entry, int level) =>
      SelectorUtils.findIdsAtLevel(entry, level);

  /// Returns the extra ids of the children of [entry] located at the given tree
  /// [level].
  ///
  /// See [findChildrenAtLevel] for the level semantics.
  List<String> findExtrasAtLevel(SelectorEntry entry, int level) =>
      SelectorUtils.findExtrasAtLevel(entry, level);

  /// Returns the id of the first selected entry, or `null` when nothing is
  /// selected. Convenience accessor for single-selection tabs such as sort
  /// order.
  String? get firstSelectedId => firstOrNull?.id;
}

extension IterableExtension<SelectorEntry> on Iterable<SelectorEntry> {
  /// Whether this iterable contains an "Any" child entry.
  bool get hasAnyItem => any(testAnyElement);

  /// Whether this iterable contains a custom range entry.
  bool get hasCustomItem => any(testCustomElement);

  /// Returns the first element if it is a custom range entry.
  SelectorRangeEntry? get firstCustomOrNull {
    final element = firstOrNull;
    if (element != null && element is SelectorRangeEntry && element.isCustom) {
      return element;
    }
    return null;
  }

  /// Returns the last element if it is a custom range entry.
  SelectorRangeEntry? get lastCustomOrNull {
    final element = lastOrNull;
    if (element != null && element is SelectorRangeEntry && element.isCustom) {
      return element;
    }
    return null;
  }
}


