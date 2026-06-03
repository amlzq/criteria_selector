import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../selector_theme.dart';

/// Theme configuration for [SelectorFieldTile].
@immutable
class SelectorFieldTileTheme with Diagnosticable {
  const SelectorFieldTileTheme({
    this.selectedColor,
    this.textColor,
    this.labelStyle,
    this.sublabelStyle,
  });

  /// Overrides the default value of [SelectorFieldTile.selectedColor].
  final Color? selectedColor;

  /// Overrides the default value of [SelectorFieldTile.textColor].
  final Color? textColor;

  /// Overrides the default value of [SelectorFieldTile.labelStyle].
  final TextStyle? labelStyle;

  /// Overrides the default value of [SelectorFieldTile.sublabelStyle].
  final TextStyle? sublabelStyle;

  /// Returns a copy of this theme with the given fields replaced.
  SelectorFieldTileTheme copyWith({
    Color? textColor,
    TextStyle? labelStyle,
    TextStyle? sublabelStyle,
    Color? selectedColor,
  }) {
    return SelectorFieldTileTheme(
      textColor: textColor ?? this.textColor,
      labelStyle: labelStyle ?? this.labelStyle,
      sublabelStyle: sublabelStyle ?? this.sublabelStyle,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  static SelectorFieldTileTheme of(BuildContext context) {
    return SelectorTheme.of(context).fieldTileTheme;
  }

  /// Linearly interpolates between two field tile themes.
  static SelectorFieldTileTheme lerp(
      SelectorFieldTileTheme? a, SelectorFieldTileTheme? b, double t) {
    if (identical(a, b) && a != null) {
      return a;
    }
    return SelectorFieldTileTheme(
      selectedColor: Color.lerp(
        a?.selectedColor,
        b?.selectedColor,
        t,
      ),
      textColor: Color.lerp(
        a?.textColor,
        b?.textColor,
        t,
      ),
      labelStyle: TextStyle.lerp(
        a?.labelStyle,
        b?.labelStyle,
        t,
      ),
      sublabelStyle: TextStyle.lerp(
        a?.sublabelStyle,
        b?.sublabelStyle,
        t,
      ),
    );
  }

  @override
  int get hashCode => Object.hash(
        textColor,
        labelStyle,
        sublabelStyle,
        selectedColor,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SelectorFieldTileTheme &&
        other.textColor == textColor &&
        other.labelStyle == labelStyle &&
        other.sublabelStyle == sublabelStyle &&
        other.selectedColor == selectedColor;
  }
}
