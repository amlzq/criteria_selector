import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

SelectorTextEntry<dynamic> _text(
  String parentId,
  String id,
  String name, {
  Set<SelectorEntry<dynamic>>? children,
}) {
  return SelectorTextEntry<dynamic>(
    parentId: parentId,
    id: id,
    name: name,
    children: children,
  );
}

SelectorCategoryEntry<dynamic> _category(
  String id,
  String name, {
  required Set<SelectorEntry<dynamic>> children,
  SelectionMode selectionMode = SelectionMode.single,
}) {
  return SelectorCategoryEntry<dynamic>(
    id: id,
    name: name,
    children: children,
    selectionMode: selectionMode,
  );
}

void main() {
  group('DropdownSelectorBar', () {
    testWidgets('toggles overlay and indicator on tap', (tester) async {
      var showed = false;
      var hidden = false;
      final controller = DropdownSelectorController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: DropdownSelectorBar(
              tabs: const [
                DropdownTab(label: 'Filter'),
              ],
              selectorDelegates: [
                ListSelectorDelegate(
                  entriesLoader: () async => <SelectorEntry<dynamic>>{
                    SelectorTextEntry<dynamic>.name(id: 'a', name: 'A'),
                  },
                ),
              ],
              onSelectorShowed: (_) => showed = true,
              onSelectorHidden: (_) => hidden = true,
              controller: controller,
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      expect(controller.isSelectorShowing, isFalse);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_up), findsNothing);

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(showed, isTrue);
      expect(controller.isSelectorShowing, isTrue);
      expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);
      expect(find.text('A'), findsOneWidget);

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(hidden, isTrue);
      expect(controller.isSelectorShowing, isFalse);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('applies selection and updates tab label', (tester) async {
      DropdownSelectorResult? applied;
      final controller = DropdownSelectorController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: DropdownSelectorBar(
              tabs: const [
                DropdownTab(label: 'Sort'),
              ],
              selectorDelegates: [
                ListSelectorDelegate(
                  entriesLoader: () async => <SelectorEntry<dynamic>>{
                    SelectorTextEntry<dynamic>.name(id: 'a', name: 'A'),
                    SelectorTextEntry<dynamic>.name(id: 'b', name: 'B'),
                  },
                ),
              ],
              onApplied: (result) => applied = result,
              controller: controller,
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();

      expect(controller.isSelectorShowing, isTrue);
      expect(find.text('A'), findsOneWidget);

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(controller.isSelectorShowing, isFalse);
      expect(find.text('Sort'), findsNothing);
      expect(find.text('A'), findsOneWidget);

      expect(applied, isNotNull);
      expect(applied!.selected.any((e) => e.id == 'a'), isTrue);
    });

    testWidgets('uses labelGetter when provided', (tester) async {
      DropdownSelectorResult? applied;
      final controller = DropdownSelectorController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: DropdownSelectorBar(
              tabs: [
                DropdownTab(
                  label: 'Price',
                  labelGetter: (_) => 'Custom',
                ),
              ],
              selectorDelegates: [
                ListSelectorDelegate(
                  entriesLoader: () async => <SelectorEntry<dynamic>>{
                    SelectorTextEntry<dynamic>.name(id: 'a', name: 'A'),
                  },
                ),
              ],
              onApplied: (result) => applied = result,
              controller: controller,
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      await tester.tap(find.text('Price'));
      await tester.pumpAndSettle();

      expect(controller.isSelectorShowing, isTrue);

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(controller.isSelectorShowing, isFalse);
      expect(find.text('Custom'), findsOneWidget);
      expect(find.text('Price'), findsNothing);
      expect(applied, isNotNull);
    });

    testWidgets('fires onChanged and onReset in multiple selection',
        (tester) async {
      DropdownSelectorResult? changed;
      var resetCalled = false;
      final controller = DropdownSelectorController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: DropdownSelectorBar(
              tabs: const [
                DropdownTab(label: 'Multi'),
              ],
              selectorDelegates: [
                ListSelectorDelegate(
                  selectionMode: SelectionMode.multiple,
                  entriesLoader: () async => <SelectorEntry<dynamic>>{
                    SelectorTextEntry<dynamic>.name(id: 'a', name: 'A'),
                    SelectorTextEntry<dynamic>.name(id: 'b', name: 'B'),
                  },
                ),
              ],
              onChanged: (result) => changed = result,
              onReset: () => resetCalled = true,
              controller: controller,
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      await tester.tap(find.text('Multi'));
      await tester.pumpAndSettle();

      expect(controller.isSelectorShowing, isTrue);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(controller.isSelectorShowing, isTrue);
      expect(changed, isNotNull);
      expect(changed!.selected.any((e) => e.id == 'a'), isTrue);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(controller.isSelectorShowing, isTrue);
      expect(resetCalled, isTrue);
    });
  });

  group('CascadingSelector', () {
    testWidgets('restores a connected deepest focused path', (tester) async {
      final branchALeaf = _text('a', 'a_leaf', 'BranchALeaf');
      final branchA = _text('c', 'a', 'BranchA', children: {branchALeaf});
      final branchBLeaf = _text('b', 'b_leaf', 'BranchBLeaf');
      final branchB = _text('c', 'b', 'BranchB', children: {branchBLeaf});
      final category = _category(
        'c',
        'Category',
        children: {branchA, branchB},
        selectionMode: SelectionMode.multiple,
      );

      final previousSelected = <SelectorEntry<dynamic>>{
        _category(
          'c',
          'Category',
          children: {
            _text(
              'c',
              'a',
              'BranchA',
              children: {
                _text('a', 'a_leaf', 'BranchALeaf'),
              },
            ),
            _text('c', 'b', 'BranchB'),
          },
          selectionMode: SelectionMode.multiple,
        ),
      };

      final selector =
          CascadingSelectorDelegate(selectionMode: SelectionMode.multiple);
      final controller = SelectorController(
        selectionMode: SelectionMode.multiple,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorTheme(
              data: SelectorThemeData.fallback(ThemeData()),
              child: SelectorControllerProvider(
                controller: controller,
                child: Builder(
                  builder: (context) => selector.buildBody(
                    context,
                    [category],
                    previousSelected,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('BranchA'), findsOneWidget);
      expect(find.text('BranchB'), findsOneWidget);
      expect(find.text('BranchALeaf'), findsOneWidget);
      expect(find.text('BranchBLeaf'), findsNothing);
    });

    testWidgets('reveals restored target item when it is initially offscreen',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 320));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final targetLeaf = _text('parent', 'target_leaf', 'TargetLeaf');
      final leaves = <SelectorEntry<dynamic>>{
        for (int i = 0; i < 16; i++) _text('parent', 'leaf_$i', 'Leaf $i'),
        targetLeaf,
      };
      final parent = _text('c', 'parent', 'Parent', children: leaves);
      final category = _category(
        'c',
        'Category',
        children: {parent},
        selectionMode: SelectionMode.multiple,
      );

      final previousSelected = <SelectorEntry<dynamic>>{
        _category(
          'c',
          'Category',
          children: {
            _text(
              'c',
              'parent',
              'Parent',
              children: {
                _text('parent', 'target_leaf', 'TargetLeaf'),
              },
            ),
          },
          selectionMode: SelectionMode.multiple,
        ),
      };

      final selector =
          CascadingSelectorDelegate(selectionMode: SelectionMode.multiple);
      final controller = SelectorController(
        selectionMode: SelectionMode.multiple,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorTheme(
              data: SelectorThemeData.fallback(ThemeData()),
              child: SelectorControllerProvider(
                controller: controller,
                child: Builder(
                  builder: (context) => selector.buildBody(
                    context,
                    [category],
                    previousSelected,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Parent'), findsOneWidget);
      expect(find.text('TargetLeaf'), findsOneWidget);
      expect(find.text('Leaf 0'), findsNothing);
    });
  });

  group('Deprecated API backward compatibility', () {
    testWidgets('still works with deprecated `selectors` and `ListSelector`',
        (tester) async {
      final controller = DropdownSelectorController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: DropdownSelectorBar(
              tabs: const [
                DropdownTab(label: 'Filter'),
              ],
              // ignore: deprecated_member_use_from_same_package
              selectors: [
                // ignore: deprecated_member_use_from_same_package
                ListSelector(
                  entriesLoader: () async => <SelectorEntry<dynamic>>{
                    SelectorTextEntry<dynamic>.name(id: 'a', name: 'A'),
                  },
                ),
              ],
              controller: controller,
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(controller.isSelectorShowing, isTrue);
      expect(find.text('A'), findsOneWidget);
    });

    test('deprecated selector aliases point to the new Delegate types', () {
      // ignore: deprecated_member_use_from_same_package
      final ListSelector list = ListSelectorDelegate();
      expect(list, isA<ListSelectorDelegate>());

      // ignore: deprecated_member_use_from_same_package
      final Selector base = list;
      expect(base, isA<SelectorDelegate>());
    });
  });
}
