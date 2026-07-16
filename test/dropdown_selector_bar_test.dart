import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
      // The default indicator (Icons.arrow_drop_down) rotates 180° to point up
      // while expanded; the icon data is unchanged, so assert on the rotation
      // rather than on a swapped Icons.arrow_drop_up widget.
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_up), findsNothing);
      final expandedRotation = tester.widget<RotationTransition>(
        find.descendant(
          of: find.byType(DropdownTab),
          matching: find.byType(RotationTransition),
        ),
      );
      expect(expandedRotation.turns.value, 0.5);
      expect(find.text('A'), findsOneWidget);

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(hidden, isTrue);
      expect(controller.isSelectorShowing, isFalse);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      final collapsedRotation = tester.widget<RotationTransition>(
        find.descendant(
          of: find.byType(DropdownTab),
          matching: find.byType(RotationTransition),
        ),
      );
      expect(collapsedRotation.turns.value, 0.0);
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
}
