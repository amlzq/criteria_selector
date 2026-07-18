import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../selector_theme.dart';

/// Visual variant for [SelectorGridTile].
enum SelectorGridTileVariant {
  filled,

  outlined,
}

/// Theme configuration for [SelectorGridTile].
@immutable
class SelectorGridTileTheme with Diagnosticable {
  const SelectorGridTileTheme({
    this.selectedColor,
    this.textColor,
    this.labelStyle,
    this.sublabelStyle,
    this.variant,
    this.tileColor,
    this.selectedTileColor,
  });

  /// Overrides the default value of [SelectorGridTile.selectedColor].
  final Color? selectedColor;

  /// Overrides the default value of [SelectorGridTile.textColor].
  final Color? textColor;

  /// Overrides the default value of [SelectorGridTile.labelStyle].
  final TextStyle? labelStyle;

  /// Overrides the default value of [SelectorGridTile.sublabelStyle].
  final TextStyle? sublabelStyle;

  /// Overrides the default value of [SelectorGridTile.variant].
  final SelectorGridTileVariant? variant;

  /// Overrides the default value of [SelectorGridTile.tileColor].
  final Color? tileColor;

  /// Overrides the default value of [SelectorGridTile.selectedTileColor].
  final Color? selectedTileColor;

  /// Returns a copy of this theme with the given fields replaced.
  SelectorGridTileTheme copyWith({
    Color? selectedColor,
    Color? textColor,
    TextStyle? labelStyle,
    TextStyle? sublabelStyle,
    SelectorGridTileVariant? variant,
    Color? tileColor,
    Color? selectedTileColor,
  }) {
    return SelectorGridTileTheme(
      selectedColor: selectedColor ?? this.selectedColor,
      textColor: textColor ?? this.textColor,
      labelStyle: labelStyle ?? this.labelStyle,
      sublabelStyle: sublabelStyle ?? this.sublabelStyle,
      variant: variant ?? this.variant,
      tileColor: tileColor ?? this.tileColor,
      selectedTileColor: selectedTileColor ?? this.selectedTileColor,
    );
  }

  static SelectorGridTileTheme of(BuildContext context) {
    return SelectorTheme.of(context).gridTileTheme;
  }

  /// Linearly interpolates between two grid tile themes.
  static SelectorGridTileTheme lerp(
      SelectorGridTileTheme? a, SelectorGridTileTheme? b, double t) {
    if (identical(a, b) && a != null) {
      return a;
    }
    return SelectorGridTileTheme(
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
        selectedColor,
        textColor,
        labelStyle,
        sublabelStyle,
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
    return other is SelectorGridTileTheme &&
        other.selectedColor == selectedColor &&
        other.textColor == textColor &&
        other.labelStyle == labelStyle &&
        other.sublabelStyle == sublabelStyle &&
        other.variant == variant &&
        other.tileColor == tileColor &&
        other.selectedTileColor == selectedTileColor;
  }
}
