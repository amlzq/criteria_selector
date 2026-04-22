import 'dart:collection';

import 'package:collection/collection.dart';

import 'constants.dart';
import 'selector_entry.dart';

/// Utility methods for working with [SelectorEntry] trees and selections.
class SelectorUtils {
  /// Returns the entries at the given tree [level] starting from [entry].
  ///
  /// - If [level] is 0, returns a set containing [entry].
  /// - If [level] is greater than the depth under [entry], returns an empty set.
  static SelectorEntries findChildrenAtLevel(SelectorEntry entry, int level) {
    // If level == 0, the current entry is the target.
    if (level == 0) return {entry};

    // If there are no children, any level > 0 cannot be found.
    if (entry.children == null || entry.children!.isEmpty) return {};

    // Recurse into the next level
    SelectorEntries result = {};
    for (var child in entry.children ?? {}) {
      result.addAll(findChildrenAtLevel(child, level - 1));
    }
    return result;
  }

  /// Returns the entry ids at the given tree [level] starting from [entry].
  static Set<String> findIdsAtLevel(SelectorEntry entry, int level) {
    // If level == 0, the current entry is the target.
    if (level == 0) return {entry.id};

    // If there are no children, any level > 0 cannot be found.
    if (entry.children == null || entry.children!.isEmpty) return {};

    // Recurse into the next level
    Set<String> result = {};
    for (var child in entry.children ?? {}) {
      result.addAll(findIdsAtLevel(child, level - 1));
    }
    return result;
  }

