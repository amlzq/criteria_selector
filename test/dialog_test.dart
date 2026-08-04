import 'package:criteria_selector/criteria_selector.dart';
import 'package:criteria_selector/src/selector/selector_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [SelectDelegate] whose body is a simple widget, so the dialog wrapper
/// can be exercised without relying on a concrete selector's data handling.
class _DialogTestDelegate extends SelectDelegate {
  _DialogTestDelegate();

  @override
  Widget buildBody(
    BuildContext context,
    List<SelectEntry> entries,
    Set<SelectEntry>? previousSelected,
  ) =>
      const Text('body');

  @override
  Widget buildSkeleton(BuildContext context) => const Text('skeleton');
}

void main() {
  group('showSelect', () {
    testWidgets('shows a dialog and returns null when dismissed',
        (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Placeholder()),
        ),
      );

      final future = showSelect(
        context: navigatorKey.currentContext!,
        delegate: _DialogTestDelegate(),
      );

      await tester.pumpAndSettle();

      // The selector panel is rendered inside a modal dialog.
      expect(find.byType(SelectorPanel), findsOneWidget);

      // Simulate a barrier dismiss (returns null).
      Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop(null);

      final SelectEntries? result = await future;
      expect(result, isNull);
    });

    testWidgets('returns the popped selection', (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Placeholder()),
        ),
      );

      final future = showSelect(
        context: navigatorKey.currentContext!,
        delegate: _DialogTestDelegate(),
      );

      await tester.pumpAndSettle();

      final selection = <SelectEntry>{};
      Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
          .pop(selection);

      final SelectEntries? result = await future;
      expect(result, selection);
    });

    testWidgets('deprecated showSelector alias behaves identically',
        (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Placeholder()),
        ),
      );

      // ignore: deprecated_member_use
      final future = showSelector(
        context: navigatorKey.currentContext!,
        delegate: _DialogTestDelegate(),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SelectorPanel), findsOneWidget);

      // ignore: deprecated_member_use
      Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop(null);

      final SelectEntries? result = await future;
      expect(result, isNull);
    });
  });
}
