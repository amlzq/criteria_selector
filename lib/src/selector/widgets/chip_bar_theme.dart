import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../selector_theme.dart';

/// Visual variant for chips rendered by [SelectorChipBar].
@immutable
enum SelectorChipVariant {
  filled,

  outlined,
}

/// Theme configuration for [SelectorChipBar].
@immutable
class SelectorChipBarTheme with Diagnosticable {
  const SelectorChipBarTheme({
    this.color,
    this.labelStyle,
    this.selectedColor,
    this.selectedLabelStyle,
    this.variant,
    this.backgroundColor,
    this.padding,
  });

  /// Chip color used when selected.
  final Color? selectedColor;

  /// Chip color used when unselected.
  final Color? color;

  /// Label style used when unselected.
  final TextStyle? labelStyle;

  /// Label style used when selected.
  final TextStyle? selectedLabelStyle;

  /// Chip visual variant.
  final SelectorChipVariant? variant;

  /// Background color of the chip bar.
  final Color? backgroundColor;

  /// Outer padding of the chip bar.
  final EdgeInsetsGeometry? padding;

  /// Returns a copy of this theme with the given fields replaced.
  SelectorChipBarTheme copyWith({
    Color? color,
    TextStyle? labelStyle,
    Color? selectedColor,
    TextStyle? selectedLabelStyle,
    SelectorChipVariant? variant,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
  }) {
    return SelectorChipBarTheme(
      color: color ?? this.color,
      labelStyle: labelStyle ?? this.labelStyle,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedLabelStyle: selectedLabelStyle ?? this.selectedLabelStyle,
      variant: variant ?? this.variant,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
    );
  }

  static SelectorChipBarTheme of(BuildContext context) {
    return SelectorTheme.of(context).chipBarThemeData;
  }

  /// Linearly interpolates between two chip bar themes.
  static SelectorChipBarTheme lerp(
      SelectorChipBarTheme? a, SelectorChipBarTheme? b, double t) {
    if (identical(a, b) && a != null) {
      return a;
    }
    return SelectorChipBarTheme(
      color: Color.lerp(
        a?.color,
        b?.color,
        t,
      ),
      labelStyle: TextStyle.lerp(
        a?.labelStyle,
        b?.labelStyle,
        t,
      ),
      selectedColor: Color.lerp(
        a?.selectedColor,
        b?.selectedColor,
        t,
      ),
      selectedLabelStyle: TextStyle.lerp(
        a?.selectedLabelStyle,
        b?.selectedLabelStyle,
        t,
      ),
      variant: t < 0.5 ? a?.variant : b?.variant,
      backgroundColor: Color.lerp(
        a?.backgroundColor,
        b?.backgroundColor,
        t,
      ),
      padding: EdgeInsetsGeometry.lerp(
        a?.padding,
        b?.padding,
        t,
      ),
    );
  }

  @override
  int get hashCode => Object.hash(
        color,
        labelStyle,
        selectedColor,
        selectedLabelStyle,
        variant,
        backgroundColor,
        padding,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SelectorChipBarTheme &&
        other.color == color &&
        other.labelStyle == labelStyle &&
        other.selectedColor == selectedColor &&
        other.selectedLabelStyle == selectedLabelStyle &&
        other.variant == variant &&
        other.backgroundColor == backgroundColor &&
        other.padding == padding;
  }
}
