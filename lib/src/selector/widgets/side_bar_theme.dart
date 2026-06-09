import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../selector_theme.dart';
import 'side_bar.dart';

/// Defines a theme for [SelectorSideBar] widgets.
@immutable
class SelectorSideBarTheme with Diagnosticable {
  const SelectorSideBarTheme({
    this.backgroundColor,
    this.width,
    this.padding,
    this.selectedColor,
    this.labelStyle,
    this.selectedLabelStyle,
    this.selectedTileColor,
    this.indicatorColor,
    this.indicatorHeight,
    this.indicatorPadding,
    this.indicatorAnimationDuration,
  });

  /// Overrides the default value of [SelectorSideBar.selectedColor].
  final Color? backgroundColor;

  /// Overrides the default value of [SelectorSideBar.width].
  final double? width;

  /// Overrides the default value of [SelectorSideBar.padding].
  final EdgeInsetsGeometry? padding;

  /// Overrides the default value of [SelectorSideBar.selectedColor].
  final Color? selectedColor;

  /// Overrides the default value of [SelectorSideBar.labelStyle].
  final TextStyle? labelStyle;

  /// Overrides the default value of [SelectorSideBar.selectedLabelStyle].
  final TextStyle? selectedLabelStyle;

  /// Overrides the default value of [SelectorSideBar.selectedTileColor].
  final Color? selectedTileColor;

  /// Overrides the default value of [SelectorSideBar.indicatorColor].
  final Color? indicatorColor;

  /// Overrides the default value of [SelectorSideBar.indicatorHeight].
  final double? indicatorHeight;

  /// Overrides the default value of [SelectorSideBar.indicatorPadding].
  final EdgeInsetsGeometry? indicatorPadding;

  /// Overrides the default value of [SelectorSideBar.indicatorAnimationDuration].
  final Duration? indicatorAnimationDuration;

  /// Returns a copy of this theme with the given fields replaced.
  SelectorSideBarTheme copyWith({
    Color? backgroundColor,
    double? width,
    EdgeInsetsGeometry? padding,
    Color? selectedColor,
    TextStyle? labelStyle,
    TextStyle? selectedLabelStyle,
    Color? selectedTileColor,
    Color? indicatorColor,
    double? indicatorHeight,
    EdgeInsetsGeometry? indicatorPadding,
    Duration? indicatorAnimationDuration,
  }) {
    return SelectorSideBarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      width: width ?? this.width,
      padding: padding ?? this.padding,
      selectedColor: selectedColor ?? this.selectedColor,
      labelStyle: labelStyle ?? this.labelStyle,
      selectedLabelStyle: selectedLabelStyle ?? this.selectedLabelStyle,
      selectedTileColor: selectedTileColor ?? this.selectedTileColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorHeight: indicatorHeight ?? this.indicatorHeight,
      indicatorPadding: indicatorPadding ?? this.indicatorPadding,
      indicatorAnimationDuration:
          indicatorAnimationDuration ?? this.indicatorAnimationDuration,
    );
  }

  static SelectorSideBarTheme of(BuildContext context) {
    return SelectorTheme.of(context).sideBarTheme;
  }

  /// Linearly interpolates between two category bar themes.
  static SelectorSideBarTheme lerp(
      SelectorSideBarTheme? a, SelectorSideBarTheme? b, double t) {
    if (identical(a, b) && a != null) {
      return a;
    }
    return SelectorSideBarTheme(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      width: lerpDouble(a?.width, b?.width, t),
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
    );
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        width,
        padding,
        selectedColor,
        labelStyle,
        selectedLabelStyle,
        selectedTileColor,
        indicatorColor,
        indicatorHeight,
        indicatorPadding,
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
    return other is SelectorSideBarTheme &&
        other.backgroundColor == backgroundColor &&
        other.width == width &&
        other.padding == padding &&
        other.selectedColor == selectedColor &&
        other.labelStyle == labelStyle &&
        other.selectedLabelStyle == selectedLabelStyle &&
        other.selectedTileColor == selectedTileColor &&
        other.indicatorColor == indicatorColor &&
        other.indicatorHeight == indicatorHeight &&
        other.indicatorPadding == indicatorPadding &&
        other.indicatorAnimationDuration == indicatorAnimationDuration;
  }
}
