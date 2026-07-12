import 'package:collection/collection.dart';

import '../constants.dart';
import '../selector_entry.dart';
import '../selector_utils.dart';
import 'selector_state_snapshot.dart';

class SelectorStateTree {
  final ListEquality<SelectorEntry> _entryListEquality = const ListEquality();
  final SetEquality<SelectorEntry> _entrySetEquality = const SetEquality();

  List<SelectorEntry> _entries = const [];
  final Map<String, List<SelectorEntry>> _idIndex = {};
  SelectorEntries? _previousSelected;
  SelectorEntries? _resetSelected;

  final List<SelectorEntries> _selectedEntriesPerLevel = [];
  final Map<String, SelectorEntries> _selectedHeaderEntries = {};
  final Map<String, SelectorEntries> _selectedFooterEntries = {};

  List<SelectorEntry> get entries => _entries;

  SelectorEntries? get previousSelected => _previousSelected;

  SelectorEntries? get resetSelected => _resetSelected;

  int get levelCount => _selectedEntriesPerLevel.length;

  SelectorStateSnapshot get snapshot => SelectorStateSnapshot(
        selectedEntriesPerLevel:
            _selectedEntriesPerLevel.map((e) => {...e}).toList(),
        selectedHeaderEntries:
            _selectedHeaderEntries.map((k, v) => MapEntry(k, {...v})),
        selectedFooterEntries:
            _selectedFooterEntries.map((k, v) => MapEntry(k, {...v})),
      );

  bool bind(
    List<SelectorEntry> entries, {
    SelectorEntries? previousSelected,
    SelectorEntries? resetSelected,
    required bool initializeAnyIfEmpty,
  }) {
    final isSameEntries = _entryListEquality.equals(_entries, entries);
    final isSamePrevious = _entrySetEquality.equals(
        _previousSelected ?? {}, previousSelected ?? {});
    final isSameReset =
        _entrySetEquality.equals(_resetSelected ?? {}, resetSelected ?? {});
    if (isSameEntries && isSamePrevious && isSameReset) {
      return false;
    }

    _entries = entries;
    _rebuildIdIndex();
    _previousSelected = previousSelected;
    _resetSelected = resetSelected;
    _restoreSelections(previousSelected,
        initializeAnyIfEmpty: initializeAnyIfEmpty);
    return true;
  }

  void reset({required bool initializeAnyIfEmpty}) {
    _restoreSelections(_resetSelected,
        initializeAnyIfEmpty: initializeAnyIfEmpty);
  }

  SelectorEntries selectedEntriesAtLevel(int level) {
    return _selectedEntriesPerLevel.elementAtOrNull(level) ?? {};
  }

  SelectorEntries selectedEntriesForParent(String parentId,
      {required int level}) {
    return selectedEntriesAtLevel(level)
        .whereType<SelectorChildEntry>()
        .where((entry) => entry.parentId == parentId)
        .toSet();
  }

  SelectorEntries selectedHeaderEntriesFor(String categoryId) {
    return _selectedHeaderEntries[categoryId] ?? {};
  }

  SelectorEntries selectedFooterEntriesFor(String categoryId) {
    return _selectedFooterEntries[categoryId] ?? {};
  }

  void ensureLevels(int count) {
    while (_selectedEntriesPerLevel.length < count) {
      _selectedEntriesPerLevel.add({});
    }
  }

  void trimLevels(int count) {
    while (_selectedEntriesPerLevel.length > count) {
      _selectedEntriesPerLevel.removeLast();
    }
  }

  void trimTrailingEmptyLevels() {
    while (_selectedEntriesPerLevel.isNotEmpty &&
        _selectedEntriesPerLevel.last.isEmpty) {
      _selectedEntriesPerLevel.removeLast();
    }
  }

  void clearSelections() {
    _selectedEntriesPerLevel.clear();
    _selectedHeaderEntries.clear();
    _selectedFooterEntries.clear();
  }

  SelectorEntries mutableSelectedEntriesAtLevel(int level) {
    ensureLevels(level + 1);
    return _selectedEntriesPerLevel[level];
  }

  SelectorEntries mutableHeaderEntriesFor(String categoryId) {
    return _selectedHeaderEntries.putIfAbsent(
        categoryId, () => <SelectorEntry>{});
  }

  SelectorEntries mutableFooterEntriesFor(String categoryId) {
    return _selectedFooterEntries.putIfAbsent(
        categoryId, () => <SelectorEntry>{});
  }

  SelectorEntries buildChangedEntries() {
    return SelectorUtils.cloneTree(
      _entries,
      _selectedEntriesPerLevel,
      deepCloneSelectedSubtree: false,
      selectedHeaderEntries: _selectedHeaderEntries,
      selectedFooterEntries: _selectedFooterEntries,
    );
  }

