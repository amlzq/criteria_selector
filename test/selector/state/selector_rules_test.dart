import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter_test/flutter_test.dart';

SelectTextEntry<dynamic> _text(
  String parentId,
  String id,
  String name, {
  Set<SelectEntry<dynamic>>? children,
}) {
  return SelectTextEntry<dynamic>(
    parentId: parentId,
    id: id,
    name: name,
    children: children,
  );
}

SelectCategoryEntry<dynamic> _category(
  String id,
  String name, {
  required Set<SelectEntry<dynamic>> children,
  SelectEntry<dynamic>? header,
  SelectionMode headerSelectionMode = SelectionMode.single,
  SelectEntry<dynamic>? footer,
  SelectionMode footerSelectionMode = SelectionMode.single,
  SelectionMode selectionMode = SelectionMode.single,
}) {
  return SelectCategoryEntry<dynamic>(
    id: id,
    name: name,
    children: children,
    header: header,
    headerSelectionMode: headerSelectionMode,
    footer: footer,
    footerSelectionMode: footerSelectionMode,
    selectionMode: selectionMode,
  );
}

void main() {
  group('SelectController external control API', () {
    test('select/unselect leaf without any does not throw and clears selection',
        () {
      final a = _text('c', 'a', 'A');
      final b = _text('c', 'b', 'B');
      final c = _category('c', 'C', children: {a, b});

      final controller = SelectController(
        selectionMode: SelectionMode.single,
      );
      controller.bindState([c], initializeAnyIfEmpty: true);

      expect(controller.select('a', parentId: 'c'), isTrue);
      expect(controller.selectedEntriesAtLevel(0).contains(c), isTrue);
      expect(controller.selectedEntriesForParent('c', level: 1).contains(a),
          isTrue);

      expect(controller.unselect('a', parentId: 'c'), isTrue);
      expect(controller.selectedEntriesAtLevel(0), isEmpty);
      expect(controller.selectedEntriesAtLevel(1), isEmpty);
    });

    test('custom range replaces existing selection within same parent', () {
      final any = SelectTextEntry<dynamic>.any(parentId: 'c', name: 'Any');
      final custom = SelectRangeEntry<int, dynamic>.custom(
        parentId: 'c',
        name: 'Custom',
      );
      final a = _text('c', 'a', 'A');
      final c = _category('c', 'C', children: {any, custom, a});

      final controller = SelectController(
        selectionMode: SelectionMode.single,
      );
      controller.bindState([c], initializeAnyIfEmpty: true);

      expect(controller.selectedEntriesForParent('c', level: 1).contains(any),
          isTrue);

      expect(controller.select('a', parentId: 'c'), isTrue);
      expect(controller.selectedEntriesForParent('c', level: 1).contains(any),
          isFalse);
      expect(controller.selectedEntriesForParent('c', level: 1).contains(a),
          isTrue);

      // The view normalizes the input onto the entry and then selects it.
      custom.min = 10;
      custom.max = 20;
      expect(controller.select(custom.id, parentId: 'c'), isTrue);
      expect(controller.selectedEntriesForParent('c', level: 1).contains(a),
          isFalse);
      final selectedCustom = controller
          .selectedEntriesForParent('c', level: 1)
          .whereType<SelectRangeEntry>()
          .single;
      expect(selectedCustom.isCustom, isTrue);
      expect(selectedCustom.min, 10);
      expect(selectedCustom.max, 20);
    });

    test('cascading select selects full path', () {
      final leaf = _text('p', 'l', 'L');
      final parent = _text('c', 'p', 'P', children: {leaf});
      final c = _category('c', 'C', children: {parent});

      final controller = SelectController(
        selectionMode: SelectionMode.single,
      );
      controller.bindState([c], initializeAnyIfEmpty: false);

      expect(controller.select('l', parentId: 'p'), isTrue);
      expect(controller.selectedEntriesAtLevel(0).contains(c), isTrue);
      expect(controller.selectedEntriesAtLevel(1).contains(parent), isTrue);
      expect(controller.selectedEntriesAtLevel(2).contains(leaf), isTrue);
    });

    test('selectHeaderChild respects single selection', () {
      final h1 = _text('header', 'h1', 'H1');
      final h2 = _text('header', 'h2', 'H2');
      final header = _text('c', 'header', 'Header', children: {h1, h2});
      final c = _category(
        'c',
        'C',
        children: {_text('c', 'a', 'A')},
        header: header,
        headerSelectionMode: SelectionMode.single,
      );

      final controller = SelectController(
        selectionMode: SelectionMode.single,
      );
      controller.bindState([c], initializeAnyIfEmpty: false);

      expect(controller.selectHeaderChild('c', 'h2'), isTrue);
      expect(controller.selectedHeaderEntriesFor('c').map((e) => e.id).toSet(),
          {'h2'});

      expect(controller.selectHeaderChild('c', 'h1'), isTrue);
      expect(controller.selectedHeaderEntriesFor('c').map((e) => e.id).toSet(),
          {'h1'});
    });

    test('unselectHeaderChild clears selected header child', () {
      final h1 = _text('header', 'h1', 'H1');
      final header = _text('c', 'header', 'Header', children: {h1});
      final c = _category(
        'c',
        'C',
        children: {_text('c', 'a', 'A')},
        header: header,
        headerSelectionMode: SelectionMode.single,
      );

      final controller = SelectController(
        selectionMode: SelectionMode.single,
      );
      controller.bindState([c], initializeAnyIfEmpty: false);

      expect(controller.selectHeaderChild('c', 'h1'), isTrue);
      expect(controller.selectedHeaderEntriesFor('c').map((e) => e.id).toSet(),
          {'h1'});

      expect(controller.unselectHeaderChild('c', 'h1'), isTrue);
      expect(controller.selectedHeaderEntriesFor('c'), isEmpty);
    });

    test('selectHeaderChild respects multiple selection', () {
      final h1 = _text('header', 'h1', 'H1');
      final h2 = _text('header', 'h2', 'H2');
      final header = _text('c', 'header', 'Header', children: {h1, h2});
      final c = _category(
        'c',
        'C',
        children: {_text('c', 'a', 'A')},
        header: header,
        headerSelectionMode: SelectionMode.multiple,
      );

      final controller = SelectController(
        selectionMode: SelectionMode.single,
      );
      controller.bindState([c], initializeAnyIfEmpty: false);

      expect(controller.selectHeaderChild('c', 'h1'), isTrue);
      expect(controller.selectHeaderChild('c', 'h2'), isTrue);
      expect(controller.selectedHeaderEntriesFor('c').map((e) => e.id).toSet(),
          {'h1', 'h2'});
    });

    test('select/unselect footer child works', () {
      final f1 = _text('footer', 'f1', 'F1');
      final footer = _text('c', 'footer', 'Footer', children: {f1});
      final c = _category(
        'c',
        'C',
        children: {_text('c', 'a', 'A')},
        footer: footer,
        footerSelectionMode: SelectionMode.single,
      );

      final controller = SelectController(
        selectionMode: SelectionMode.single,
      );
      controller.bindState([c], initializeAnyIfEmpty: false);

      expect(controller.selectFooterChild('c', 'f1'), isTrue);
      expect(controller.selectedFooterEntriesFor('c').map((e) => e.id).toSet(),
          {'f1'});

      expect(controller.unselectFooterChild('c', 'f1'), isTrue);
      expect(controller.selectedFooterEntriesFor('c'), isEmpty);
    });
  });
}
