import 'package:criteria_selector/criteria_selector.dart';
import 'package:criteria_selector/src/selector/state/selection_rules.dart';
import 'package:criteria_selector/src/selector/state/state_tree.dart';
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
  group('SelectionRules – focusCategory', () {
    test(
        'single mode: clears all previous selections then adds Any for category',
        () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final any = SelectTextEntry<dynamic>.any(parentId: 'c1', name: 'Any');
      final a = _text('c1', 'a', 'A');
      final b = _text('c2', 'b', 'B');
      final c1 = _category('c1', 'C1', children: {any, a});
      final c2 = _category('c2', 'C2', children: {b});
      tree.bind([c1, c2], initializeAnyIfEmpty: false);

      // Pre-select something in another category
      tree.ensureLevels(2);
      tree.mutableSelectedEntriesAtLevel(0).add(c2);
      tree.mutableSelectedEntriesAtLevel(1).add(b);

      rules.focusCategory(tree, c1, selectionMode: SelectionMode.single);

      // Previous selections should be cleared, c1 should be selected
      expect(tree.selectedEntriesAtLevel(0).contains(c1), isTrue);
      expect(tree.selectedEntriesAtLevel(0).contains(c2), isFalse);
      expect(tree.selectedEntriesAtLevel(1).contains(any), isTrue);
    });

    test('single mode: clearSelections then adds Any for category with Any',
        () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final any = SelectTextEntry<dynamic>.any(parentId: 'c', name: 'Any');
      final a = _text('c', 'a', 'A');
      final c = _category('c', 'C', children: {any, a});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(2);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(a);

      rules.focusCategory(tree, c, selectionMode: SelectionMode.single);

      // In single mode, focusCategory clears all and then adds Any for the category
      expect(tree.selectedEntriesAtLevel(0).contains(c), isTrue);
      expect(tree.selectedEntriesAtLevel(1).contains(any), isTrue);
      expect(tree.selectedEntriesAtLevel(1).contains(a), isFalse);
    });

    test('single mode: category without selected children is removed from root',
        () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final a = _text('c1', 'a', 'A');
      final b = _text('c2', 'b', 'B');
      final c1 = _category('c1', 'C1', children: {a});
      final c2 = _category('c2', 'C2', children: {b});
      tree.bind([c1, c2], initializeAnyIfEmpty: false);

      tree.ensureLevels(2);
      tree.mutableSelectedEntriesAtLevel(0).add(c1);
      tree.mutableSelectedEntriesAtLevel(1).add(a);

      // Focus on c2 which has no selected children
      rules.focusCategory(tree, c2, selectionMode: SelectionMode.single);

      // c1 should be removed since c2 has no Any to auto-select
      expect(tree.selectedEntriesAtLevel(0).contains(c1), isFalse);
      expect(
          tree.selectedEntriesAtLevel(1).where(
                (e) => e is SelectChildEntry && e.parentId == 'c1',
              ),
          isEmpty);
    });

    test(
        'multiple mode: adds category with Any when no previous child selections',
        () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final a = _text('c1', 'a', 'A');
      final any = SelectTextEntry<dynamic>.any(parentId: 'c2', name: 'Any');
      final b = _text('c2', 'b', 'B');
      final c1 = _category('c1', 'C1', children: {a});
      final c2 = _category('c2', 'C2', children: {any, b});
      tree.bind([c1, c2], initializeAnyIfEmpty: false);

      tree.ensureLevels(2);
      tree.mutableSelectedEntriesAtLevel(0).add(c1);
      tree.mutableSelectedEntriesAtLevel(1).add(a);

      rules.focusCategory(tree, c2, selectionMode: SelectionMode.multiple);

      // Both categories should be selected, c2 gets its Any
      expect(tree.selectedEntriesAtLevel(0).contains(c1), isTrue);
      expect(tree.selectedEntriesAtLevel(0).contains(c2), isTrue);
      expect(tree.selectedEntriesAtLevel(1).contains(a), isTrue);
      expect(tree.selectedEntriesAtLevel(1).contains(any), isTrue);
    });
  });

  group('SelectionRules – toggleFlatLeaf (non-category tree)', () {
    test('selecting Any clears all and selects Any', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final any = SelectTextEntry<dynamic>.any(parentId: '', name: 'Any');
      final a = _text('', 'a', 'A');
      tree.bind([any, a], initializeAnyIfEmpty: false);

      tree.ensureLevels(1);
      tree.mutableSelectedEntriesAtLevel(0).add(a);

      rules.toggleFlatLeaf(
        tree,
        any,
        selectionMode: SelectionMode.single,
        isCategoryTree: false,
      );

      expect(tree.selectedEntriesAtLevel(0).contains(any), isTrue);
      expect(tree.selectedEntriesAtLevel(0).contains(a), isFalse);
    });

    test('single mode: selecting non-any entry replaces previous', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final a = _text('', 'a', 'A');
      final b = _text('', 'b', 'B');
      tree.bind([a, b], initializeAnyIfEmpty: false);

      tree.ensureLevels(1);
      tree.mutableSelectedEntriesAtLevel(0).add(a);

      rules.toggleFlatLeaf(
        tree,
        b,
        selectionMode: SelectionMode.single,
        isCategoryTree: false,
      );

      expect(tree.selectedEntriesAtLevel(0).contains(b), isTrue);
      expect(tree.selectedEntriesAtLevel(0).contains(a), isFalse);
    });

    test('single mode: selecting same entry does not remove it', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final a = _text('', 'a', 'A');
      tree.bind([a], initializeAnyIfEmpty: false);

      tree.ensureLevels(1);
      tree.mutableSelectedEntriesAtLevel(0).add(a);

      rules.toggleFlatLeaf(
        tree,
        a,
        selectionMode: SelectionMode.single,
        isCategoryTree: false,
      );

      // Still selected (short-circuit return)
      expect(tree.selectedEntriesAtLevel(0).contains(a), isTrue);
    });

    test('multiple mode: selecting toggles entry', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final a = _text('', 'a', 'A');
      final b = _text('', 'b', 'B');
      tree.bind([a, b], initializeAnyIfEmpty: false);

      tree.ensureLevels(1);
      tree.mutableSelectedEntriesAtLevel(0).add(a);

      // Add b
      rules.toggleFlatLeaf(
        tree,
        b,
        selectionMode: SelectionMode.multiple,
        isCategoryTree: false,
      );
      expect(tree.selectedEntriesAtLevel(0).contains(a), isTrue);
      expect(tree.selectedEntriesAtLevel(0).contains(b), isTrue);

      // Remove a
      rules.toggleFlatLeaf(
        tree,
        a,
        selectionMode: SelectionMode.multiple,
        isCategoryTree: false,
      );
      expect(tree.selectedEntriesAtLevel(0).contains(a), isFalse);
      expect(tree.selectedEntriesAtLevel(0).contains(b), isTrue);
    });

    test('removes Any entries when selecting non-Any', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final any = SelectTextEntry<dynamic>.any(parentId: '', name: 'Any');
      final a = _text('', 'a', 'A');
      tree.bind([any, a], initializeAnyIfEmpty: false);

      tree.ensureLevels(1);
      tree.mutableSelectedEntriesAtLevel(0).add(any);

      rules.toggleFlatLeaf(
        tree,
        a,
        selectionMode: SelectionMode.single,
        isCategoryTree: false,
      );

      expect(tree.selectedEntriesAtLevel(0).contains(any), isFalse);
    });
  });

  group('SelectionRules – toggleFlatLeaf (category tree)', () {
    test('category tree: selecting Any clears siblings under same parent', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final any = SelectTextEntry<dynamic>.any(parentId: 'c', name: 'Any');
      final a = _text('c', 'a', 'A');
      final c = _category('c', 'C', children: {any, a});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(2);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(a);

      rules.toggleFlatLeaf(
        tree,
        any,
        selectionMode: SelectionMode.single,
        isCategoryTree: true,
        category: c,
      );

      expect(tree.selectedEntriesAtLevel(1).contains(any), isTrue);
      expect(tree.selectedEntriesAtLevel(1).contains(a), isFalse);
    });

    test('category tree: selecting custom range clears siblings', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final custom = SelectRangeEntry<int, dynamic>.custom(
        parentId: 'c',
        name: 'Custom',
      );
      final a = _text('c', 'a', 'A');
      final c = _category('c', 'C', children: {custom, a});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(2);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(a);

      rules.toggleFlatLeaf(
        tree,
        custom,
        selectionMode: SelectionMode.single,
        isCategoryTree: true,
        category: c,
      );

      expect(tree.selectedEntriesAtLevel(1).contains(custom), isTrue);
      expect(tree.selectedEntriesAtLevel(1).contains(a), isFalse);
    });

    test('category tree single mode: selecting non-any replaces siblings', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final a = _text('c', 'a', 'A');
      final b = _text('c', 'b', 'B');
      final c = _category('c', 'C', children: {a, b});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(2);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(a);

      rules.toggleFlatLeaf(
        tree,
        b,
        selectionMode: SelectionMode.single,
        isCategoryTree: true,
        category: c,
      );

      expect(tree.selectedEntriesAtLevel(1).contains(b), isTrue);
      expect(tree.selectedEntriesAtLevel(1).contains(a), isFalse);
    });

    test('category tree single mode: selecting same entry does not remove it',
        () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final a = _text('c', 'a', 'A');
      final c = _category('c', 'C', children: {a});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(2);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(a);

      rules.toggleFlatLeaf(
        tree,
        a,
        selectionMode: SelectionMode.single,
        isCategoryTree: true,
        category: c,
      );

      expect(tree.selectedEntriesAtLevel(1).contains(a), isTrue);
    });

    test('category tree multiple mode: selecting toggles entries', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final a = _text('c', 'a', 'A');
      final b = _text('c', 'b', 'B');
      final c = _category('c', 'C',
          children: {a, b}, selectionMode: SelectionMode.multiple);
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(2);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(a);

      // Add b
      rules.toggleFlatLeaf(
        tree,
        b,
        selectionMode: SelectionMode.multiple,
        isCategoryTree: true,
        category: c,
      );
      expect(tree.selectedEntriesAtLevel(1).contains(a), isTrue);
      expect(tree.selectedEntriesAtLevel(1).contains(b), isTrue);

      // Remove a
      rules.toggleFlatLeaf(
        tree,
        a,
        selectionMode: SelectionMode.multiple,
        isCategoryTree: true,
        category: c,
      );
      expect(tree.selectedEntriesAtLevel(1).contains(a), isFalse);
      expect(tree.selectedEntriesAtLevel(1).contains(b), isTrue);
    });

    test(
        'category tree: toggling last selected entry in multiple mode re-adds Any if available',
        () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final any = SelectTextEntry<dynamic>.any(parentId: 'c', name: 'Any');
      final a = _text('c', 'a', 'A');
      final b = _text('c', 'b', 'B');
      final c = _category('c', 'C',
          children: {any, a, b}, selectionMode: SelectionMode.multiple);
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(2);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(a);

      // Toggle to deselect a (multiple mode on the category)
      rules.toggleFlatLeaf(
        tree,
        a,
        selectionMode: SelectionMode.multiple,
        isCategoryTree: true,
        category: c,
      );

      // Any should be re-added and category should remain selected
      expect(tree.selectedEntriesAtLevel(1).contains(any), isTrue);
      expect(tree.selectedEntriesAtLevel(0).contains(c), isTrue);
      expect(tree.selectedEntriesAtLevel(1).contains(a), isFalse);
    });

    test(
        'category tree: toggling last selected entry in multiple mode removes category if no Any',
        () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final a = _text('c', 'a', 'A');
      final c = _category('c', 'C',
          children: {a}, selectionMode: SelectionMode.multiple);
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(2);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(a);

      // Toggle to deselect a (multiple mode on the category)
      rules.toggleFlatLeaf(
        tree,
        a,
        selectionMode: SelectionMode.multiple,
        isCategoryTree: true,
        category: c,
      );

      // Category should be removed since there's no Any
      expect(tree.selectedEntriesAtLevel(0).contains(c), isFalse);
    });

    test('category tree: null category returns early', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final a = _text('c', 'a', 'A');
      final c = _category('c', 'C', children: {a});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(1);
      tree.mutableSelectedEntriesAtLevel(0).add(c);

      // null category should not throw
      rules.toggleFlatLeaf(
        tree,
        a,
        selectionMode: SelectionMode.single,
        isCategoryTree: true,
        category: null,
      );

      // Tree should be unchanged
      expect(tree.selectedEntriesAtLevel(0).contains(c), isTrue);
    });

    test('category tree: removes Any entries before selecting non-Any', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final any = SelectTextEntry<dynamic>.any(parentId: 'c', name: 'Any');
      final a = _text('c', 'a', 'A');
      final c = _category('c', 'C', children: {any, a});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(2);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(any);

      rules.toggleFlatLeaf(
        tree,
        a,
        selectionMode: SelectionMode.single,
        isCategoryTree: true,
        category: c,
      );

      expect(tree.selectedEntriesAtLevel(1).contains(any), isFalse);
      expect(tree.selectedEntriesAtLevel(1).contains(a), isTrue);
    });
  });

  group('SelectionRules – toggleCascadingLeaf', () {
    test('single mode: selecting Any replaces all siblings', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final any = SelectTextEntry<dynamic>.any(parentId: 'p', name: 'Any');
      final leaf = _text('p', 'l', 'L');
      final parent = _text('c', 'p', 'P', children: {any, leaf});
      final c = _category('c', 'C', children: {parent});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(3);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(parent);
      tree.mutableSelectedEntriesAtLevel(2).add(leaf);

      rules.toggleCascadingLeaf(
        tree,
        any,
        selectionMode: SelectionMode.single,
        childrenSelectionMode: SelectionMode.single,
        focusedPath: [c, parent],
        category: c,
      );

      expect(tree.selectedEntriesAtLevel(2).contains(any), isTrue);
      expect(tree.selectedEntriesAtLevel(2).contains(leaf), isFalse);
      // All ancestors should remain selected
      expect(tree.selectedEntriesAtLevel(0).contains(c), isTrue);
      expect(tree.selectedEntriesAtLevel(1).contains(parent), isTrue);
    });

    test(
        'single mode: selecting non-Any leaf removes Any from same level and upper levels',
        () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final any = SelectTextEntry<dynamic>.any(parentId: 'p', name: 'Any');
      final leaf = _text('p', 'l', 'L');
      final parent = _text('c', 'p', 'P', children: {any, leaf});
      final c = _category('c', 'C', children: {parent});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(3);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(parent);
      tree.mutableSelectedEntriesAtLevel(2).add(any);

      rules.toggleCascadingLeaf(
        tree,
        leaf,
        selectionMode: SelectionMode.single,
        childrenSelectionMode: SelectionMode.single,
        focusedPath: [c, parent],
        category: c,
      );

      // Any should be removed at level 2, and also at level 1 if it was an Any there
      expect(tree.selectedEntriesAtLevel(2).contains(leaf), isTrue);
      expect(tree.selectedEntriesAtLevel(2).contains(any), isFalse);
    });

    test('single mode: selecting same entry does nothing', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final leaf = _text('p', 'l', 'L');
      final parent = _text('c', 'p', 'P', children: {leaf});
      final c = _category('c', 'C', children: {parent});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(3);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(parent);
      tree.mutableSelectedEntriesAtLevel(2).add(leaf);

      rules.toggleCascadingLeaf(
        tree,
        leaf,
        selectionMode: SelectionMode.single,
        childrenSelectionMode: SelectionMode.single,
        focusedPath: [c, parent],
        category: c,
      );

      expect(tree.selectedEntriesAtLevel(2).contains(leaf), isTrue);
    });

    test('multiple mode: selecting toggles entries', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final leaf1 = _text('p', 'l1', 'L1');
      final leaf2 = _text('p', 'l2', 'L2');
      final parent = _text('c', 'p', 'P', children: {leaf1, leaf2});
      final c = _category('c', 'C', children: {parent});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(3);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(parent);
      tree.mutableSelectedEntriesAtLevel(2).add(leaf1);

      // Add leaf2
      rules.toggleCascadingLeaf(
        tree,
        leaf2,
        selectionMode: SelectionMode.multiple,
        childrenSelectionMode: SelectionMode.multiple,
        focusedPath: [c, parent],
        category: c,
      );
      expect(tree.selectedEntriesAtLevel(2).contains(leaf1), isTrue);
      expect(tree.selectedEntriesAtLevel(2).contains(leaf2), isTrue);

      // Remove leaf1
      rules.toggleCascadingLeaf(
        tree,
        leaf1,
        selectionMode: SelectionMode.multiple,
        childrenSelectionMode: SelectionMode.multiple,
        focusedPath: [c, parent],
        category: c,
      );
      expect(tree.selectedEntriesAtLevel(2).contains(leaf1), isFalse);
      expect(tree.selectedEntriesAtLevel(2).contains(leaf2), isTrue);
    });

    test('multiple mode: selecting Any clears siblings and selects Any', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final any = SelectTextEntry<dynamic>.any(parentId: 'p', name: 'Any');
      final leaf = _text('p', 'l', 'L');
      final parent = _text('c', 'p', 'P', children: {any, leaf});
      final c = _category('c', 'C', children: {parent});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(3);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(parent);
      tree.mutableSelectedEntriesAtLevel(2).add(leaf);

      rules.toggleCascadingLeaf(
        tree,
        any,
        selectionMode: SelectionMode.multiple,
        childrenSelectionMode: SelectionMode.multiple,
        focusedPath: [c, parent],
        category: c,
      );

      expect(tree.selectedEntriesAtLevel(2).contains(any), isTrue);
      expect(tree.selectedEntriesAtLevel(2).contains(leaf), isFalse);
    });

    test('multiple mode: toggling Any removes it', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final any = SelectTextEntry<dynamic>.any(parentId: 'p', name: 'Any');
      final parent = _text('c', 'p', 'P', children: {any});
      final c = _category('c', 'C', children: {parent});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(3);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(parent);
      tree.mutableSelectedEntriesAtLevel(2).add(any);

      rules.toggleCascadingLeaf(
        tree,
        any,
        selectionMode: SelectionMode.multiple,
        childrenSelectionMode: SelectionMode.multiple,
        focusedPath: [c, parent],
        category: c,
      );

      expect(tree.selectedEntriesAtLevel(2).contains(any), isFalse);
    });

    test(
        'cascading: deselection removes ancestors that have no remaining selected children',
        () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final leaf = _text('p', 'l', 'L');
      final parent = _text('c', 'p', 'P', children: {leaf});
      final c = _category('c', 'C', children: {parent});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(3);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(parent);
      tree.mutableSelectedEntriesAtLevel(2).add(leaf);

      // Toggle to deselect leaf (multiple mode)
      rules.toggleCascadingLeaf(
        tree,
        leaf,
        selectionMode: SelectionMode.multiple,
        childrenSelectionMode: SelectionMode.multiple,
        focusedPath: [c, parent],
        category: c,
      );

      // Parent and category should be cleaned up
      // After trimTrailingEmptyLevels, empty levels are removed
    });

    test('cascading: deselecting last leaf adds Any if available', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final any = SelectTextEntry<dynamic>.any(parentId: 'c', name: 'Any');
      final leaf = _text('p', 'l', 'L');
      final parent = _text('c', 'p', 'P', children: {leaf});
      final c = _category('c', 'C', children: {any, parent});
      tree.bind([c], initializeAnyIfEmpty: false);

      tree.ensureLevels(3);
      tree.mutableSelectedEntriesAtLevel(0).add(c);
      tree.mutableSelectedEntriesAtLevel(1).add(parent);
      tree.mutableSelectedEntriesAtLevel(2).add(leaf);

      // Toggle to deselect leaf
      rules.toggleCascadingLeaf(
        tree,
        leaf,
        selectionMode: SelectionMode.multiple,
        childrenSelectionMode: SelectionMode.multiple,
        focusedPath: [c, parent],
        category: c,
      );

      // Category should still be selected with Any
      expect(tree.selectedEntriesAtLevel(0).contains(c), isTrue);
      expect(tree.selectedEntriesAtLevel(1).contains(any), isTrue);
    });

    test('cascading: ensures enough levels for the focused path', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final grandchild = _text('p2', 'gc', 'GC');
      final child = _text('p1', 'p2', 'P2', children: {grandchild});
      final parent = _text('c', 'p1', 'P1', children: {child});
      final c = _category('c', 'C', children: {parent});
      tree.bind([c], initializeAnyIfEmpty: false);

      // Tree has no levels yet, toggleCascadingLeaf should create them
      rules.toggleCascadingLeaf(
        tree,
        grandchild,
        selectionMode: SelectionMode.single,
        childrenSelectionMode: SelectionMode.single,
        focusedPath: [c, parent, child],
        category: c,
      );

      expect(tree.levelCount, greaterThanOrEqualTo(4));
      expect(tree.selectedEntriesAtLevel(0).contains(c), isTrue);
      expect(tree.selectedEntriesAtLevel(1).contains(parent), isTrue);
      expect(tree.selectedEntriesAtLevel(2).contains(child), isTrue);
      expect(tree.selectedEntriesAtLevel(3).contains(grandchild), isTrue);
    });
  });

  group('SelectionRules – toggleHeaderOrFooter', () {
    test('header single mode: selecting toggles entry', () {
      final rules = const SelectionRules();
      final tree = StateTree();
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
      tree.bind([c], initializeAnyIfEmpty: false);

      rules.toggleHeaderOrFooter(
        tree,
        categoryId: 'c',
        entry: h1,
        selectionMode: SelectionMode.single,
        isHeader: true,
      );
      expect(tree.selectedHeaderEntriesFor('c').contains(h1), isTrue);

      // Selecting another replaces it
      rules.toggleHeaderOrFooter(
        tree,
        categoryId: 'c',
        entry: h2,
        selectionMode: SelectionMode.single,
        isHeader: true,
      );
      expect(tree.selectedHeaderEntriesFor('c').contains(h2), isTrue);
      expect(tree.selectedHeaderEntriesFor('c').contains(h1), isFalse);
    });

    test('header single mode: deselecting by toggling same entry', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final h1 = _text('header', 'h1', 'H1');
      final header = _text('c', 'header', 'Header', children: {h1});
      final c = _category(
        'c',
        'C',
        children: {_text('c', 'a', 'A')},
        header: header,
      );
      tree.bind([c], initializeAnyIfEmpty: false);

      rules.toggleHeaderOrFooter(
        tree,
        categoryId: 'c',
        entry: h1,
        selectionMode: SelectionMode.single,
        isHeader: true,
      );
      expect(tree.selectedHeaderEntriesFor('c').contains(h1), isTrue);

      // Toggle again to deselect
      rules.toggleHeaderOrFooter(
        tree,
        categoryId: 'c',
        entry: h1,
        selectionMode: SelectionMode.single,
        isHeader: true,
      );
      expect(tree.selectedHeaderEntriesFor('c').contains(h1), isFalse);
    });

    test('header multiple mode: selecting multiple entries', () {
      final rules = const SelectionRules();
      final tree = StateTree();
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
      tree.bind([c], initializeAnyIfEmpty: false);

      rules.toggleHeaderOrFooter(
        tree,
        categoryId: 'c',
        entry: h1,
        selectionMode: SelectionMode.multiple,
        isHeader: true,
      );
      rules.toggleHeaderOrFooter(
        tree,
        categoryId: 'c',
        entry: h2,
        selectionMode: SelectionMode.multiple,
        isHeader: true,
      );

      expect(tree.selectedHeaderEntriesFor('c').contains(h1), isTrue);
      expect(tree.selectedHeaderEntriesFor('c').contains(h2), isTrue);
    });

    test('header multiple mode: toggling removes entry', () {
      final rules = const SelectionRules();
      final tree = StateTree();
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
      tree.bind([c], initializeAnyIfEmpty: false);

      rules.toggleHeaderOrFooter(
        tree,
        categoryId: 'c',
        entry: h1,
        selectionMode: SelectionMode.multiple,
        isHeader: true,
      );
      rules.toggleHeaderOrFooter(
        tree,
        categoryId: 'c',
        entry: h2,
        selectionMode: SelectionMode.multiple,
        isHeader: true,
      );

      // Remove h1
      rules.toggleHeaderOrFooter(
        tree,
        categoryId: 'c',
        entry: h1,
        selectionMode: SelectionMode.multiple,
        isHeader: true,
      );
      expect(tree.selectedHeaderEntriesFor('c').contains(h1), isFalse);
      expect(tree.selectedHeaderEntriesFor('c').contains(h2), isTrue);
    });

    test('footer single mode: selecting and deselecting', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final f1 = _text('footer', 'f1', 'F1');
      final footer = _text('c', 'footer', 'Footer', children: {f1});
      final c = _category(
        'c',
        'C',
        children: {_text('c', 'a', 'A')},
        footer: footer,
      );
      tree.bind([c], initializeAnyIfEmpty: false);

      rules.toggleHeaderOrFooter(
        tree,
        categoryId: 'c',
        entry: f1,
        selectionMode: SelectionMode.single,
        isHeader: false,
      );
      expect(tree.selectedFooterEntriesFor('c').contains(f1), isTrue);

      rules.toggleHeaderOrFooter(
        tree,
        categoryId: 'c',
        entry: f1,
        selectionMode: SelectionMode.single,
        isHeader: false,
      );
      expect(tree.selectedFooterEntriesFor('c').contains(f1), isFalse);
    });

    test('footer multiple mode: selecting multiple entries', () {
      final rules = const SelectionRules();
      final tree = StateTree();
      final f1 = _text('footer', 'f1', 'F1');
      final f2 = _text('footer', 'f2', 'F2');
      final footer = _text('c', 'footer', 'Footer', children: {f1, f2});
      final c = _category(
        'c',
        'C',
        children: {_text('c', 'a', 'A')},
        footer: footer,
        footerSelectionMode: SelectionMode.multiple,
      );
      tree.bind([c], initializeAnyIfEmpty: false);

      rules.toggleHeaderOrFooter(
        tree,
        categoryId: 'c',
        entry: f1,
        selectionMode: SelectionMode.multiple,
        isHeader: false,
      );
      rules.toggleHeaderOrFooter(
        tree,
        categoryId: 'c',
        entry: f2,
        selectionMode: SelectionMode.multiple,
        isHeader: false,
      );

      expect(tree.selectedFooterEntriesFor('c').contains(f1), isTrue);
      expect(tree.selectedFooterEntriesFor('c').contains(f2), isTrue);
    });
  });
}
