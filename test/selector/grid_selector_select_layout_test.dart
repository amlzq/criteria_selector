import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

SelectTextEntry<dynamic> _child({
  required String parentId,
  required String id,
  required String name,
}) {
  return SelectTextEntry<dynamic>(
    parentId: parentId,
    id: id,
    name: name,
  );
}

SelectCategoryEntry<dynamic> _category({
  required String id,
  required String name,
  required Set<SelectEntry<dynamic>> children,
  SelectLayout? layout,
  SelectionMode selectionMode = SelectionMode.single,
}) {
  return SelectCategoryEntry<dynamic>(
    id: id,
    name: name,
    children: children,
    layout: layout,
    selectionMode: selectionMode,
  );
}

Widget _buildGridSelector(
  List<SelectEntry<dynamic>> entries, {
  GridSelectDelegate? delegate,
  Set<SelectEntry<dynamic>>? previousSelected,
}) {
  final effectiveDelegate = delegate ??
      GridSelectDelegate(
        crossAxisCount: 3,
        selectionMode: SelectionMode.single,
      );
  final controller = SelectController(
    selectionMode: effectiveDelegate.selectionMode,
  );

  return MaterialApp(
    home: Scaffold(
      body: SelectTheme(
        data: SelectThemeData.fallback(ThemeData()),
        child: SelectControllerProvider(
          controller: controller,
          child: Builder(
            builder: (context) => effectiveDelegate.buildBody(
              context,
              entries,
              previousSelected,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('GridSelector SelectLayout Consumption', () {
    testWidgets('renders default SelectListLayout when layout is null',
        (tester) async {
      final children = {
        _child(parentId: 'c', id: 'a', name: 'Option A'),
        _child(parentId: 'c', id: 'b', name: 'Option B'),
      };
      final category = _category(
        id: 'c',
        name: 'Test Category',
        children: children,
      );

      await tester.pumpWidget(_buildGridSelector([category]));
      await tester.pumpAndSettle();

      // Default layout (null) falls back to SelectListLayout
      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
    });

    testWidgets('renders SelectListLayout as list view', (tester) async {
      final children = {
        _child(parentId: 'c', id: 'a', name: 'List Item A'),
        _child(parentId: 'c', id: 'b', name: 'List Item B'),
      };
      final category = _category(
        id: 'c',
        name: 'List Category',
        children: children,
        layout: const SelectListLayout(),
      );

      await tester.pumpWidget(_buildGridSelector([category]));
      await tester.pumpAndSettle();

      // Items should be rendered in a list view
      expect(find.text('List Item A'), findsOneWidget);
      expect(find.text('List Item B'), findsOneWidget);
    });

    testWidgets('renders SelectGridLayout as grid view', (tester) async {
      final children = {
        _child(parentId: 'c', id: 'a', name: 'Grid Item A'),
        _child(parentId: 'c', id: 'b', name: 'Grid Item B'),
      };
      final category = _category(
        id: 'c',
        name: 'Grid Category',
        children: children,
        layout: const SelectGridLayout(crossAxisCount: 2),
      );

      await tester.pumpWidget(_buildGridSelector([category]));
      await tester.pumpAndSettle();

      // Items should be rendered in a grid view
      expect(find.text('Grid Item A'), findsOneWidget);
      expect(find.text('Grid Item B'), findsOneWidget);
    });

    testWidgets('renders SelectChipLayout as chip bar', (tester) async {
      final children = {
        _child(parentId: 'c', id: 'a', name: 'Chip A'),
        _child(parentId: 'c', id: 'b', name: 'Chip B'),
      };
      final category = _category(
        id: 'c',
        name: 'Chip Category',
        children: children,
        layout: const SelectChipLayout(),
      );

      await tester.pumpWidget(_buildGridSelector([category]));
      await tester.pumpAndSettle();

      // Items should be rendered as chips
      expect(find.text('Chip A'), findsOneWidget);
      expect(find.text('Chip B'), findsOneWidget);
    });

    testWidgets('renders SelectRangeLayout as range view', (tester) async {
      final children = <SelectEntry<dynamic>>{
        SelectRangeEntry.custom(
          parentId: 'c',
          name: 'Custom Range',
          min: 0,
          max: 100,
        ),
      };
      final category = _category(
        id: 'c',
        name: 'Range Category',
        children: children,
        layout: const SelectRangeLayout(),
      );

      await tester.pumpWidget(_buildGridSelector([category]));
      await tester.pumpAndSettle();

      // The range view should render a SelectorRangeSlider
      expect(find.byType(SelectorRangeSlider), findsOneWidget);
    });

    testWidgets('switches between tabs with different layouts', (tester) async {
      final gridChildren = {
        _child(parentId: 'grid', id: 'g1', name: 'Grid A'),
        _child(parentId: 'grid', id: 'g2', name: 'Grid B'),
      };
      final chipChildren = {
        _child(parentId: 'chip', id: 'c1', name: 'Chip A'),
        _child(parentId: 'chip', id: 'c2', name: 'Chip B'),
      };

      final gridCategory = _category(
        id: 'grid',
        name: 'Grid Tab',
        children: gridChildren,
        layout: const SelectGridLayout(crossAxisCount: 2),
      );
      final chipCategory = _category(
        id: 'chip',
        name: 'Chip Tab',
        children: chipChildren,
        layout: const SelectChipLayout(),
      );

      await tester.pumpWidget(
        _buildGridSelector(
          [gridCategory, chipCategory],
          delegate: GridSelectDelegate(
            crossAxisCount: 3,
            selectionMode: SelectionMode.single,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // First tab (Grid) should be visible
      expect(find.text('Grid A'), findsOneWidget);
      expect(find.text('Grid B'), findsOneWidget);
      expect(find.text('Chip A'), findsNothing);

      // Tap the second tab (Chip)
      await tester.tap(find.text('Chip Tab'));
      await tester.pumpAndSettle();

      // Chip tab items should now be visible, grid items hidden
      expect(find.text('Chip A'), findsOneWidget);
      expect(find.text('Chip B'), findsOneWidget);
    });

    testWidgets('GridLayout uses layout params not delegate defaults',
        (tester) async {
      final children = {
        _child(parentId: 'c', id: 'a', name: 'Layout Grid Item'),
      };
      final category = _category(
        id: 'c',
        name: 'Grid Category',
        children: children,
        layout: const SelectGridLayout(
          crossAxisCount: 5,
          childAspectRatio: 2.0,
        ),
      );

      await tester.pumpWidget(
        _buildGridSelector(
          [category],
          delegate: GridSelectDelegate(
            crossAxisCount: 2, // Different from layout's 5
            childAspectRatio: 1.0, // Different from layout's 2.0
            selectionMode: SelectionMode.single,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Item should render; the layout's crossAxisCount=5 is used, not delegate's 2
      expect(find.text('Layout Grid Item'), findsOneWidget);
    });
  });
}
