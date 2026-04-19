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
bool testMultipleItem(e) =>
    e is SelectorCategoryEntry && e.selectionMode == SelectionMode.multiple;

/// Returns true if the entry is an "Any" child entry.
bool testAnyItem(e) => e is SelectorChildEntry && e.isAny;

/// Returns true if the entry is a custom range entry.
bool testCustomItem(e) => e is SelectorRangeEntry && e.isCustom;

/// Returns true if the entry is not a custom range entry.
bool testNotCustomItem(e) => e is! SelectorRangeEntry || (!e.isCustom);

extension SelectorEntriesExtension on SelectorEntries {
  /// Inserts [option] at the given [index] while preserving set iteration order.
  void insert(int index, SelectorEntry option) {
    final temp = toList();
    temp.insert(index, option);
    clear();
    addAll(temp);
  }

  /// Flattens a selection tree into a list of selections per depth level.
  List<SelectorEntries>? flatten() {
    if (isEmpty) return null;

    List<SelectorEntries> result = [];
    void traverse(SelectorEntries options, int level) {
      if (result.length <= level) {
        result.add({});
      }
      for (var option in options) {
        result[level].add(option);
        if (option.children != null && option.children!.isNotEmpty) {
          traverse(option.children!, level + 1);
        }
      }
    }

    traverse(this, 0);
    return result;
  }
}

extension IterableExtension<SelectorEntry> on Iterable<SelectorEntry> {
  /// Whether this iterable contains an "Any" child entry.
  bool get hasAnyItem => any(testAnyItem);

  /// Whether this iterable contains a custom range entry.
  bool get hasCustomItem => any(testCustomItem);

  /// Returns the first element if it is a custom range entry.
  SelectorRangeEntry? get firstCustomOrNull {
    final element = first;
    if (element != null && element is SelectorRangeEntry && element.isCustom) {
      return element;
    }
    return null;
  }

  /// Returns the last element if it is a custom range entry.
  SelectorRangeEntry? get lastCustomOrNull {
    final element = last;
    if (element != null && element is SelectorRangeEntry && element.isCustom) {
      return element;
    }
    return null;
  }
}
