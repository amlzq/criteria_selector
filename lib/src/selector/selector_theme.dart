import 'package:flutter/material.dart';

import 'selector_theme_data.dart';

/// Provides [SelectorThemeData] to selector widgets.
///
/// This works similarly to Material's theme widgets and supports merging via
/// [SelectorTheme.merge].
class SelectorTheme extends InheritedTheme {
  const SelectorTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final SelectorThemeData data;

  /// Returns the nearest [SelectorThemeData] or a fallback derived from the
  /// current Material [ThemeData].
  static SelectorThemeData of(BuildContext context) {
    final SelectorTheme? inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<SelectorTheme>();
    return inheritedTheme?.data ??
        SelectorThemeData.fallback(Theme.of(context));
  }

  /// Merges the given [data] into the ambient [SelectorThemeData].
  static Widget merge({
    Key? key,
    SelectorThemeData? data,
    required Widget child,
  }) {
    if (data == null) {
      return child;
    }
    return Builder(
      builder: (context) {
        final merged = SelectorTheme.of(context).copyWith(
          selectedColor: data.selectedColor,
          onSelectedColor: data.onSelectedColor,
          backgroundColor: data.backgroundColor,
          onBackgroundColor: data.onBackgroundColor,
          backgroundColorHigh: data.backgroundColorHigh,
          backgroundColorHighest: data.backgroundColorHighest,
          onBackgroundColorHighest: data.onBackgroundColorHighest,
          actionBarTheme: data.actionBarTheme,
          categoryBarTheme: data.categoryBarTheme,
          gridTileTheme: data.gridTileTheme,
          listTileTheme: data.listTileTheme,
          fieldTileTheme: data.fieldTileTheme,
          radioTheme: data.radioTheme,
          checkboxTheme: data.checkboxTheme,
        );
        return SelectorTheme(key: key, data: merged, child: child);
      },
    );
  }

  @override
  bool updateShouldNotify(SelectorTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return SelectorTheme(data: data, child: child);
  }
}
