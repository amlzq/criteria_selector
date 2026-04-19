import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../selector_theme.dart';

/// Visual variant for [SelectorGridTile].
@immutable
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
  });

  /// Color used to indicate selection.
  final Color? selectedColor;

  /// Text color used when unselected.
  final Color? textColor;

  /// Label style used by the tile.
  final TextStyle? labelStyle;

  /// Sublabel style used by the tile.
  final TextStyle? sublabelStyle;

  /// Visual variant for the tile.
  final SelectorGridTileVariant? variant;

  /// Returns a copy of this theme with the given fields replaced.
  SelectorGridTileTheme copyWith({
    Color? selectedColor,
    Color? textColor,
    TextStyle? labelStyle,
    TextStyle? sublabelStyle,
    SelectorGridTileVariant? variant,
  }) {
    return SelectorGridTileTheme(
      selectedColor: selectedColor ?? this.selectedColor,
      textColor: textColor ?? this.textColor,
      labelStyle: labelStyle ?? this.labelStyle,
      sublabelStyle: sublabelStyle ?? this.sublabelStyle,
      variant: variant ?? this.variant,
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
    );
  }

  @override
  int get hashCode => Object.hash(
        selectedColor,
        textColor,
        labelStyle,
        sublabelStyle,
        variant,
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
        other.variant == variant;
  }
}
