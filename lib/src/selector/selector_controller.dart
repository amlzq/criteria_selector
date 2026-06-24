import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector.dart';
import '../selector_entry.dart';
import 'state/selector_selection_rules.dart';
import 'state/selector_state_snapshot.dart';
import 'state/selector_state_tree.dart';

/// Controller for a single [Selector] instance.
///
/// This controller exposes the selector configuration and forwards user actions
/// (change/apply/reset) to the callbacks provided by the owner widget.
class SelectorController extends ChangeNotifier {
  final Selector selector;

  final SelectorCallback? changeCallback;

  final SelectorCallback? applyCallback;

  final VoidCallback? resetCallback;

  final SelectorStateTree stateTree = SelectorStateTree();
  final SelectorSelectionRules _selectionRules = const SelectorSelectionRules();
  bool _isDisposed = false;

  SelectorController({
    required this.selector,
    this.changeCallback,
    this.applyCallback,
    this.resetCallback,
  });

  /// Selector selection mode; controls how category (level-1) entries are selected
  SelectionMode get selectionMode => selector.selectionMode;

  /// Previous selection
  SelectorEntries? get previousSelected => selector.selectedData;

  /// Reset selection
  SelectorEntries? get resetSelected => selector.resetData;

  bool get isDisposed => _isDisposed;

  SelectorStateSnapshot get snapshot => stateTree.snapshot;

  void _notifyListenersIfAlive() {
    if (_isDisposed) return;
    notifyListeners();
  }

  void bindState(
    List<SelectorEntry> entries, {
    required bool initializeAnyIfEmpty,
    SelectorEntries? previousSelectedOverride,
    SelectorEntries? resetSelectedOverride,
  }) {
    final changed = stateTree.bind(
      entries,
      previousSelected: previousSelectedOverride ?? previousSelected,
      resetSelected: resetSelectedOverride ?? resetSelected,
      initializeAnyIfEmpty: initializeAnyIfEmpty,
    );
    if (changed) {
      _notifyListenersIfAlive();
    }
  }

  SelectorEntries selectedEntriesAtLevel(int level) =>
      stateTree.selectedEntriesAtLevel(level);

  SelectorEntries selectedEntriesForParent(String parentId,
          {required int level}) =>
      stateTree.selectedEntriesForParent(parentId, level: level);

  SelectorEntries selectedHeaderEntriesFor(String categoryId) =>
      stateTree.selectedHeaderEntriesFor(categoryId);

  SelectorEntries selectedFooterEntriesFor(String categoryId) =>
      stateTree.selectedFooterEntriesFor(categoryId);

  void focusCategoryEntry(
    SelectorCategoryEntry category, {
    required SelectionMode selectionMode,
  }) {
    _selectionRules.focusCategory(
      stateTree,
      category,
      selectionMode: selectionMode,
    );
    _notifyListenersIfAlive();
  }

  void toggleFlatEntry(
    SelectorChildEntry entry, {
    required SelectionMode selectorSelectionMode,
    required bool isCategoryTree,
    SelectorCategoryEntry? category,
  }) {
    _selectionRules.toggleFlatLeaf(
      stateTree,
      entry,
      selectorSelectionMode: selectorSelectionMode,
      isCategoryTree: isCategoryTree,
      category: category,
    );
    _notifyListenersIfAlive();
  }

  void toggleCascadingEntry(
    SelectorChildEntry entry, {
    required SelectionMode selectorSelectionMode,
    required SelectionMode childrenSelectionMode,
    required List<SelectorEntry> focusedPath,
    required SelectorCategoryEntry category,
  }) {
    _selectionRules.toggleCascadingLeaf(
      stateTree,
      entry,
      selectorSelectionMode: selectorSelectionMode,
      childrenSelectionMode: childrenSelectionMode,
      focusedPath: focusedPath,
      category: category,
    );
    _notifyListenersIfAlive();
  }

