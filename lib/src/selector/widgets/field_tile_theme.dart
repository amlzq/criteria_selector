import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../selector_theme.dart';

/// Visual variant for [SelectorFieldTile].
@immutable
enum SelectorFieldTileVariant {
  filled,

  outlined,
}

/// Theme configuration for [SelectorFieldTile].
@immutable
class SelectorFieldTileTheme with Diagnosticable {
  const SelectorFieldTileTheme({
    this.selectedColor,
    this.textColor,
    this.labelStyle,
    this.sublabelStyle,
    this.variant,
    this.tileColor,
    this.selectedTileColor,
  });

  /// Overrides the default value of [SelectorFieldTile.selectedColor].
  final Color? selectedColor;

  /// Overrides the default value of [SelectorFieldTile.textColor].
  final Color? textColor;

  /// Overrides the default value of [SelectorFieldTile.labelStyle].
  final TextStyle? labelStyle;

  /// Overrides the default value of [SelectorFieldTile.sublabelStyle].
  final TextStyle? sublabelStyle;

  /// Overrides the default value of [SelectorFieldTile.variant].
  final SelectorFieldTileVariant? variant;

  /// Overrides the default value of [SelectorFieldTile.tileColor].
  final Color? tileColor;

  /// Overrides the default value of [SelectorFieldTile.selectedTileColor].
  final Color? selectedTileColor;

  /// Returns a copy of this theme with the given fields replaced.
  SelectorFieldTileTheme copyWith({
    Color? textColor,
    TextStyle? labelStyle,
    TextStyle? sublabelStyle,
    Color? selectedColor,
    SelectorFieldTileVariant? variant,
    Color? tileColor,
    Color? selectedTileColor,
  }) {
    return SelectorFieldTileTheme(
      textColor: textColor ?? this.textColor,
      labelStyle: labelStyle ?? this.labelStyle,
      sublabelStyle: sublabelStyle ?? this.sublabelStyle,
      selectedColor: selectedColor ?? this.selectedColor,
      variant: variant ?? this.variant,
      tileColor: tileColor ?? this.tileColor,
      selectedTileColor: selectedTileColor ?? this.selectedTileColor,
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
      variant: t < 0.5 ? a?.variant : b?.variant,
      tileColor: Color.lerp(
        a?.tileColor,
        b?.tileColor,
        t,
      ),
      selectedTileColor: Color.lerp(
        a?.selectedTileColor,
        b?.selectedTileColor,
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
        variant,
        tileColor,
        selectedTileColor,
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
        other.selectedColor == selectedColor &&
        other.variant == variant &&
        other.tileColor == tileColor &&
        other.selectedTileColor == selectedTileColor;
  }
}
