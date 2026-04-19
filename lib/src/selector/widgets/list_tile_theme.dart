import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../selector_theme.dart';

/// Theme configuration for [SelectorListTile], including toggle builders.
@immutable
class SelectorListTileTheme with Diagnosticable {
  const SelectorListTileTheme({
    this.selectedColor,
    this.textColor,
    this.tileColor,
    this.selectedTileColor,
    this.labelStyle,
    this.sublabelStyle,
    this.radioBuilder,
    this.checkboxBuilder,
  });

  /// Color used to indicate selection (e.g. selected text or badge).
  final Color? selectedColor;

  /// Text color used when unselected.
  final Color? textColor;

  /// Background color used when unselected.
  final Color? tileColor;

  /// Background color used when selected.
  final Color? selectedTileColor;

  /// Label style used by list tiles.
  final TextStyle? labelStyle;

  /// Sublabel style used by list tiles.
  final TextStyle? sublabelStyle;

  /// Builds a radio widget for [SelectorRadioListTile].
  final ToggleWidgetBuilder? radioBuilder;

  /// Builds a checkbox widget for [SelectorCheckboxListTile].
  final ToggleWidgetBuilder? checkboxBuilder;

  /// Returns a copy of this theme with the given fields replaced.
  SelectorListTileTheme copyWith({
    Color? selectedColor,
    Color? textColor,
    Color? tileColor,
    Color? selectedTileColor,
    TextStyle? labelStyle,
    TextStyle? sublabelStyle,
    ToggleWidgetBuilder? radioBuilder,
    ToggleWidgetBuilder? checkboxBuilder,
  }) {
    return SelectorListTileTheme(
      selectedColor: selectedColor ?? this.selectedColor,
      textColor: textColor ?? this.textColor,
      tileColor: tileColor ?? this.tileColor,
      selectedTileColor: selectedTileColor ?? this.selectedTileColor,
      labelStyle: labelStyle ?? this.labelStyle,
      sublabelStyle: sublabelStyle ?? this.sublabelStyle,
      radioBuilder: radioBuilder ?? this.radioBuilder,
      checkboxBuilder: checkboxBuilder ?? this.checkboxBuilder,
    );
  }

  static SelectorListTileTheme of(BuildContext context) {
    return SelectorTheme.of(context).listTileTheme;
  }

  /// Linearly interpolates between two list tile themes.
  static SelectorListTileTheme lerp(
      SelectorListTileTheme? a, SelectorListTileTheme? b, double t) {
    if (identical(a, b) && a != null) {
      return a;
    }
    return SelectorListTileTheme(
      selectedColor: Color.lerp(a?.selectedColor, b?.selectedColor, t),
      textColor: Color.lerp(a?.textColor, b?.textColor, t),
      tileColor: Color.lerp(a?.tileColor, b?.tileColor, t),
      selectedTileColor:
          Color.lerp(a?.selectedTileColor, b?.selectedTileColor, t),
      labelStyle: TextStyle.lerp(a?.labelStyle, b?.labelStyle, t),
      sublabelStyle: TextStyle.lerp(a?.sublabelStyle, b?.sublabelStyle, t),
      radioBuilder: t < 0.5 ? a?.radioBuilder : b?.radioBuilder,
      checkboxBuilder: t < 0.5 ? a?.checkboxBuilder : b?.checkboxBuilder,
    );
  }

  @override
  int get hashCode => Object.hash(
        selectedColor,
        textColor,
        tileColor,
        selectedTileColor,
        labelStyle,
        sublabelStyle,
        radioBuilder,
        checkboxBuilder,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SelectorListTileTheme &&
        other.selectedColor == selectedColor &&
        other.textColor == textColor &&
        other.tileColor == tileColor &&
        other.selectedTileColor == selectedTileColor &&
        other.labelStyle == labelStyle &&
        other.sublabelStyle == sublabelStyle &&
        other.radioBuilder == radioBuilder &&
        other.checkboxBuilder == checkboxBuilder;
  }
}