  void toggleHeaderOrFooterEntry({
    required String categoryId,
    required SelectorChildEntry entry,
    required SelectionMode selectionMode,
    required bool isHeader,
  }) {
    _selectionRules.toggleHeaderOrFooter(
      stateTree,
      categoryId: categoryId,
      entry: entry,
      selectionMode: selectionMode,
      isHeader: isHeader,
    );
    _notifyListenersIfAlive();
  }

  void emitChangeFromState() {
    change(stateTree.buildChangedEntries());
  }

  void applyFromState() {
    apply(stateTree.buildAppliedEntries());
  }

  void resetState({required bool initializeAnyIfEmpty}) {
    stateTree.reset(initializeAnyIfEmpty: initializeAnyIfEmpty);
    _notifyListenersIfAlive();
  }

  void trimSelectionLevels(int count) {
    stateTree.trimLevels(count);
    stateTree.trimTrailingEmptyLevels();
    _notifyListenersIfAlive();
  }

  SelectorEntry? findEntry(String id, {String? parentId}) {
    return stateTree.findEntry(id, parentId: parentId);
  }

  List<SelectorEntry>? findPath(String id, {String? parentId}) {
    return stateTree.findPath(id, parentId: parentId);
  }

  bool focusCategory(String categoryId) {
    final category = stateTree.findCategory(categoryId);
    if (category == null) return false;
    focusCategoryEntry(category, selectionMode: selectionMode);
    return true;
  }

  bool select(
    String id, {
    String? parentId,
    bool emitChange = true,
    bool applyIfImmediate = false,
  }) {
    final entry = stateTree.findEntry(id, parentId: parentId);
    if (entry == null) return false;

    if (entry is SelectorCategoryEntry) {
      focusCategoryEntry(entry, selectionMode: selectionMode);
      if (emitChange) emitChangeFromState();
      return true;
    }

    if (entry is! SelectorChildEntry) return false;

    final path = stateTree.findPath(id, parentId: parentId);
    final selectorMode = _effectiveSelectorSelectionMode();

    if (path == null || path.isEmpty) {
      if (stateTree.entries.isEmpty ||
          stateTree.entries.first is SelectorCategoryEntry) {
        return false;
      }

      final alreadySelected =
          stateTree.selectedEntriesAtLevel(0).contains(entry);
      if (!alreadySelected) {
        toggleFlatEntry(
          entry,
          selectorSelectionMode: selectorMode,
          isCategoryTree: false,
        );
      }
      if (applyIfImmediate &&
          (selectorMode == SelectionMode.single || entry.immediate)) {
        applyFromState();
      } else if (emitChange) {
        emitChangeFromState();
      }
      return true;
    }

    final root = path.first;
    if (root is! SelectorCategoryEntry) return false;

    if (path.length == 2) {
      final leaf = path.last;
      if (leaf is! SelectorChildEntry) return false;

      final alreadySelected =
          stateTree.selectedEntriesForParent(root.id, level: 1).contains(leaf);
      if (!alreadySelected) {
        toggleFlatEntry(
          leaf,
          selectorSelectionMode: selectorMode,
          isCategoryTree: true,
          category: root,
        );
      }

      if (applyIfImmediate &&
          (selectorMode == SelectionMode.single || leaf.immediate)) {
        applyFromState();
      } else if (emitChange) {
        emitChangeFromState();
      }
      return true;
    }

    final leaf = path.last;
    if (leaf is! SelectorChildEntry) return false;
    final focusedPath = path.sublist(0, path.length - 1);
    final level = focusedPath.length;
    final alreadySelected =
        stateTree.selectedEntriesAtLevel(level).contains(leaf);
    if (!alreadySelected) {
      toggleCascadingEntry(
        leaf,
        selectorSelectionMode: selectorMode,
        childrenSelectionMode: root.selectionMode,
        focusedPath: focusedPath,
        category: root,
      );
    }

    if (applyIfImmediate &&
        (selectorMode == SelectionMode.single || leaf.immediate)) {
      applyFromState();
    } else if (emitChange) {
      emitChangeFromState();
    }
    return true;
  }

