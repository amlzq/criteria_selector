import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'widgets/action_bar_theme.dart';
import 'widgets/category_bar_theme.dart';
import 'widgets/chip_bar_theme.dart';
import 'widgets/field_tile_theme.dart';
import 'widgets/grid_tile_theme.dart';
import 'widgets/list_tile_theme.dart';

@immutable

/// Theme configuration for selector widgets.
///
/// This object is usually derived from a Material [ThemeData] plus optional
/// overrides, and is consumed by selector widgets to keep styling consistent.
class SelectorThemeData with Diagnosticable {
  /// Creates a [SelectorThemeData] by reading defaults from [theme] and applying
  /// optional overrides.
  factory SelectorThemeData(
    ThemeData theme, {
    Color? selectedColor,
    Color? onSelectedColor,
    Color? backgroundColor,
    Color? onBackgroundColor,
    Color? backgroundColorHigh,
    Color? backgroundColorHighest,
    Color? onBackgroundColorHighest,
    SelectorActionBarTheme? actionBarTheme,
    SelectorCategoryBarTheme? categoryBarTheme,
    SelectorGridTileTheme? gridTileTheme,
    SelectorListTileTheme? listTileTheme,
    SelectorFieldTileTheme? fieldTileTheme,
    RadioThemeData? radioTheme,
    CheckboxThemeData? checkboxTheme,
    SelectorChipBarTheme? chipBarThemeData,
  }) {
    return SelectorThemeData.raw(
      selectedColor: selectedColor ?? theme.colorScheme.primary,
      onSelectedColor: onSelectedColor ?? theme.colorScheme.onPrimary,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      onBackgroundColor: onBackgroundColor ?? theme.colorScheme.onSurface,
      backgroundColorHigh:
          backgroundColorHigh ?? theme.colorScheme.surfaceContainerLow,
      backgroundColorHighest:
          backgroundColorHighest ?? theme.colorScheme.surfaceContainer,
      onBackgroundColorHighest:
          onBackgroundColorHighest ?? theme.colorScheme.onSurfaceVariant,
      actionBarTheme: actionBarTheme ?? const SelectorActionBarTheme(),
      categoryBarTheme: categoryBarTheme ?? const SelectorCategoryBarTheme(),
      gridTileTheme: gridTileTheme ?? const SelectorGridTileTheme(),
      listTileTheme: listTileTheme ?? const SelectorListTileTheme(),
      fieldTileTheme: fieldTileTheme ?? const SelectorFieldTileTheme(),
      radioTheme: radioTheme ?? const RadioThemeData(),
      checkboxTheme: checkboxTheme ?? const CheckboxThemeData(),
      chipBarThemeData: chipBarThemeData ?? const SelectorChipBarTheme(),
    );
  }

  /// Creates a [SelectorThemeData] with explicit values.
  const SelectorThemeData.raw({
    required this.selectedColor,
    required this.onSelectedColor,
    required this.backgroundColor,
    required this.onBackgroundColor,
    required this.backgroundColorHigh,
    required this.backgroundColorHighest,
    required this.onBackgroundColorHighest,
    required this.actionBarTheme,
    required this.categoryBarTheme,
    required this.gridTileTheme,
    required this.listTileTheme,
    required this.fieldTileTheme,
    required this.radioTheme,
    required this.checkboxTheme,
    required this.chipBarThemeData,
  });

  /// Convenience factory that uses [theme] defaults without any overrides.
  factory SelectorThemeData.fallback(ThemeData theme) =>
      SelectorThemeData(theme);

  /// The background color used for selected entries.
  final Color selectedColor;

  /// Text/icon color used on top of [selectedColor].
  final Color onSelectedColor;

  /// Base background color used by the selector panel.
  final Color backgroundColor;

  /// Text/icon color used on top of [backgroundColor].
  final Color onBackgroundColor;

  /// A higher-contrast background color used for elevated sections.
  final Color backgroundColorHigh;

  /// The highest-contrast background color (often used for nested levels).
  final Color backgroundColorHighest;

  /// Text/icon color used on top of [backgroundColorHighest].
  final Color onBackgroundColorHighest;

  /// Theme overrides for the action bar widget.
  final SelectorActionBarTheme actionBarTheme;

  /// Theme overrides for the category bar widget.
  final SelectorCategoryBarTheme categoryBarTheme;

  /// Theme overrides for grid tiles.
  final SelectorGridTileTheme gridTileTheme;

  /// Theme overrides for list tiles.
  final SelectorListTileTheme listTileTheme;

  /// Theme overrides for range field tiles.
  final SelectorFieldTileTheme fieldTileTheme;

  /// Theme used for radio controls when rendered by selector widgets.
  final RadioThemeData radioTheme;

  /// Theme used for checkbox controls when rendered by selector widgets.
  final CheckboxThemeData checkboxTheme;

  /// Theme overrides for the selected chips bar.
  final SelectorChipBarTheme chipBarThemeData;

