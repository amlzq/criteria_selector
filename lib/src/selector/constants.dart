import 'dart:async';

import 'package:flutter/material.dart';

import '../dropdown_selector_result.dart';
import '../dropdown_tab_data.dart';
import '../selector/selector_controller.dart';
import 'selector_entry.dart';

/// A set of selected [SelectorEntry] values.
typedef SelectorEntries<T> = Set<SelectorEntry<T>>;

/// Callback invoked when the selection changes or is applied.
typedef DropdownSelectorResultCallback = void Function(
    DropdownSelectorResult result);

/// Callback invoked with the currently selected entries.
typedef SelectorCallback = void Function(SelectorEntries selected);

/// Callback invoked when an item in a list/grid is tapped.
typedef ItemTapCallback<T extends SelectorEntry> = Function(int index, T entry);

/// Callback parameter indicates which selector is being shown or hidden.
typedef SelectorVisibilityCallback = void Function(DropdownTabData tabData);

/// Callback invoked just before the selector overlay is shown for [tabData].
///
/// The returned [Future] (if any) is awaited *before* the overlay is actually
/// displayed, so callers can run an async task first — for example, animating a
/// [SliverPersistentHeader] to the top of the list — and have the overlay
/// anchored to the final layout. Returning `false` cancels the show, leaving
/// the overlay hidden.
typedef SelectorWillShowCallback = FutureOr<bool> Function(
    DropdownTabData tabData);

/// Callback invoked just before the selector overlay is hidden for [tabData].
/// Returning `false` cancels the hide, leaving the overlay visible.
typedef SelectorWillHideCallback = FutureOr<bool> Function(
    DropdownTabData tabData);

/// Builds a custom label for a tab based on the current [DropdownSelectorResult].
typedef DropdownTabLabelGetter = String Function(DropdownSelectorResult result);

/// Callback invoked when a custom range entry is tapped.
typedef CustomRangeListener = void Function(
    String categoryId, String minValue, String maxValue);

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

const kSelectorCategoryBarMaxWidthFactor = 0.7;

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
  /// `showModalBottomSelector` — not only on [DropdownSelectorResult].
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
