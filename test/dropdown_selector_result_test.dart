import 'package:criteria_selector/src/dropdown_selector_result.dart';
import 'package:criteria_selector/src/dropdown_tab_data.dart';
import 'package:criteria_selector/src/selector/constants.dart';
import 'package:criteria_selector/src/selector/selector_entry.dart';
import 'package:flutter_test/flutter_test.dart';

SelectorTextEntry<dynamic> _text(
  String parentId,
  String id, {
  String? name,
  Set<SelectorEntry<dynamic>>? children,
}) {
  return SelectorTextEntry<dynamic>(
    parentId: parentId,
    id: id,
    name: name ?? id,
    children: children,
  );
}

SelectorRangeEntry<int, dynamic> _range(String parentId, String id,
    {int? min, int? max}) {
  return SelectorRangeEntry<int, dynamic>(
    parentId: parentId,
    id: id,
    name: id,
    min: min,
    max: max,
  );
}

SelectorCategoryEntry<dynamic> _category(
  String id, {
  required Set<SelectorEntry<dynamic>> children,
}) {
  return SelectorCategoryEntry<dynamic>(
    id: id,
    name: id,
    children: children,
  );
}

DropdownSelectorResult _result(SelectorEntries selected) {
  return DropdownSelectorResult(
    tabData: DropdownTabData(index: 0, tag: 'tab', originalLabel: 'Tab'),
    selected: selected,
  );
}

/// Shared selection set used by both the `DropdownSelectorResult` and the bare
/// `SelectorEntries` query-helper groups, proving the two code paths
/// (dropdown-bar callback vs. `showSelector`/`showModalBottomSelector` return)
/// produce identical results.
final SelectorEntries _sharedSelected = {
  _category('text', children: {
    _text('text', 'a'),
    _text('text', 'b'),
  }),
  _category('range', children: {
    _range('range', 'r1', min: 10, max: 20),
    _range('range', 'r2', min: 30, max: 40),
  }),
  _category('region', children: {
    _text('region', 'd1', children: {
      _text('d1', 's1'),
      _text('d1', 's2'),
    }),
    _text('region', 'd2', children: {
      _text('d2', 's3'),
    }),
  }),
  _text('', 'sort_single'),
};

void main() {
  group('DropdownSelectorResult query helpers', () {
    final result = _result(_sharedSelected);

    test('findCategory returns matching category and null otherwise', () {
      expect(result.findCategory('text')?.id, 'text');
      expect(result.findCategory('missing'), isNull);
    });

    test('childIdsOf returns direct child ids', () {
      expect(result.childIdsOf('text'), ['a', 'b']);
      expect(result.childIdsOf('sort_single'), isEmpty);
      expect(result.childIdsOf('missing'), isEmpty);
    });

    test('childRangesOf returns range entries with min/max', () {
      final ranges = result.childRangesOf('range');
      expect(ranges.length, 2);
      expect(ranges[0].id, 'r1');
      expect(ranges[0].min, 10);
      expect(ranges[0].max, 20);
      expect(ranges[1].min, 30);
      expect(result.childRangesOf('text'), isEmpty);
      expect(result.childRangesOf('missing'), isEmpty);
    });

    test('cascadingPairsOf returns parent -> child id pairs', () {
      final pairs = {
        for (final p in result.cascadingPairsOf('region')) p.id: p.childIds,
      };
      expect(pairs.length, 2);
      expect(pairs['d1'], ['s1', 's2']);
      expect(pairs['d2'], ['s3']);
      expect(result.cascadingPairsOf('missing'), isEmpty);
    });

    test('firstSelectedId returns id of first selected entry', () {
      expect(result.firstSelectedId, 'text');
    });

    test('query helpers on empty selection return empty / null', () {
      final empty = _result(<SelectorEntry<dynamic>>{});
      expect(empty.findCategory('text'), isNull);
      expect(empty.childIdsOf('text'), isEmpty);
      expect(empty.childRangesOf('text'), isEmpty);
      expect(empty.cascadingPairsOf('text'), isEmpty);
      expect(empty.firstSelectedId, isNull);
    });
  });

  // Mirrors the group above but invokes the helpers directly on a bare
  // `SelectorEntries` — the type returned by `showSelector` /
  // `showModalBottomSelector` — to prove the dialog/bottom-sheet path can
  // query results without a `DropdownSelectorResult` wrapper.
  group('SelectorEntries query helpers (bare set, dialog/bottom-sheet path)',
      () {
    final entries = _sharedSelected;

    test('findCategory on bare set', () {
      expect(entries.findCategory('text')?.id, 'text');
      expect(entries.findCategory('missing'), isNull);
    });

    test('childIdsOf on bare set', () {
      expect(entries.childIdsOf('text'), ['a', 'b']);
      expect(entries.childIdsOf('sort_single'), isEmpty);
      expect(entries.childIdsOf('missing'), isEmpty);
    });

    test('childRangesOf on bare set', () {
      final ranges = entries.childRangesOf('range');
      expect(ranges.length, 2);
      expect(ranges[0].min, 10);
      expect(ranges[1].max, 40);
      expect(entries.childRangesOf('missing'), isEmpty);
    });

    test('cascadingPairsOf on bare set', () {
      final pairs = {
        for (final p in entries.cascadingPairsOf('region')) p.id: p.childIds,
      };
      expect(pairs['d1'], ['s1', 's2']);
      expect(pairs['d2'], ['s3']);
    });

    test('firstSelectedId on bare set', () {
      expect(entries.firstSelectedId, 'text');
    });

    test('bare empty set returns empty / null', () {
      final empty = <SelectorEntry<dynamic>>{};
      expect(empty.findCategory('text'), isNull);
      expect(empty.childIdsOf('text'), isEmpty);
      expect(empty.firstSelectedId, isNull);
    });
  });
}
