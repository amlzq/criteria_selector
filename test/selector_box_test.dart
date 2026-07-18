import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal [SelectorDelegate] used to drive [SelectorBox] rendering and
/// to capture the active controller for assertions.
class _TestDelegate extends SelectorDelegate {
  _TestDelegate({
    required this.bodyBuilder,
    super.entriesLoader,
    super.selectedEntriesLoader,
  });

  final Widget Function(
    BuildContext context,
    List<SelectorEntry> entries,
    Set<SelectorEntry>? previousSelected,
  ) bodyBuilder;

  @override
  Widget buildBody(
    BuildContext context,
    List<SelectorEntry> entries,
    Set<SelectorEntry>? previousSelected,
  ) =>
      bodyBuilder(context, entries, previousSelected);

  @override
  Widget buildSkeleton(BuildContext context) => const Text('skeleton');
}

void main() {
  group('SelectorBox', () {
    testWidgets('renders the body once data is available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorBox(
              delegate: _TestDelegate(
                entriesLoader: () async => <SelectorEntry<dynamic>>{
                  SelectorTextEntry<dynamic>.name(id: 'a', name: 'A'),
                },
                bodyBuilder: (context, entries, _) =>
                    Text('entries:${entries.length}'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('entries:1'), findsOneWidget);
    });

    testWidgets('forwards onChangeTap through an internal controller',
        (tester) async {
      SelectorController? captured;
      var changed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorBox(
              delegate: _TestDelegate(
                entriesLoader: () async => <SelectorEntry<dynamic>>{},
                bodyBuilder: (context, _, __) {
                  captured = SelectorController.of(context);
                  return const SizedBox();
                },
              ),
              onChangeTap: (_) => changed = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      captured!.change(<SelectorEntry>{});

      expect(changed, isTrue);
    });

    testWidgets('disposes its own internal controller on unmount',
        (tester) async {
      SelectorController? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorBox(
              delegate: _TestDelegate(
                entriesLoader: () async => <SelectorEntry<dynamic>>{},
                bodyBuilder: (context, _, __) {
                  captured = SelectorController.of(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(captured, isNotNull);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(captured!.isDisposed, isTrue);
    });

    testWidgets('does not dispose an externally-provided controller',
        (tester) async {
      final controller =
          SelectorController(selectionMode: SelectionMode.single);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorBox(
              delegate: _TestDelegate(
                entriesLoader: () async => <SelectorEntry<dynamic>>{},
                bodyBuilder: (_, __, ___) => const SizedBox(),
              ),
              controller: controller,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      expect(controller.isDisposed, isFalse);
    });

    testWidgets('initializes the internal controller from delegate state',
        (tester) async {
      SelectorController? captured;
      final previous = <SelectorEntry<dynamic>>{
        SelectorTextEntry<dynamic>.name(id: 'a', name: 'A'),
      };
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorBox(
              delegate: _TestDelegate(
                entriesLoader: () async => <SelectorEntry<dynamic>>{},
                selectedEntriesLoader: () => previous,
                bodyBuilder: (context, _, __) {
                  captured = SelectorController.of(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.previousSelected, isNotNull);
      expect(captured!.previousSelected!.any((e) => e.id == 'a'), isTrue);
    });

    testWidgets('does not leak an internal controller across rebuilds',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorBox(
              delegate: _TestDelegate(
                entriesLoader: () async => <SelectorEntry<dynamic>>{},
                bodyBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Rebuild with the same (null) controller; no new internal controller
      // should be created, and the old one must not have been disposed
      // prematurely.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorBox(
              delegate: _TestDelegate(
                entriesLoader: () async => <SelectorEntry<dynamic>>{},
                bodyBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders inside an unbounded context without throwing',
        (tester) async {
      // Regression: a Column(min) + Expanded body (as the CascadingSelector
      // uses) requires a bounded height. Embedding SelectorBox in an
      // unbounded parent (Column with mainAxisSize.min) must not throw the
      // "non-zero flex but incoming height constraints are unbounded" error;
      // the internal ConstrainedBox caps the height so the Expanded can lay
      // out.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('header'),
                  SelectorBox(
                    delegate: _TestDelegate(
                      entriesLoader: () async => <SelectorEntry<dynamic>>{
                        SelectorTextEntry<dynamic>.name(id: 'a', name: 'A'),
                      },
                      bodyBuilder: (context, entries, _) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('body'),
                          Expanded(
                            child: ListView(
                              children: [
                                for (final e in entries) Text(e.name ?? ''),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('body'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('caps height to maxHeightFactor of the screen height',
        (tester) async {
      final mediaQuery = MediaQueryData(size: const Size(400, 800));
      await tester.pumpWidget(
        MediaQuery(
          data: mediaQuery,
          child: MaterialApp(
            home: Scaffold(
              body: SelectorBox(
                maxHeightFactor: 0.5,
                delegate: _TestDelegate(
                  entriesLoader: () async => <SelectorEntry<dynamic>>{},
                  // A tall, unconstrained body to verify the cap is applied.
                  bodyBuilder: (_, __, ___) => Container(height: 5000.0),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The internal ConstrainedBox must cap the height at the expected factor.
      final hasCap = tester
          .widgetList(find.byType(ConstrainedBox))
          .where((w) => w is ConstrainedBox && w.constraints.maxHeight == 400)
          .isNotEmpty;
      expect(hasCap, isTrue);
    });
  });
}