  bool unselect(
    String id, {
    String? parentId,
    bool emitChange = true,
  }) {
    final entry = stateTree.findEntry(id, parentId: parentId);
    if (entry == null || entry is! SelectorChildEntry) return false;

    final selectorMode = _effectiveSelectorSelectionMode();
    final path = stateTree.findPath(id, parentId: parentId);

    if (path == null || path.isEmpty) {
      final selected0 = stateTree.mutableSelectedEntriesAtLevel(0);
      if (!selected0.contains(entry)) return true;
      if (selectorMode == SelectionMode.single) {
        final any = stateTree.entries.singleWhereOrNull(testAnyElement);
        selected0
          ..clear()
          ..addAll(any == null ? {} : {any});
      } else {
        selected0.remove(entry);
      }
      _notifyListenersIfAlive();
      if (emitChange) emitChangeFromState();
      return true;
    }

    final root = path.first;
    if (root is! SelectorCategoryEntry) return false;

    if (path.length == 2) {
      final leaf = path.last;
      if (leaf is! SelectorChildEntry) return false;
      final selectedChildren = stateTree.mutableSelectedEntriesAtLevel(1);
      if (!selectedChildren.contains(leaf)) return true;

      if (root.selectionMode == SelectionMode.single) {
        final any = root.children?.singleWhereOrNull(testAnyElement);
        selectedChildren.removeWhere(
            (e) => e is SelectorChildEntry && e.parentId == root.id);
        if (any != null) {
          selectedChildren.add(any);
          stateTree.mutableSelectedEntriesAtLevel(0).add(root);
        } else {
          stateTree.mutableSelectedEntriesAtLevel(0).remove(root);
        }
      } else {
        toggleFlatEntry(
          leaf,
          selectorSelectionMode: selectorMode,
          isCategoryTree: true,
          category: root,
        );
      }

      if (emitChange) emitChangeFromState();
      return true;
    }

    final leaf = path.last;
    if (leaf is! SelectorChildEntry) return false;
    final focusedPath = path.sublist(0, path.length - 1);
    final level = focusedPath.length;
    final selectedAtLevel = stateTree.mutableSelectedEntriesAtLevel(level);
    if (!selectedAtLevel.contains(leaf)) return true;

    if (root.selectionMode == SelectionMode.single) {
      final parent = focusedPath.last;
      final any = parent.children
          ?.whereType<SelectorChildEntry>()
          .singleWhereOrNull(testAnyElement);
      if (any != null && any != leaf) {
        select(any.id,
            parentId: (any as SelectorChildEntry).parentId,
            emitChange: emitChange);
        return true;
      }
      return false;
    }

    toggleCascadingEntry(
      leaf,
      selectorSelectionMode: selectorMode,
      childrenSelectionMode: root.selectionMode,
      focusedPath: focusedPath,
      category: root,
    );
    if (emitChange) emitChangeFromState();
    return true;
  }

  bool setCustomRangeForParent({
    required String parentId,
    Object? min,
    Object? max,
    bool emitChange = true,
    bool applyIfImmediate = false,
  }) {
    final entry = stateTree.findEntry(kCustomEntryId, parentId: parentId);
    if (entry is! SelectorRangeEntry) return false;
    entry.min = min;
    entry.max = max;
    if (min != null || max != null) {
      entry.name = '${min ?? ''}-${max ?? ''}';
      return select(
        kCustomEntryId,
        parentId: parentId,
        emitChange: emitChange,
        applyIfImmediate: applyIfImmediate,
      );
    }
    return unselect(kCustomEntryId, parentId: parentId, emitChange: emitChange);
  }

