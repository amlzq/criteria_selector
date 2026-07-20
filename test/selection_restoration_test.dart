import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

SelectorEntries _entries(String id) => <SelectorEntry<dynamic>>{
      SelectorTextEntry<dynamic>.name(id: id, name: id.toUpperCase()),
    };

void main() {
  group('Selection restoration', () {
    test('handleApply writes the applied selection back to delegate.selectedData',
        () {
      final delegate = ListSelectorDelegate(
        entriesLoader: () async => <SelectorEntry<dynamic>>{},
      );
      final controller = DropdownSelectorController();
      controller.attachSelectorDelegates(<SelectorDelegate>[delegate]);
      controller.currentIndex = 0;
      // Opening the selector sets `previousSelectorDelegate`; `handleApply`
      // then writes the applied selection back onto it.
      controller.previousSelectorDelegate = delegate;
      // `handleApply` reads `currentTabData.resultLabel`, so a tab must exist.
      controller.tabDataMap[0] = DropdownTabData(index: 0);

      final applied = _entries('a');
      controller.handleApply(applied, 'Selected');

      // The applied selection must be persisted on the delegate so that a
      // reopened controller (DropdownSelectorBar / Button / Dialog / bottom
      // sheet) reconstructs with `previousSelected = applied`.
      expect(delegate.selectedData, applied);
    });

    testWidgets(
        'DropdownSelectorBar restores the previous selection when reopened',
        (tester) async {
      final controller = DropdownSelectorController();
      final delegate = ListSelectorDelegate(
        selectionMode: SelectionMode.multiple,
        entriesLoader: () async => <SelectorEntry<dynamic>>{
          SelectorTextEntry<dynamic>.name(id: 'a', name: 'A'),
          SelectorTextEntry<dynamic>.name(id: 'b', name: 'B'),
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: DropdownSelectorBar(
              tabs: const [DropdownTab(label: 'Filter')],
              selectorDelegates: [delegate],
              controller: controller,
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      // Open, select A, then press Apply (the action bar apply triggers
      // `handleApply`, which writes the selection back to `selectedData`).
      await tester.tap(find.widgetWithText(DropdownTab, 'Filter'));
      await tester.pumpAndSettle();
      expect(controller.isSelectorShowing, isTrue);
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // The applied selection is written back to the delegate.
      expect(delegate.selectedData, isNotNull);
      expect(delegate.selectedData!.any((e) => e.id == 'a'), isTrue);

      // Reopen: the controller must be rebuilt with `previousSelected` coming
      // from `delegate.selectedData`, so the previously applied selection is
      // restored rather than lost. The tab label now shows the applied value.
      await tester.tap(find.widgetWithText(DropdownTab, 'A'));
      await tester.pumpAndSettle();

      expect(controller.isSelectorShowing, isTrue);
      expect(controller.selectorController, isNotNull);
      expect(
          controller.selectorController!.previousSelected!
              .any((e) => e.id == 'a'),
          isTrue);
    });
  });
}
