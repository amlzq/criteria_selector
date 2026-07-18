import 'dart:async';

import 'package:criteria_selector/criteria_selector.dart';
import 'package:criteria_selector/src/selector/selector_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal [SelectorDelegate] used to drive [SelectorPanel] rendering and to
/// capture the active controller for assertions.
class _TestDelegate extends SelectorDelegate {
  _TestDelegate({
    required this.bodyBuilder,
    super.entriesLoader,
    super.selectedEntriesLoader,
    super.errorBuilder,
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
  Widget buildSkeleton(BuildContext context) =>
      skeletonBuilder?.call(context) ?? const Text('skeleton');
}

void main() {
  group('SelectorPanel', () {
    testWidgets('shows the skeleton while data is loading', (tester) async {
      final completer = Completer<SelectorEntries>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorPanel(
              delegate: _TestDelegate(
                entriesLoader: () => completer.future,
                bodyBuilder: (_, __, ___) => const Text('body'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('skeleton'), findsOneWidget);
      expect(find.text('body'), findsNothing);

      completer.complete(<SelectorEntry>{});
      await tester.pumpAndSettle();
      expect(find.text('skeleton'), findsNothing);
      expect(find.text('body'), findsOneWidget);
    });

    testWidgets('shows the body once data is available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorPanel(
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

    testWidgets('shows an error message when data fails', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorPanel(
              delegate: _TestDelegate(
                entriesLoader: () async => throw Exception('boom'),
                bodyBuilder: (_, __, ___) => const Text('body'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('body'), findsNothing);
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('uses errorBuilder when data fails', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorPanel(
              delegate: _TestDelegate(
                entriesLoader: () async => throw Exception('boom'),
                bodyBuilder: (_, __, ___) => const Text('body'),
                errorBuilder: (error, _) => Text('custom: $error'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('body'), findsNothing);
      expect(find.text('custom: Exception: boom'), findsOneWidget);
    });

    testWidgets('forwards callbacks with an external controller',
        (tester) async {
      final controller =
          SelectorController(selectionMode: SelectionMode.single);
      var changed = false;
      var applied = false;
      var reset = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorPanel(
              delegate: _TestDelegate(
                entriesLoader: () async => <SelectorEntry<dynamic>>{},
                bodyBuilder: (_, __, ___) => const SizedBox(),
              ),
              controller: controller,
              onChangeTap: (_) => changed = true,
              onApplyTap: (_) => applied = true,
              onResetTap: () => reset = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.change(<SelectorEntry>{});
      controller.apply(<SelectorEntry>{});
      controller.reset();

      expect(changed, isTrue);
      expect(applied, isTrue);
      expect(reset, isTrue);
    });

    testWidgets('forwards callbacks with an internal controller',
        (tester) async {
      SelectorController? captured;
      var changed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorPanel(
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

    testWidgets('does not dispose an externally-provided controller',
        (tester) async {
      final controller =
          SelectorController(selectionMode: SelectionMode.single);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorPanel(
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

    testWidgets('disposes its own internal controller', (tester) async {
      SelectorController? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorPanel(
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

    testWidgets('re-registers forwarding listeners when controller changes',
        (tester) async {
      final first = SelectorController(selectionMode: SelectionMode.single);
      final second = SelectorController(selectionMode: SelectionMode.single);
      var appliedOnFirst = false;
      var appliedOnSecond = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorPanel(
              delegate: _TestDelegate(
                entriesLoader: () async => <SelectorEntry<dynamic>>{},
                bodyBuilder: (_, __, ___) => const SizedBox(),
              ),
              controller: first,
              onApplyTap: (_) => appliedOnFirst = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Swap to a new external controller.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectorPanel(
              delegate: _TestDelegate(
                entriesLoader: () async => <SelectorEntry<dynamic>>{},
                bodyBuilder: (_, __, ___) => const SizedBox(),
              ),
              controller: second,
              onApplyTap: (_) => appliedOnSecond = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The first controller must not have been disposed by the panel, and the
      // second controller's callbacks must now fire.
      expect(first.isDisposed, isFalse);
      second.apply(<SelectorEntry>{});
      expect(appliedOnSecond, isTrue);
      expect(appliedOnFirst, isFalse);
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
            body: SelectorPanel(
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
  });
}
