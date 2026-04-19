import 'dart:collection';

import 'package:collection/collection.dart';

import 'constants.dart';
import 'selector_entry.dart';

/// Utility methods for working with [SelectorEntry] trees and selections.
class SelectorUtils {
  /// Returns the entries at the given tree [level] starting from [option].
  ///
  /// - If [level] is 0, returns a set containing [option].
  /// - If [level] is greater than the depth under [option], returns an empty set.
  static SelectorEntries findChildrenAtLevel(SelectorEntry option, int level) {
    // If level == 0, the current node is the target.
    if (level == 0) return {option};

    // If there are no children, any level > 0 cannot be found.
    if (option.children == null || option.children!.isEmpty) return {};

    // Recurse into the next level
    SelectorEntries result = {};
    for (var child in option.children ?? {}) {
      result.addAll(findChildrenAtLevel(child, level - 1));
    }
    return result;
  }

  /// Returns the entry ids at the given tree [level] starting from [option].
  static Set<String> findIdsAtLevel(SelectorEntry option, int level) {
    // If level == 0, the current node is the target.
    if (level == 0) return {option.id};

    // If there are no children, any level > 0 cannot be found.
    if (option.children == null || option.children!.isEmpty) return {};

    // Recurse into the next level
    Set<String> result = {};
    for (var child in option.children ?? {}) {
      result.addAll(findIdsAtLevel(child, level - 1));
    }
    return result;
  }

  /// Returns the `extra` payload values at the given tree [level] starting from
  /// [option].
  ///
  /// The result contains values in traversal order, and each value is cast to
  /// [E]. If a node's `extra` is not assignable to [E], a runtime error may be
  /// thrown.
  static List<E> findExtrasAtLevel<E>(SelectorEntry option, int level) {
    // If level == 0, the current node is the target.
    if (level == 0) return [option.extra as E];

    // If there are no children, any level > 0 cannot be found.
    if (option.children == null || option.children!.isEmpty) return [];

    // Recurse into the next level
    List<E> result = [];
    for (var child in option.children ?? {}) {
      result.addAll(findExtrasAtLevel(child, level - 1));
    }
    return result;
  }

  /// Flattens a tree into a list of entry sets grouped by depth level.
  static List<SelectorEntries> flattenTree(SelectorEntry? root) {
    if (root == null) return [];

    final List<SelectorEntries> resultLevels = [];

    // Use a Queue to store nodes to be processed
    final Queue<SelectorEntry> queue = Queue()..add(root);

    while (queue.isNotEmpty) {
      // Key step: record the current queue size at the start of processing this level
      final int levelSize = queue.length;

      // Create a Set for the current level to ensure uniqueness
      final SelectorEntries currentLevelSet = {};

      // Loop levelSize times to process only nodes in this level
      for (int i = 0; i < levelSize; i++) {
        final SelectorEntry option = queue.removeFirst();
        currentLevelSet.add(option);

        // Add all children to the queue; they will be processed as the next level
        if (!option.hasChildren) continue;
        for (final child in option.children!) {
          queue.add(child);
        }
      }

      // Add the completed Set (all unique nodes of a level) to the result list
      resultLevels.add(currentLevelSet);
    }
    return resultLevels;
  }

  /// Returns the maximum depth of a tree structure rooted at [root].
  int treeDepth(SelectorEntry? root) {
    if (root?.children == null || root?.children?.isEmpty == true) return 1;
    return 1 + root!.children!.map(treeDepth).fold(0, (a, b) => a > b ? a : b);
  }

  /// Removes unselected nodes from [items] by clipping the tree in-place.
  ///
  /// [selectedItemsPerLevel] represents selected entries per depth level. Nodes
  /// not present at the current [level] are removed, and the process continues
  /// recursively for remaining nodes.
  static void clippingTree(
    SelectorEntries? items,
    List<SelectorEntries> selectedItemsPerLevel,
    int level,
  ) {
    if (items == null || items.isEmpty || selectedItemsPerLevel.isEmpty) {
      return;
    }
    SelectorEntries? selectedItems =
        selectedItemsPerLevel.elementAtOrNull(level);
    if (selectedItems == null || selectedItems.isEmpty) {
      return;
    }
    items.removeWhere((e) => !selectedItems.contains(e));
    if (level + 1 >= selectedItemsPerLevel.length) return;
    for (var item in items) {
      clippingTree(item.children, selectedItemsPerLevel, level + 1);
    }
  }

  /// Restores a previous selection by matching ids within [items].
  ///
  /// Returns selected entries per level. For custom range entries, previously
  /// entered values are restored into the matched entries.
  static List<SelectorEntries> restorePreviousSelected(
      List<SelectorEntry>? items, Set<SelectorEntry>? selectedItems) {
    final result = <SelectorEntries>[];
    _initializeSelectedItemsPerLevel(items, selectedItems, 0, result);
    return result;
  }

  static void _initializeSelectedItemsPerLevel(
      List<SelectorEntry>? items,
      Set<SelectorEntry>? selectedItems,
      int level,
      List<SelectorEntries> result) {
    if (items == null ||
        items.isEmpty ||
        selectedItems == null ||
        selectedItems.isEmpty) {
      return;
    }
    result.add({});
    for (var selectedItem in selectedItems) {
      final item = items.singleWhereOrNull((e) => e.id == selectedItem.id);
      if (item != null) {
        result[level].add(item);
        if (item is SelectorRangeEntry && item.isCustom) {
          // If it's a custom option, restore the previous input values.
          selectedItem as SelectorRangeEntry;
          item.min = selectedItem.min;
          item.max = selectedItem.max;
        }
      }
      if (selectedItem.children?.isNotEmpty == true) {
        _initializeSelectedItemsPerLevel(
            item?.children?.toList(), selectedItem.children, level + 1, result);
      }
    }
  }
}
