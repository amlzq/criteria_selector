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
    this.backgroundColor,
    this.padding,
    this.variant,
    this.chipColor,
    this.selectedChipColor,
    this.labelStyle,
    this.selectedLabelStyle,
  });

  /// Overrides the default value of [SelectorChipBar.selectedColor].
  final Color? backgroundColor;

  /// Overrides the default value of [SelectorChipBar.padding].
  final EdgeInsetsGeometry? padding;

  /// Overrides the default value of [SelectorChipBar.variant].
  final SelectorChipVariant? variant;

  /// Overrides the default value of [SelectorChipBar.chipColor].
  final Color? chipColor;

  /// Overrides the default value of [SelectorChipBar.selectedChipColor].
  final Color? selectedChipColor;

  /// Overrides the default value of [SelectorChipBar.labelStyle].
  final TextStyle? labelStyle;

  /// Overrides the default value of [SelectorChipBar.selectedLabelStyle].
  final TextStyle? selectedLabelStyle;

  /// Returns a copy of this theme with the given fields replaced.
  SelectorChipBarTheme copyWith({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    SelectorChipVariant? variant,
    Color? chipColor,
    Color? selectedChipColor,
    TextStyle? labelStyle,
    TextStyle? selectedLabelStyle,
  }) {
    return SelectorChipBarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      variant: variant ?? this.variant,
      chipColor: chipColor ?? this.chipColor,
      selectedChipColor: selectedChipColor ?? this.selectedChipColor,
      labelStyle: labelStyle ?? this.labelStyle,
      selectedLabelStyle: selectedLabelStyle ?? this.selectedLabelStyle,
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
      variant: t < 0.5 ? a?.variant : b?.variant,
      chipColor: Color.lerp(
        a?.chipColor,
        b?.chipColor,
        t,
      ),
      selectedChipColor: Color.lerp(
        a?.selectedChipColor,
        b?.selectedChipColor,
        t,
      ),
      labelStyle: TextStyle.lerp(
        a?.labelStyle,
        b?.labelStyle,
        t,
      ),
      selectedLabelStyle: TextStyle.lerp(
        a?.selectedLabelStyle,
        b?.selectedLabelStyle,
        t,
      ),
    );
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        padding,
        variant,
        chipColor,
        selectedChipColor,
        labelStyle,
        selectedLabelStyle,
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
        other.backgroundColor == backgroundColor &&
        other.variant == variant &&
        other.padding == padding &&
        other.chipColor == chipColor &&
        other.selectedChipColor == selectedChipColor &&
        other.labelStyle == labelStyle &&
        other.selectedLabelStyle == selectedLabelStyle;
  }
}
