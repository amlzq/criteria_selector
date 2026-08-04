// Tests that the deprecated `Selector*Delegate` aliases and the deprecated
// `selectorDelegate(s)` members remain usable for backward compatibility.
// These aliases are slated for removal in a future minor version.
//
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deprecated SelectorDelegate type alias resolves to SelectDelegate', () {
    SelectorDelegate base = ListSelectorDelegate();
    expect(base, isA<SelectDelegate>());

    expect(CascadingSelectorDelegate(), isA<CascadingSelectDelegate>());
    expect(ListSelectorDelegate(), isA<ListSelectDelegate>());
    expect(GridSelectorDelegate(crossAxisCount: 2), isA<GridSelectDelegate>());
    expect(FlattenSelectorDelegate(crossAxisCount: 2),
        isA<FlattenSelectDelegate>());
  });

  testWidgets('PopupSelectBar maps deprecated selectorDelegates parameter',
      (tester) async {
    final bar = PopupSelectBar(
      tabs: const [PopupTab(label: 'Filter')],
      selectorDelegates: [ListSelectorDelegate()],
    );
    expect(bar.selectDelegates, hasLength(1));
    expect(bar.selectorDelegates, hasLength(1));
  });

  testWidgets('PopupSelectButton maps deprecated selectorDelegate parameter',
      (tester) async {
    final button = PopupSelectButton(
      label: 'Filter',
      selectorDelegate: ListSelectorDelegate(),
    );
    expect(button.selectDelegate, isA<ListSelectDelegate>());
    expect(button.selectorDelegate, isA<ListSelectDelegate>());
  });

  test('PopupSelectController keeps deprecated members working', () {
    final controller = PopupSelectController();
    final delegate = ListSelectDelegate();

    controller.attachSelectorDelegates([delegate]);
    controller.currentIndex = 0;
    controller.previousSelectorDelegate = delegate;
    expect(controller.previousSelectorDelegate, same(delegate));
    expect(controller.previousSelectDelegate, same(delegate));
  });

  test('deprecated overlay / label type aliases resolve to Select* types', () {
    // DropdownOverlayStyle -> SelectOverlayStyle
    DropdownOverlayStyle style = const SelectOverlayStyle();
    expect(style, isA<SelectOverlayStyle>());
    expect(const DropdownOverlayStyle(), isA<SelectOverlayStyle>());

    // SelectorLabelState -> SelectLabelState
    SelectorLabelState labelState = SelectLabelState(originalLabel: 'All');
    expect(labelState, isA<SelectLabelState>());
    expect(labelState.originalLabel, 'All');

    // SelectorLabelLoader -> SelectLabelLoader
    String loader(SelectEntries selected) => '${selected.length} selected';
    expect(loader, isA<SelectLabelLoader>());
    expect(loader(<SelectEntry<dynamic>>{}), '0 selected');
  });
}
