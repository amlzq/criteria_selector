import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../selector_theme.dart';
import 'tab_bar.dart';

/// Defines a theme for [SelectorTabBar] widgets.
@immutable
class SelectorTabBarTheme with Diagnosticable {
  const SelectorTabBarTheme({
    this.backgroundColor,
    this.padding,
    this.selectedColor,
    this.labelStyle,
    this.selectedLabelStyle,
    this.indicatorColor,
    this.indicatorHeight,
    this.indicatorPadding,
    this.indicatorSize,
    this.indicatorAnimationDuration,
  });

  /// Overrides the default value of [SelectorTabBar.selectedColor].
  final Color? backgroundColor;

  /// Overrides the default value of [SelectorTabBar.padding].
  final EdgeInsetsGeometry? padding;

  /// Overrides the default value of [SelectorTabBar.selectedColor].
  final Color? selectedColor;

  /// Overrides the default value of [SelectorTabBar.labelStyle].
  final TextStyle? labelStyle;

  /// Overrides the default value of [SelectorTabBar.selectedLabelStyle].
  final TextStyle? selectedLabelStyle;

  /// Overrides the default value of [SelectorTabBar.indicatorColor].
  final Color? indicatorColor;

  /// Overrides the default value of [SelectorTabBar.indicatorHeight].
  final double? indicatorHeight;

  /// Overrides the default value of [SelectorTabBar.indicatorPadding].
  final EdgeInsetsGeometry? indicatorPadding;

  /// Overrides the default value of [SelectorTabBar.indicatorSize].
  final SelectorTabBarIndicatorSize? indicatorSize;

  /// Overrides the default value of [SelectorTabBar.indicatorAnimationDuration].
  final Duration? indicatorAnimationDuration;

  /// Returns a copy of this theme with the given fields replaced.
  SelectorTabBarTheme copyWith({
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
    SelectorTabBarIndicatorSize? indicatorSize,
    Duration? indicatorAnimationDuration,
  }) {
    return SelectorTabBarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      selectedColor: selectedColor ?? this.selectedColor,
      labelStyle: labelStyle ?? this.labelStyle,
      selectedLabelStyle: selectedLabelStyle ?? this.selectedLabelStyle,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorHeight: indicatorHeight ?? this.indicatorHeight,
      indicatorPadding: indicatorPadding ?? this.indicatorPadding,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      indicatorAnimationDuration:
          indicatorAnimationDuration ?? this.indicatorAnimationDuration,
    );
  }

  static SelectorTabBarTheme of(BuildContext context) {
    return SelectorTheme.of(context).tabBarTheme;
  }

  /// Linearly interpolates between two tab bar themes.
  static SelectorTabBarTheme lerp(
      SelectorTabBarTheme? a, SelectorTabBarTheme? b, double t) {
    if (identical(a, b) && a != null) {
      return a;
    }
    return SelectorTabBarTheme(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      selectedColor: Color.lerp(a?.selectedColor, b?.selectedColor, t),
      labelStyle: TextStyle.lerp(a?.labelStyle, b?.labelStyle, t),
      selectedLabelStyle: TextStyle.lerp(
        a?.selectedLabelStyle,
        b?.selectedLabelStyle,
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
        padding,
        selectedColor,
        labelStyle,
        selectedLabelStyle,
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
    return other is SelectorTabBarTheme &&
        other.backgroundColor == backgroundColor &&
        other.padding == padding &&
        other.selectedColor == selectedColor &&
        other.labelStyle == labelStyle &&
        other.selectedLabelStyle == selectedLabelStyle &&
        other.indicatorColor == indicatorColor &&
        other.indicatorHeight == indicatorHeight &&
        other.indicatorPadding == indicatorPadding &&
        other.indicatorSize == indicatorSize &&
        other.indicatorAnimationDuration == indicatorAnimationDuration;
  }
}
