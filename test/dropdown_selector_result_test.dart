import 'package:criteria_selector/src/selector/select_entry.dart';
import 'package:flutter_test/flutter_test.dart';

SelectTextEntry<dynamic> _text(
  String parentId,
  String id, {
  String? name,
  Set<SelectEntry<dynamic>>? children,
}) {
  return SelectTextEntry<dynamic>(
    parentId: parentId,
    id: id,
    name: name ?? id,
    children: children,
  );
}

SelectRangeEntry<int, dynamic> _range(String parentId, String id,
    {int? min, int? max}) {
  return SelectRangeEntry<int, dynamic>(
    parentId: parentId,
    id: id,
    name: id,
    min: min,
    max: max,
  );
}

SelectCategoryEntry<dynamic> _category(
  String id, {
  required Set<SelectEntry<dynamic>> children,
}) {
  return SelectCategoryEntry<dynamic>(
    id: id,
    name: id,
    children: children,
  );
}

/// Shared selection set used to verify that the bare `SelectEntries` query
/// helpers (e.g. for `showSelect` / `showModalBottomSelect` return values)
/// work correctly.
final SelectEntries _sharedSelected = {
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
  // Query helpers on a bare `SelectEntries` — the type returned by
  // `showSelect` / `showModalBottomSelect` — to prove the
  // dialog/bottom-sheet path can query results without a wrapper.
  group('SelectEntries query helpers (bare set, dialog/bottom-sheet path)',
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
      final empty = <SelectEntry<dynamic>>{};
      expect(empty.findCategory('text'), isNull);
      expect(empty.childIdsOf('text'), isEmpty);
      expect(empty.firstSelectedId, isNull);
    });
  });
}
