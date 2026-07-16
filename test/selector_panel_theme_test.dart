import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _shapeA = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
);
const _shapeB = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(24)),
);

void main() {
  group('SelectorPanelTheme', () {
    test('copyWith replaces only non-null fields', () {
      const base = SelectorPanelTheme(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
      );
      final copy = base.copyWith(shape: _shapeA);
      expect(copy.elevation, 1);
      expect(copy.shape, _shapeA);
      expect(copy.clipBehavior, Clip.antiAlias);
      expect(copy.shadowColor, isNull);
    });

    test('lerp interpolates elevation, colors and shape', () {
      const a = SelectorPanelTheme(
        elevation: 0,
        shadowColor: Color(0x00000000),
        surfaceTintColor: Color(0x00000000),
        shape: _shapeA,
        clipBehavior: Clip.none,
      );
      const b = SelectorPanelTheme(
        elevation: 10,
        shadowColor: Color(0xff000000),
        surfaceTintColor: Color(0xffffffff),
        shape: _shapeB,
        clipBehavior: Clip.antiAlias,
      );
      final mid = SelectorPanelTheme.lerp(a, b, 0.5);
      expect(mid.elevation, 5);
      // Flutter convention: at t >= 0.5 the end value wins.
      expect(mid.clipBehavior, Clip.antiAlias);
      final quarter = SelectorPanelTheme.lerp(a, b, 0.25);
      expect(quarter.clipBehavior, Clip.none);
      final end = SelectorPanelTheme.lerp(a, b, 1);
      expect(end.elevation, 10);
      expect(end.clipBehavior, Clip.antiAlias);
    });

    test('lerp returns identical non-null theme when a and b are identical',
        () {
      const a = SelectorPanelTheme(elevation: 4);
      expect(SelectorPanelTheme.lerp(a, a, 0.3), same(a));
    });

    test('equality and hashCode', () {
      const a = SelectorPanelTheme(elevation: 2, shape: _shapeA);
      const b = SelectorPanelTheme(elevation: 2, shape: _shapeA);
      const c = SelectorPanelTheme(elevation: 3, shape: _shapeA);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });
  });

  group('SelectorThemeData.panelTheme', () {
    test('default is a const SelectorPanelTheme', () {
      final theme = SelectorThemeData(ThemeData.light());
      expect(theme.panelTheme, const SelectorPanelTheme());
    });

    test('copyWith and lerp propagate panelTheme', () {
      const themeA = SelectorPanelTheme(elevation: 0);
      const themeB = SelectorPanelTheme(elevation: 8, shape: _shapeB);
      final dataA = SelectorThemeData(ThemeData.light(), panelTheme: themeA);
      final dataB = SelectorThemeData(ThemeData.light(), panelTheme: themeB);

      final copied = dataA.copyWith(panelTheme: themeB);
      expect(copied.panelTheme, themeB);

      final lerped = SelectorThemeData.lerp(dataA, dataB, 1)!;
      expect(lerped.panelTheme.elevation, 8);
    });

    testWidgets('CriteriaSelector renders Material when decorated',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CriteriaSelector(
              delegate: _EmptyDelegate(
                panelTheme: const SelectorPanelTheme(
                  elevation: 6,
                  shape: _shapeA,
                  clipBehavior: Clip.antiAlias,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // The Scaffold itself provides a background Material (elevation 0), so
      // filter for the panel's elevated Material specifically.
      final panelMaterial = find.byWidgetPredicate(
        (w) => w is Material && w.elevation > 0,
      );
      expect(panelMaterial, findsOneWidget);
      expect(
        tester.widget<Material>(panelMaterial).elevation,
        6,
      );
    });

    testWidgets('CriteriaSelector falls back to ColoredBox when undecorated',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CriteriaSelector(
              delegate: _EmptyDelegate(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // No elevated (decorated) Material should be present for the panel.
      expect(
        find.byWidgetPredicate((w) => w is Material && w.elevation > 0),
        findsNothing,
      );
      expect(find.byType(ColoredBox), findsOneWidget);
    });

    testWidgets('delegate.panelTheme is applied without a selectorTheme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CriteriaSelector(
              delegate: _EmptyDelegate(
                panelTheme: const SelectorPanelTheme(
                  elevation: 4,
                  shape: _shapeB,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final panelMaterial = find.byWidgetPredicate(
        (w) => w is Material && w.elevation > 0,
      );
      expect(panelMaterial, findsOneWidget);
      expect(tester.widget<Material>(panelMaterial).elevation, 4);
    });
  });
}

class _EmptyDelegate extends SelectorDelegate {
  _EmptyDelegate({super.panelTheme});

  @override
  Widget buildBody(
    BuildContext context,
    List<SelectorEntry> entries,
    Set<SelectorEntry>? previousSelected,
  ) =>
      const SizedBox();

  @override
  Widget buildSkeleton(BuildContext context) => const SizedBox();
}
