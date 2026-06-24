import 'package:collection/collection.dart';

import '../../constants.dart';
import '../../selector_entry.dart';
import 'selector_state_tree.dart';

class SelectorSelectionRules {
  const SelectorSelectionRules();

  void focusCategory(
    SelectorStateTree tree,
    SelectorCategoryEntry category, {
    required SelectionMode selectionMode,
  }) {
    if (SelectionMode.single == selectionMode) {
      tree.clearSelections();
    }

    tree.ensureLevels(2);
    final rootSelected = tree.mutableSelectedEntriesAtLevel(0);
    if (!rootSelected.contains(category)) {
      rootSelected.add(category);
    }

    final selectedChildren = tree.mutableSelectedEntriesAtLevel(1);
    final hasChildOfCategory = selectedChildren.any(
      (e) => e is SelectorChildEntry && e.parentId == category.id,
    );
    if (hasChildOfCategory) {
      return;
    }

    final anyItem = category.children?.singleWhereOrNull(testAnyElement);
    if (anyItem != null) {
      selectedChildren.removeWhere(
        (e) => e is SelectorChildEntry && e.parentId == category.id,
      );
      selectedChildren.add(anyItem);
    }
  }

  void toggleFlatLeaf(
    SelectorStateTree tree,
    SelectorChildEntry item, {
    required SelectionMode selectorSelectionMode,
    required bool isCategoryTree,
    SelectorCategoryEntry? category,
  }) {
    if (!isCategoryTree) {
      tree.ensureLevels(1);
      final selectedEntries = tree.mutableSelectedEntriesAtLevel(0);

      if (item.isAny) {
        selectedEntries
          ..clear()
          ..add(item);
        return;
      }

      selectedEntries.removeWhere((e) => e is SelectorChildEntry && e.isAny);
      if (SelectionMode.single == selectorSelectionMode) {
        if (selectedEntries.contains(item)) return;
        selectedEntries
          ..clear()
          ..add(item);
      } else {
        if (selectedEntries.contains(item)) {
          selectedEntries.remove(item);
        } else {
          selectedEntries.add(item);
        }
      }
      return;
    }

    if (category == null) return;
    tree.ensureLevels(2);
    final selectedEntries = tree.mutableSelectedEntriesAtLevel(1);

    if (item.isAny) {
      selectedEntries
          .removeWhere((e) => testSameParentElement(e, item.parentId));
      selectedEntries.add(item);
    } else if (item is SelectorRangeEntry && item.isCustom) {
      selectedEntries
          .removeWhere((e) => testSameParentElement(e, item.parentId));
      selectedEntries.add(item);
    } else {
      selectedEntries.removeWhere(
        (e) =>
            e is SelectorChildEntry && e.parentId == item.parentId && e.isAny,
      );

      if (SelectionMode.single == category.selectionMode) {
        if (selectedEntries.contains(item)) return;
        selectedEntries
            .removeWhere((e) => testSameParentElement(e, item.parentId));
        selectedEntries.add(item);
      } else {
        if (selectedEntries.contains(item)) {
          selectedEntries.remove(item);
        } else {
          selectedEntries.add(item);
        }
      }
    }

    final rootSelected = tree.mutableSelectedEntriesAtLevel(0);
    final hasSelectionInCategory =
        selectedEntries.any((e) => testSameParentElement(e, category.id));
    if (hasSelectionInCategory) {
      rootSelected.add(category);
    } else {
      final anyItem = category.children?.singleWhereOrNull(testAnyElement);
      if (anyItem != null) {
        selectedEntries.add(anyItem);
        rootSelected.add(category);
      } else {
        rootSelected.remove(category);
      }
    }
  }

  void toggleCascadingLeaf(
    SelectorStateTree tree,
    SelectorChildEntry entry, {
    required SelectionMode selectorSelectionMode,
    required SelectionMode childrenSelectionMode,
    required List<SelectorEntry> focusedPath,
    required SelectorCategoryEntry category,
  }) {
    final level = focusedPath.length;
    while (level - tree.levelCount >= 0) {
      tree.ensureLevels(tree.levelCount + 1);
    }

    final selectedEntries = tree.mutableSelectedEntriesAtLevel(level);
    if (entry.isAny) {
      if (SelectionMode.single == childrenSelectionMode) {
        if (!selectedEntries.contains(entry)) {
          selectedEntries
            ..clear()
            ..add(entry);
        }
      } else {
        if (selectedEntries.contains(entry)) {
          selectedEntries.remove(entry);
        } else {
          selectedEntries.removeWhere(
              (e) => (e as SelectorTextEntry).parentId == entry.parentId);
          selectedEntries.add(entry);
        }
      }
    } else {
      tree.mutableSelectedEntriesAtLevel(1).removeWhere((e) =>
          e is SelectorChildEntry && e.parentId == entry.parentId && e.isAny);
      selectedEntries.removeWhere((e) =>
          e is SelectorChildEntry && e.parentId == entry.parentId && e.isAny);

      if (SelectionMode.single == childrenSelectionMode) {
        if (!selectedEntries.contains(entry)) {
          selectedEntries
            ..clear()
            ..add(entry);
        }
      } else {
        if (selectedEntries.contains(entry)) {
          selectedEntries.remove(entry);
        } else {
          selectedEntries.add(entry);
        }
      }
    }

    if (selectedEntries.contains(entry)) {
      for (var i = level - 1; i >= 0; i--) {
        tree.mutableSelectedEntriesAtLevel(i).add(focusedPath[i]);
      }
      return;
    }

    for (var i = level - 1; i >= 0; i--) {
      final parent = focusedPath[i];
      final sameParentSelected = tree
          .mutableSelectedEntriesAtLevel(i + 1)
          .where((e) =>
              e is SelectorChildEntry &&
              (e as SelectorChildEntry).parentId == parent.id);
      if (sameParentSelected.isEmpty) {
        tree.mutableSelectedEntriesAtLevel(i).remove(parent);
      }
    }

    if (tree.selectedEntriesAtLevel(1).isEmpty) {
      tree.mutableSelectedEntriesAtLevel(0).add(category);
      final anyItem = category.children?.singleWhereOrNull(testAnyElement);
      if (anyItem != null) {
        tree.mutableSelectedEntriesAtLevel(1).add(anyItem);
      }
    }

    tree.trimTrailingEmptyLevels();
  }

  void toggleHeaderOrFooter(
    SelectorStateTree tree, {
    required String categoryId,
    required SelectorChildEntry entry,
    required SelectionMode selectionMode,
    required bool isHeader,
  }) {
    final selectedEntries = isHeader
        ? tree.mutableHeaderEntriesFor(categoryId)
        : tree.mutableFooterEntriesFor(categoryId);
    final contains = selectedEntries.any((e) => e.id == entry.id);
    if (SelectionMode.single == selectionMode) {
      if (contains) {
        selectedEntries.removeWhere((e) => e.id == entry.id);
      } else {
        selectedEntries
          ..clear()
          ..add(entry);
      }
      return;
    }

    if (contains) {
      selectedEntries.removeWhere((e) => e.id == entry.id);
    } else {
      selectedEntries.add(entry);
    }
  }
}
