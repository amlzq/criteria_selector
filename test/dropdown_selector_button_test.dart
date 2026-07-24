import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DropdownSelectorButton', () {
    testWidgets('toggles overlay and rotates the icon on tap', (tester) async {
      var showed = false;
      var hidden = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownSelectorButton(
              label: 'Filter',
              selectorDelegate: ListSelectorDelegate(
                entriesLoader: () async => <SelectorEntry<dynamic>>{
                  SelectorTextEntry<dynamic>.name(id: 'a', name: 'A'),
                },
              ),
              onSelectorShowed: (_) => showed = true,
              onSelectorHidden: (_) => hidden = true,
            ),
          ),
        ),
      );

      expect(showed, isFalse);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(showed, isTrue);
      // The trailing icon rotates 180° (visually) while the overlay is open.
      final rotationFinder = find.descendant(
        of: find.byType(DropdownSelectorButton),
        matching: find.byType(RotationTransition),
      );
      final rotation = tester.widget<RotationTransition>(rotationFinder);
      expect(rotation.turns.value, closeTo(0.5, 0.001));
      expect(find.text('A'), findsOneWidget);

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      expect(hidden, isTrue);
      final rotationClosed = tester.widget<RotationTransition>(rotationFinder);
      expect(rotationClosed.turns.value, closeTo(0.0, 0.001));
    });

    testWidgets('applies selection and updates the trigger label',
        (tester) async {
      DropdownSelectorResult? applied;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownSelectorButton(
              label: 'Sort',
              selectorDelegate: ListSelectorDelegate(
                entriesLoader: () async => <SelectorEntry<dynamic>>{
                  SelectorTextEntry<dynamic>.name(id: 'a', name: 'A'),
                  SelectorTextEntry<dynamic>.name(id: 'b', name: 'B'),
                },
              ),
              onApplied: (tabData, selected) => applied =
                  DropdownSelectorResult(tabData: tabData, selected: selected),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(find.text('Sort'), findsNothing);
      expect(find.text('A'), findsOneWidget);

      expect(applied, isNotNull);
      expect(applied!.selected.any((e) => e.id == 'a'), isTrue);
    });

    testWidgets('renders outlined and elevated variants', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Wrap(
              children: [
                DropdownSelectorButton.elevated(
                  label: 'Elevated',
                  selectorDelegate: ListSelectorDelegate(
                    entriesLoader: () async => <SelectorEntry<dynamic>>{},
                  ),
                ),
                DropdownSelectorButton.outlined(
                  label: 'Outlined',
                  selectorDelegate: ListSelectorDelegate(
                    entriesLoader: () async => <SelectorEntry<dynamic>>{},
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Elevated'), findsOneWidget);
      expect(find.text('Outlined'), findsOneWidget);
    });
  });
}