  /// Returns the `extra` payload values at the given tree [level] starting from
  /// [entry].
  ///
  /// The result contains values in traversal order, and each value is cast to
  /// [E]. If a node's `extra` is not assignable to [E], a runtime error may be
  /// thrown.
  static List<E> findExtrasAtLevel<E>(SelectorEntry entry, int level) {
    // If level == 0, the current node is the target.
    if (level == 0) return [entry.extra as E];

    // If there are no children, any level > 0 cannot be found.
    if (entry.children == null || entry.children!.isEmpty) return [];

    // Recurse into the next level
    List<E> result = [];
    for (var child in entry.children ?? {}) {
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
        final SelectorEntry entry = queue.removeFirst();
        currentLevelSet.add(entry);

        // Add all children to the queue; they will be processed as the next level
        if (!entry.hasChildren) continue;
        for (final child in entry.children!) {
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

  static SelectorEntries removeAnyEntries(Iterable<SelectorEntry> entries) {
    final SelectorEntries result =
        entries is Set<SelectorEntry> ? entries : entries.toSet();

    void removeAnyInChildren(SelectorEntry entry) {
      final children = entry.children;
      if (children == null || children.isEmpty) return;

      children
          .removeWhere((child) => child is SelectorChildEntry && child.isAny);

      for (final child in children) {
        removeAnyInChildren(child);
      }
    }

    result.removeWhere((entry) => entry is SelectorChildEntry && entry.isAny);
    for (final entry in result) {
      removeAnyInChildren(entry);
    }

    return result;
  }

  /// Creates a deep copy of selector entries.
  ///
  /// The returned set and all nested nodes are new instances, so in-place
  /// operations (e.g. [clippingTree]) won't mutate the original tree.
  ///
  /// If [skipAny] is true, nodes marked as "Any" are excluded from the cloned
  /// result.
  static SelectorEntries deepCloneEntries(
    Iterable<SelectorEntry> entries, {
    bool skipAny = false,
  }) {
    return entries
        .where((entry) =>
            !skipAny || !(entry is SelectorChildEntry && entry.isAny))
        .map((entry) => _cloneEntry(entry, skipAny: skipAny))
        .toSet();
  }

  static SelectorEntry _cloneEntry(
    SelectorEntry entry, {
    bool skipAny = false,
  }) {
    final clonedChildren = entry.children
        ?.where((child) =>
            !skipAny || !(child is SelectorChildEntry && child.isAny))
        .map((child) => _cloneEntry(child, skipAny: skipAny))
        .toSet();

    if (entry is SelectorCategoryEntry) {
      return SelectorCategoryEntry(
        selectionMode: entry.selectionMode,
        header: entry.header == null
            ? null
            : _cloneEntry(entry.header!, skipAny: skipAny),
        headerSelectionMode: entry.headerSelectionMode,
        footer: entry.footer == null
            ? null
            : _cloneEntry(entry.footer!, skipAny: skipAny),
        footerSelectionMode: entry.footerSelectionMode,
        id: entry.id,
        name: entry.name ?? '',
        children: clonedChildren,
        enabled: entry.enabled,
        immediate: entry.immediate,
      );
    }

    if (entry is SelectorRangeEntry) {
      return SelectorRangeEntry(
        min: entry.min,
        max: entry.max,
        inputLabel: entry.inputLabel,
        minHintText: entry.minHintText,
        maxHintText: entry.maxHintText,
        parentId: entry.parentId,
        id: entry.id,
        name: entry.name,
        children: clonedChildren,
        enabled: entry.enabled,
        immediate: entry.immediate,
        extra: entry.extra,
      );
    }

    if (entry is SelectorTextEntry) {
      return SelectorTextEntry(
        parentId: entry.parentId,
        id: entry.id,
        name: entry.name,
        children: clonedChildren,
        enabled: entry.enabled,
        immediate: entry.immediate,
      );
    }

    if (entry is SelectorChildEntry) {
      return SelectorChildEntry(
        parentId: entry.parentId,
        id: entry.id,
        name: entry.name,
        children: clonedChildren,
        enabled: entry.enabled,
        immediate: entry.immediate,
        extra: entry.extra,
      );
    }

    throw UnsupportedError(
      'Unsupported SelectorEntry type: ${entry.runtimeType}',
    );
  }

  static SelectorEntry _cloneEntryWithChildren(
    SelectorEntry entry,
    Set<SelectorEntry>? children, {
    SelectorEntry? header,
    SelectorEntry? footer,
  }) {
    if (entry is SelectorCategoryEntry) {
      return SelectorCategoryEntry(
        selectionMode: entry.selectionMode,
        header: header,
        headerSelectionMode: entry.headerSelectionMode,
        footer: footer,
        footerSelectionMode: entry.footerSelectionMode,
        id: entry.id,
        name: entry.name ?? '',
        children: children,
        enabled: entry.enabled,
        immediate: entry.immediate,
      );
    }

    if (entry is SelectorRangeEntry) {
      return SelectorRangeEntry(
        min: entry.min,
        max: entry.max,
        inputLabel: entry.inputLabel,
        minHintText: entry.minHintText,
        maxHintText: entry.maxHintText,
        parentId: entry.parentId,
        id: entry.id,
        name: entry.name,
        children: children,
        enabled: entry.enabled,
        immediate: entry.immediate,
        extra: entry.extra,
      );
    }

    if (entry is SelectorTextEntry) {
      return SelectorTextEntry(
        parentId: entry.parentId,
        id: entry.id,
        name: entry.name,
        children: children,
        enabled: entry.enabled,
        immediate: entry.immediate,
      );
    }

    if (entry is SelectorChildEntry) {
      return SelectorChildEntry(
        parentId: entry.parentId,
        id: entry.id,
        name: entry.name,
        children: children,
        enabled: entry.enabled,
        immediate: entry.immediate,
        extra: entry.extra,
      );
    }

    throw UnsupportedError(
      'Unsupported SelectorEntry type: ${entry.runtimeType}',
    );
  }

  static SelectorEntry _cloneEntryWithoutChildren(SelectorEntry entry) {
    return _cloneEntryWithChildren(entry, null);
  }

  static SelectorEntry _cloneHeaderFooterEntry(
    SelectorEntry entry,
    SelectorEntries? selectedChildren, {
    required bool deepCloneSelectedSubtree,
  }) {
    final originalChildren =
        entry.children?.toList() ?? const <SelectorEntry>[];
    final selectedIds =
        selectedChildren?.map((e) => e.id).toSet() ?? const <String>{};

    Set<SelectorEntry>? clonedChildren;
    if (entry.children != null) {
      if (selectedIds.isEmpty) {
        clonedChildren = <SelectorEntry>{};
      } else {
        final selectedOrdered =
            originalChildren.where((child) => selectedIds.contains(child.id));
        clonedChildren = deepCloneSelectedSubtree
            ? deepCloneEntries(selectedOrdered)
            : selectedOrdered.map(_cloneEntryWithoutChildren).toSet();
      }
    }

    return _cloneEntryWithChildren(entry, clonedChildren);
  }

  /// Removes unselected nodes from [entries] by clipping the tree in-place.
  ///
  /// [selectedItemsPerLevel] represents selected entries per depth level. Nodes
  /// not present at the current [level] are removed, and the process continues
  /// recursively for remaining nodes.
  static void clippingTree(
    SelectorEntries? entries,
    List<SelectorEntries> selectedItemsPerLevel,
    int level, [
    Map<String, SelectorEntries>? selectedHeaderEntries,
    Map<String, SelectorEntries>? selectedFooterEntries,
  ]) {
    if (entries == null || entries.isEmpty || selectedItemsPerLevel.isEmpty) {
      return;
    }
    SelectorEntries? selectedItems =
        selectedItemsPerLevel.elementAtOrNull(level);
    if (selectedItems == null || selectedItems.isEmpty) {
      return;
    }
    entries.removeWhere((e) => !selectedItems.contains(e));

    if (selectedHeaderEntries != null || selectedFooterEntries != null) {
      for (final entry in entries) {
        if (entry is! SelectorCategoryEntry) continue;
        final category = entry;

        if (selectedHeaderEntries != null) {
          final headerSelected = selectedHeaderEntries[category.id] ?? {};
          final headerChildren = category.header?.children;
          if (headerChildren != null) {
            if (headerSelected.isEmpty) {
              headerChildren.clear();
            } else {
              headerChildren
                  .removeWhere((e) => !headerSelected.any((s) => s.id == e.id));
            }
          }
        }

        if (selectedFooterEntries != null) {
          final footerSelected = selectedFooterEntries[category.id] ?? {};
          final footerChildren = category.footer?.children;
          if (footerChildren != null) {
            if (footerSelected.isEmpty) {
              footerChildren.clear();
            } else {
              footerChildren
                  .removeWhere((e) => !footerSelected.any((s) => s.id == e.id));
            }
          }
        }
      }
    }

    if (level + 1 >= selectedItemsPerLevel.length) return;
    for (var item in entries) {
      clippingTree(
        item.children,
        selectedItemsPerLevel,
        level + 1,
        selectedHeaderEntries,
        selectedFooterEntries,
      );
    }
  }

  static SelectorEntries cloneTree(
    Iterable<SelectorEntry> entries,
    List<SelectorEntries> selectedItemsPerLevel, {
    bool deepCloneSelectedSubtree = true,
    Map<String, SelectorEntries>? selectedHeaderEntries,
    Map<String, SelectorEntries>? selectedFooterEntries,
  }) {
    SelectorEntry cloneEntryAtLevel(SelectorEntry entry, int level) {
      Set<SelectorEntry>? clonedChildren;
      final children = entry.children;

      if (children != null && children.isNotEmpty) {
        final nextLevel = level + 1;
        final hasNextLevelSelection = nextLevel < selectedItemsPerLevel.length;

        if (!hasNextLevelSelection) {
          clonedChildren =
              deepCloneSelectedSubtree ? deepCloneEntries(children) : null;
        } else {
          final selectedNext = selectedItemsPerLevel[nextLevel];
          if (selectedNext.isEmpty) {
            clonedChildren =
                deepCloneSelectedSubtree ? deepCloneEntries(children) : null;
          } else {
            final ordered = children.toList();
            final selectedOrdered =
                ordered.where((child) => selectedNext.contains(child));
            final copied = selectedOrdered
                .map((child) => cloneEntryAtLevel(child, nextLevel))
                .toSet();
            clonedChildren = copied.isEmpty ? null : copied;
          }
        }
      }

      if (entry is SelectorCategoryEntry) {
        final clonedHeader = entry.header == null
            ? null
            : selectedHeaderEntries == null
                ? deepCloneEntries({entry.header!}).firstOrNull
                : _cloneHeaderFooterEntry(
                    entry.header!,
                    selectedHeaderEntries[entry.id],
                    deepCloneSelectedSubtree: deepCloneSelectedSubtree,
                  );
        final clonedFooter = entry.footer == null
            ? null
            : selectedFooterEntries == null
                ? deepCloneEntries({entry.footer!}).firstOrNull
                : _cloneHeaderFooterEntry(
                    entry.footer!,
                    selectedFooterEntries[entry.id],
                    deepCloneSelectedSubtree: deepCloneSelectedSubtree,
                  );
        return _cloneEntryWithChildren(
          entry,
          clonedChildren,
          header: clonedHeader,
          footer: clonedFooter,
        );
      }

      return _cloneEntryWithChildren(entry, clonedChildren);
    }

    final selectedRoot = selectedItemsPerLevel.elementAtOrNull(0) ?? {};
    if (selectedRoot.isEmpty) return {};

    final result = <SelectorEntry>{};
    for (final entry in entries) {
      if (!selectedRoot.contains(entry)) continue;
      result.add(cloneEntryAtLevel(entry, 0));
    }
    return result;
  }

  // 根据选中内容，计算出有效标签，最终返回一个结果标签。
  static String? getResultLabel(SelectorEntries? resultEntries) {
    if (resultEntries == null) return null;

    // 找到第一个有效标签后继续遍历；一旦找到第二个，立即返回“多选”。
    // 有效标签规则：
    // 从根节点到端节点，算作一条选择路径
    // 端节点的名称添加到 candidateLabels 中
    // 如果端节点 isAny=true，则取端节点的父节点的名称，如果父节点是根节点(类别节点)，则舍弃
    String? firstLabel;

    bool collectCandidateLabels(
      SelectorEntry entry, {
      SelectorEntry? parent,
    }) {
      final children = entry.children;
      final isLeaf = children == null || children.isEmpty;
      if (isLeaf) {
        String? label;
        if (entry is SelectorChildEntry && entry.isAny) {
          if (parent == null || parent is SelectorCategoryEntry) return false;
          label = parent.name;
        } else {
          label = entry.name;
        }

        if (label == null || label.isEmpty) return false;
        if (firstLabel == null) {
          firstLabel = label;
          return false;
        }
        return true;
      }

      for (final child in children) {
        if (collectCandidateLabels(child, parent: entry)) return true;
      }
      return false;
    }

    for (final entry in resultEntries) {
      if (collectCandidateLabels(entry)) return '多选';
    }
    return firstLabel;
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
          // If it's a custom entry, restore the previous input values.
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
