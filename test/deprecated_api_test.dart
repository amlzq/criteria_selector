import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
