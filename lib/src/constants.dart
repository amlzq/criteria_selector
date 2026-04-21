import 'package:flutter/material.dart';

import 'dropselect_result.dart';
import 'dropselect_tab_data.dart';
import 'selector/selector_controller.dart';
import 'selector_entry.dart';

/// A set of selected [SelectorEntry] values.
typedef SelectorEntries<T> = Set<SelectorEntry<T>>;

/// Callback invoked when the selection changes or is applied.
typedef DropselectResultCallback = void Function(DropselectResult result);

/// Callback invoked with the currently selected entries.
typedef SelectorCallback = void Function(SelectorEntries selected);

/// Callback invoked when an item in a list/grid is tapped.
typedef ItemTapCallback<T extends SelectorEntry> = Function(int index, T item);

/// Callback parameter indicates which selector is being shown or hidden.
typedef SelectorVisibilityCallback = void Function(DropselectTabData tabData);

/// Builds a custom label for a tab based on the current [DropselectResult].
typedef DropselectTabLabelGetter = String Function(DropselectResult result);

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
        if (entry.children != null && entry.children!.isNotEmpty) {
          traverse(entry.children!, level + 1);
        }
      }
    }

    traverse(this, 0);
    return result;
  }
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