  SelectorEntries buildAppliedEntries() {
    return SelectorUtils.cloneTree(
      _entries,
      _selectedEntriesPerLevel,
      selectedHeaderEntries: _selectedHeaderEntries,
      selectedFooterEntries: _selectedFooterEntries,
    );
  }

  SelectorEntry? findEntry(String id, {String? parentId}) {
    final candidates = _idIndex[id];
    if (candidates == null || candidates.isEmpty) return null;
    if (parentId == null) return candidates.first;
    for (final entry in candidates) {
      if (entry is SelectorChildEntry && entry.parentId == parentId) {
        return entry;
      }
    }
    return null;
  }

  SelectorCategoryEntry? findCategory(String categoryId) {
    final entry = findEntry(categoryId);
    if (entry is SelectorCategoryEntry) return entry;
    return null;
  }

  List<SelectorEntry>? findPath(String id, {String? parentId}) {
    if (_entries.isEmpty) return null;

    List<SelectorEntry>? result;

    bool visit(SelectorEntry entry, List<SelectorEntry> stack) {
      final nextStack = [...stack, entry];
      if (entry.id == id) {
        if (parentId == null) {
          result = nextStack;
          return true;
        }
        if (entry is SelectorChildEntry && entry.parentId == parentId) {
          result = nextStack;
          return true;
        }
      }

      if (entry is SelectorCategoryEntry) {
        final header = entry.header;
        if (header != null && visit(header, nextStack)) return true;
        final footer = entry.footer;
        if (footer != null && visit(footer, nextStack)) return true;
      }

      final children = entry.children;
      if (children != null) {
        for (final child in children) {
          if (visit(child, nextStack)) return true;
        }
      }
      return false;
    }

    for (final root in _entries) {
      if (visit(root, const [])) break;
    }
    return result;
  }

  void _restoreSelections(
    SelectorEntries? selected, {
    required bool initializeAnyIfEmpty,
  }) {
    clearSelections();
    if (selected?.isNotEmpty == true) {
      _selectedEntriesPerLevel.addAll(
        SelectorUtils.restorePreviousSelected(_entries, selected),
      );
      _restoreHeaderFooterSelected(_entries, selected!);
      return;
    }

    if (!initializeAnyIfEmpty) {
      return;
    }

    _initializeAnySelection();
  }

  void _rebuildIdIndex() {
    _idIndex.clear();
    void add(SelectorEntry entry) {
      _idIndex.putIfAbsent(entry.id, () => []).add(entry);
      if (entry is SelectorCategoryEntry) {
        final header = entry.header;
        if (header != null) add(header);
        final footer = entry.footer;
        if (footer != null) add(footer);
      }
      final children = entry.children;
      if (children != null) {
        for (final child in children) {
          add(child);
        }
      }
    }

    for (final entry in _entries) {
      add(entry);
    }
  }

  void _initializeAnySelection() {
    if (_entries.isEmpty) return;

    if (_entries.first is SelectorCategoryEntry) {
      ensureLevels(2);
      for (final category in _entries.whereType<SelectorCategoryEntry>()) {
        final anyItem = category.children?.singleWhereOrNull(testAnyElement);
        if (anyItem == null) continue;
        _selectedEntriesPerLevel[0].add(category);
        _selectedEntriesPerLevel[1].add(anyItem);
      }
      return;
    }

    ensureLevels(1);
    final anyItem = _entries.singleWhereOrNull(testAnyElement);
    if (anyItem != null) {
      _selectedEntriesPerLevel[0].add(anyItem);
    }
  }

  void _restoreHeaderFooterSelected(
    List<SelectorEntry> entries,
    Set<SelectorEntry> selected,
  ) {
    final categories = entries.whereType<SelectorCategoryEntry>().toList();
    for (final selectedEntry in selected) {
      if (selectedEntry is! SelectorCategoryEntry) continue;
      final category =
          categories.singleWhereOrNull((e) => e.id == selectedEntry.id);
      if (category == null) continue;

      final selectedHeaderChildren = selectedEntry.header?.children ?? {};
      if (selectedHeaderChildren.isNotEmpty) {
        final restoredHeader = mutableHeaderEntriesFor(category.id);
        restoredHeader.clear();
        for (final selectedChild in selectedHeaderChildren) {
          final match = category.header?.children
              ?.singleWhereOrNull((e) => e.id == selectedChild.id);
          if (match != null) restoredHeader.add(match);
        }
      }

      final selectedFooterChildren = selectedEntry.footer?.children ?? {};
      if (selectedFooterChildren.isNotEmpty) {
        final restoredFooter = mutableFooterEntriesFor(category.id);
        restoredFooter.clear();
        for (final selectedChild in selectedFooterChildren) {
          final match = category.footer?.children
              ?.singleWhereOrNull((e) => e.id == selectedChild.id);
          if (match != null) restoredFooter.add(match);
        }
      }
    }
  }
}
