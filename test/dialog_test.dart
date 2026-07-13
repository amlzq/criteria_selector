import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [SelectorDelegate] whose body is a simple widget, so the dialog wrapper
/// can be exercised without relying on a concrete selector's data handling.
class _DialogTestDelegate extends SelectorDelegate {
  _DialogTestDelegate({this.entriesLoader});

  @override
  final Future<SelectorEntries> Function()? entriesLoader;

  @override
  Widget buildBody(
    BuildContext context,
    List<SelectorEntry> entries,
    Set<SelectorEntry>? previousSelected,
  ) =>
      const Text('body');

  @override
  Widget buildSkeleton(BuildContext context) => const Text('skeleton');
}

void main() {
  group('showCriteriaSelector', () {
    testWidgets('shows a dialog and returns null when dismissed',
        (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Placeholder()),
        ),
      );

      final future = showCriteriaSelector(
        context: navigatorKey.currentContext!,
        delegate: _DialogTestDelegate(),
      );

      await tester.pumpAndSettle();

      // The selector panel is rendered inside a modal dialog.
      expect(find.byType(SelectorPanel), findsOneWidget);

      // Simulate a barrier dismiss (returns null).
      Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
          .pop(null);

      final SelectorEntries? result = await future;
      expect(result, isNull);
    });

    testWidgets('returns the popped selection',
        (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Placeholder()),
        ),
      );

      final future = showCriteriaSelector(
        context: navigatorKey.currentContext!,
        delegate: _DialogTestDelegate(),
      );

      await tester.pumpAndSettle();

      final selection = <SelectorEntry>{};
      Navigator.of(navigatorKey.currentContext!, rootNavigator: true)
          .pop(selection);

      final SelectorEntries? result = await future;
      expect(result, selection);
    });
  });
}