  SelectionMode _effectiveSelectorSelectionMode() {
    if (selectionMode == SelectionMode.multiple) return SelectionMode.multiple;
    for (final entry in stateTree.entries) {
      if (entry is SelectorCategoryEntry &&
          entry.selectionMode == SelectionMode.multiple) {
        return SelectionMode.multiple;
      }
    }
    return SelectionMode.single;
  }

  bool selectHeaderChild(
    String categoryId,
    String childId, {
    bool emitChange = true,
  }) {
    final category = stateTree.findCategory(categoryId);
    final header = category?.header;
    final child = header?.children?.singleWhereOrNull((e) => e.id == childId);
    if (child is! SelectorChildEntry) return false;
    if (stateTree
        .selectedHeaderEntriesFor(categoryId)
        .any((e) => e.id == childId)) {
      return true;
    }
    toggleHeaderOrFooterEntry(
      categoryId: categoryId,
      entry: child,
      selectionMode: category?.headerSelectionMode ?? SelectionMode.single,
      isHeader: true,
    );
    if (emitChange) emitChangeFromState();
    return true;
  }

  bool selectFooterChild(
    String categoryId,
    String childId, {
    bool emitChange = true,
  }) {
    final category = stateTree.findCategory(categoryId);
    final footer = category?.footer;
    final child = footer?.children?.singleWhereOrNull((e) => e.id == childId);
    if (child is! SelectorChildEntry) return false;
    if (stateTree
        .selectedFooterEntriesFor(categoryId)
        .any((e) => e.id == childId)) {
      return true;
    }
    toggleHeaderOrFooterEntry(
      categoryId: categoryId,
      entry: child,
      selectionMode: category?.footerSelectionMode ?? SelectionMode.single,
      isHeader: false,
    );
    if (emitChange) emitChangeFromState();
    return true;
  }

  bool unselectHeaderChild(
    String categoryId,
    String childId, {
    bool emitChange = true,
  }) {
    final selected = stateTree.mutableHeaderEntriesFor(categoryId);
    final hadSelected = selected.any((e) => e.id == childId);
    selected.removeWhere((e) => e.id == childId);
    if (hadSelected && emitChange) emitChangeFromState();
    return true;
  }

  bool unselectFooterChild(
    String categoryId,
    String childId, {
    bool emitChange = true,
  }) {
    final selected = stateTree.mutableFooterEntriesFor(categoryId);
    final hadSelected = selected.any((e) => e.id == childId);
    selected.removeWhere((e) => e.id == childId);
    if (hadSelected && emitChange) emitChangeFromState();
    return true;
  }

  /// Notifies listeners that the selection changed.
  void change(SelectorEntries selected) {
    changeCallback?.call(selected);
  }

  /// Notifies listeners that the selection was applied.
  void apply(SelectorEntries selected) {
    applyCallback?.call(selected);
  }

  /// Notifies listeners that reset was requested.
  void reset() {
    resetCallback?.call();
  }

  // void discard() {
  //   selecteSubdistricts?.clear();
  //   previousSubdistrict = null;
  //   selectedDistricts?.clear();
  //   previousDistrict = null;
  //   selectedCities?.clear();
  //   previousCity = null;
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  static SelectorController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedSelectorControllerScope>()
        ?.controller;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

class _InheritedSelectorControllerScope extends InheritedWidget {
  final SelectorController controller;

  const _InheritedSelectorControllerScope(
      {required super.child, required this.controller});

  @override
  bool updateShouldNotify(
      covariant _InheritedSelectorControllerScope oldWidget) {
    return oldWidget.controller != controller;
  }
}

class SelectorControllerProvider extends StatelessWidget {
  final SelectorController controller;
  final Widget child;

  /// Provides a [SelectorController] to descendants.
  const SelectorControllerProvider({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _InheritedSelectorControllerScope(
      controller: controller,
      child: child,
    );
  }
}