  /// Creates a copy of this theme data with the given fields replaced.
  SelectorThemeData copyWith({
    Color? selectedColor,
    Color? onSelectedColor,
    Color? backgroundColor,
    Color? onBackgroundColor,
    Color? backgroundColorHigh,
    Color? backgroundColorHighest,
    Color? onBackgroundColorHighest,
    SelectorActionBarTheme? actionBarTheme,
    SelectorCategoryBarTheme? categoryBarTheme,
    SelectorGridTileTheme? gridTileTheme,
    SelectorListTileTheme? listTileTheme,
    SelectorFieldTileTheme? fieldTileTheme,
    RadioThemeData? radioTheme,
    CheckboxThemeData? checkboxTheme,
    SelectorChipBarTheme? chipBarThemeData,
  }) {
    return SelectorThemeData.raw(
      selectedColor: selectedColor ?? this.selectedColor,
      onSelectedColor: onSelectedColor ?? this.onSelectedColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      onBackgroundColor: onBackgroundColor ?? this.onBackgroundColor,
      backgroundColorHigh: backgroundColorHigh ?? this.backgroundColorHigh,
      backgroundColorHighest:
          backgroundColorHighest ?? this.backgroundColorHighest,
      onBackgroundColorHighest:
          onBackgroundColorHighest ?? this.onBackgroundColorHighest,
      actionBarTheme: actionBarTheme ?? this.actionBarTheme,
      categoryBarTheme: categoryBarTheme ?? this.categoryBarTheme,
      gridTileTheme: gridTileTheme ?? this.gridTileTheme,
      listTileTheme: listTileTheme ?? this.listTileTheme,
      fieldTileTheme: fieldTileTheme ?? this.fieldTileTheme,
      radioTheme: radioTheme ?? this.radioTheme,
      checkboxTheme: checkboxTheme ?? this.checkboxTheme,
      chipBarThemeData: chipBarThemeData ?? this.chipBarThemeData,
    );
  }

  /// Linearly interpolates between two theme data objects.
  static SelectorThemeData? lerp(
      SelectorThemeData? a, SelectorThemeData? b, double t) {
    if (identical(a, b)) {
      return a;
    }
    return SelectorThemeData.raw(
      selectedColor: Color.lerp(a?.selectedColor, b?.selectedColor, t)!,
      onSelectedColor: Color.lerp(a?.onSelectedColor, b?.onSelectedColor, t)!,
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t)!,
      onBackgroundColor:
          Color.lerp(a?.onBackgroundColor, b?.onBackgroundColor, t)!,
      backgroundColorHigh:
          Color.lerp(a?.backgroundColorHigh, b?.backgroundColorHigh, t)!,
      backgroundColorHighest:
          Color.lerp(a?.backgroundColorHighest, b?.backgroundColorHighest, t)!,
      onBackgroundColorHighest: Color.lerp(
          a?.onBackgroundColorHighest, b?.onBackgroundColorHighest, t)!,
      actionBarTheme:
          SelectorActionBarTheme.lerp(a?.actionBarTheme, b?.actionBarTheme, t),
      categoryBarTheme: SelectorCategoryBarTheme.lerp(
          a?.categoryBarTheme, b?.categoryBarTheme, t),
      gridTileTheme:
          SelectorGridTileTheme.lerp(a?.gridTileTheme, b?.gridTileTheme, t),
      listTileTheme:
          SelectorListTileTheme.lerp(a?.listTileTheme, b?.listTileTheme, t),
      fieldTileTheme:
          SelectorFieldTileTheme.lerp(a?.fieldTileTheme, b?.fieldTileTheme, t),
      radioTheme: RadioThemeData.lerp(a?.radioTheme, b?.radioTheme, t),
      checkboxTheme:
          CheckboxThemeData.lerp(a?.checkboxTheme, b?.checkboxTheme, t),
      chipBarThemeData: SelectorChipBarTheme.lerp(
          a?.chipBarThemeData, b?.chipBarThemeData, t),
    );
  }

  @override
  int get hashCode => Object.hash(
        selectedColor,
        onSelectedColor,
        backgroundColor,
        onBackgroundColor,
        backgroundColorHigh,
        backgroundColorHighest,
        onBackgroundColorHighest,
        actionBarTheme,
        categoryBarTheme,
        gridTileTheme,
        listTileTheme,
        fieldTileTheme,
        radioTheme,
        checkboxTheme,
        chipBarThemeData,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SelectorThemeData &&
        other.selectedColor == selectedColor &&
        other.onSelectedColor == onSelectedColor &&
        other.backgroundColor == backgroundColor &&
        other.onBackgroundColor == onBackgroundColor &&
        other.backgroundColorHigh == backgroundColorHigh &&
        other.backgroundColorHighest == backgroundColorHighest &&
        other.onBackgroundColorHighest == onBackgroundColorHighest &&
        other.actionBarTheme == actionBarTheme &&
        other.categoryBarTheme == categoryBarTheme &&
        other.gridTileTheme == gridTileTheme &&
        other.listTileTheme == listTileTheme &&
        other.fieldTileTheme == fieldTileTheme &&
        other.radioTheme == radioTheme &&
        other.checkboxTheme == checkboxTheme &&
        other.chipBarThemeData == chipBarThemeData;
  }
}
