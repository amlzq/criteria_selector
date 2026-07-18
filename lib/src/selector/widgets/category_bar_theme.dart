import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../selector_theme.dart';

/// Indicator sizing mode for [SelectorCategoryBarTheme].
///
/// Deprecated: use SelectorTabBarIndicatorSize for horizontal bars.
@Deprecated('Use SelectorTabBarIndicatorSize (horizontal).')
enum SelectorCategoryBarIndicatorSize {
  tab,
  label,
}

/// Theme configuration for [SelectorCategoryBar].
///
/// Deprecated:
/// - Use SelectorTabBarTheme for horizontal bars.
/// - Use SelectorSideBarTheme for vertical bars.
@immutable
@Deprecated(
    'Use SelectorTabBarTheme (horizontal) or SelectorSideBarTheme (vertical).')
class SelectorCategoryBarTheme with Diagnosticable {
  const SelectorCategoryBarTheme({
    this.backgroundColor,
    this.size,
    this.padding,
    this.selectedColor,
    this.labelStyle,
    this.selectedLabelStyle,
    this.selectedTileColor,
    this.indicatorColor,
    this.indicatorHeight,
    this.indicatorPadding,
    this.indicatorSize,
    this.indicatorAnimationDuration,
  });

  /// Overrides the default value of [SelectorCategoryBar.selectedColor].
  final Color? backgroundColor;

  /// Overrides the default value of [SelectorCategoryBar.size].
  final double? size;

  /// Overrides the default value of [SelectorCategoryBar.padding].
  final EdgeInsetsGeometry? padding;

  /// Overrides the default value of [SelectorCategoryBar.selectedColor].
  final Color? selectedColor;

  /// Overrides the default value of [SelectorCategoryBar.labelStyle].
  final TextStyle? labelStyle;

  /// Overrides the default value of [SelectorCategoryBar.selectedLabelStyle].
  final TextStyle? selectedLabelStyle;

  /// Overrides the default value of [SelectorCategoryBar.selectedTileColor].
  final Color? selectedTileColor;

  /// Overrides the default value of [SelectorCategoryBar.indicatorColor].
  final Color? indicatorColor;

  /// Overrides the default value of [SelectorCategoryBar.indicatorHeight].
  final double? indicatorHeight;

  /// Overrides the default value of [SelectorCategoryBar.indicatorPadding].
  final EdgeInsetsGeometry? indicatorPadding;

  /// Overrides the default value of [SelectorCategoryBar.indicatorSize].
  final SelectorCategoryBarIndicatorSize? indicatorSize;

  /// Overrides the default value of [SelectorCategoryBar.indicatorAnimationDuration].
  final Duration? indicatorAnimationDuration;

  /// Returns a copy of this theme with the given fields replaced.
  SelectorCategoryBarTheme copyWith({
    Color? backgroundColor,
    double? size,
    EdgeInsetsGeometry? padding,
    Color? selectedColor,
    TextStyle? labelStyle,
    TextStyle? selectedLabelStyle,
    Color? selectedTileColor,
    Color? indicatorColor,
    double? indicatorHeight,
    EdgeInsetsGeometry? indicatorPadding,
    SelectorCategoryBarIndicatorSize? indicatorSize,
    Duration? indicatorAnimationDuration,
  }) {
    return SelectorCategoryBarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      size: size ?? this.size,
      padding: padding ?? this.padding,
      selectedColor: selectedColor ?? this.selectedColor,
      labelStyle: labelStyle ?? this.labelStyle,
      selectedLabelStyle: selectedLabelStyle ?? this.selectedLabelStyle,
      selectedTileColor: selectedTileColor ?? this.selectedTileColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorHeight: indicatorHeight ?? this.indicatorHeight,
      indicatorPadding: indicatorPadding ?? this.indicatorPadding,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      indicatorAnimationDuration:
          indicatorAnimationDuration ?? this.indicatorAnimationDuration,
    );
  }

  static SelectorCategoryBarTheme of(BuildContext context) {
    return SelectorTheme.of(context).categoryBarTheme;
  }

  /// Linearly interpolates between two category bar themes.
  static SelectorCategoryBarTheme lerp(
      SelectorCategoryBarTheme? a, SelectorCategoryBarTheme? b, double t) {
    if (identical(a, b) && a != null) {
      return a;
    }
    return SelectorCategoryBarTheme(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      size: lerpDouble(a?.size, b?.size, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      selectedColor: Color.lerp(a?.selectedColor, b?.selectedColor, t),
      labelStyle: TextStyle.lerp(a?.labelStyle, b?.labelStyle, t),
      selectedLabelStyle: TextStyle.lerp(
        a?.selectedLabelStyle,
        b?.selectedLabelStyle,
        t,
      ),
      selectedTileColor: Color.lerp(
        a?.selectedTileColor,
        b?.selectedTileColor,
        t,
      ),
      indicatorColor: Color.lerp(a?.indicatorColor, b?.indicatorColor, t),
      indicatorHeight: lerpDouble(a?.indicatorHeight, b?.indicatorHeight, t),
      indicatorPadding: EdgeInsetsGeometry.lerp(
        a?.indicatorPadding,
        b?.indicatorPadding,
        t,
      ),
      indicatorSize: t < 0.5 ? a?.indicatorSize : b?.indicatorSize,
    );
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        size,
        padding,
        selectedColor,
        labelStyle,
        selectedLabelStyle,
        selectedTileColor,
        indicatorColor,
        indicatorHeight,
        indicatorPadding,
        indicatorSize,
        indicatorAnimationDuration,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SelectorCategoryBarTheme &&
        other.backgroundColor == backgroundColor &&
        other.size == size &&
        other.padding == padding &&
        other.selectedColor == selectedColor &&
        other.labelStyle == labelStyle &&
        other.selectedLabelStyle == selectedLabelStyle &&
        other.selectedTileColor == selectedTileColor &&
        other.indicatorColor == indicatorColor &&
        other.indicatorHeight == indicatorHeight &&
        other.indicatorPadding == indicatorPadding &&
        other.indicatorSize == indicatorSize &&
        other.indicatorAnimationDuration == indicatorAnimationDuration;
  }
}
