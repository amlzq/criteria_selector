import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../selector_theme.dart';

/// Indicator sizing mode for [SelectorCategoryBarTheme].
@immutable
enum SelectorCategoryBarIndicatorSize {
  tab,
  label,
}

/// Theme configuration for [SelectorCategoryBar].
@immutable
class SelectorCategoryBarTheme with Diagnosticable {
  const SelectorCategoryBarTheme({
    this.backgroundColor,
    this.padding,
    this.selectedColor,
    this.labelStyle,
    this.unselectedLabelTextStyle,
    this.indicatorColor,
    this.indicatorHeight,
    this.indicatorPadding,
    this.indicatorSize,
    this.indicatorAnimationDuration,
  });

  /// Background color of the category bar.
  final Color? backgroundColor;

  /// Outer padding of the bar.
  final EdgeInsetsGeometry? padding;

  /// Color used to indicate the selected category.
  final Color? selectedColor;

  /// Text style used for the selected category label.
  final TextStyle? labelStyle;

  /// Text style used for unselected category labels.
  final TextStyle? unselectedLabelTextStyle;

  /// Color of the selection indicator.
  final Color? indicatorColor;

  /// Height of the selection indicator.
  final double? indicatorHeight;

  /// Padding around the indicator.
  final EdgeInsetsGeometry? indicatorPadding;

  /// Controls whether indicator width matches the tab or the label.
  final SelectorCategoryBarIndicatorSize? indicatorSize;

  /// Animation duration for indicator width changes.
  final Duration? indicatorAnimationDuration;

  /// Returns a copy of this theme with the given fields replaced.
  SelectorCategoryBarTheme copyWith({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    Color? selectedColor,
    TextStyle? labelStyle,
    TextStyle? unselectedLabelTextStyle,
    Color? indicatorColor,
    double? indicatorHeight,
    EdgeInsetsGeometry? indicatorPadding,
    SelectorCategoryBarIndicatorSize? indicatorSize,
    Duration? indicatorAnimationDuration,
  }) {
    return SelectorCategoryBarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      selectedColor: selectedColor ?? this.selectedColor,
      labelStyle: labelStyle ?? this.labelStyle,
      unselectedLabelTextStyle:
          unselectedLabelTextStyle ?? this.unselectedLabelTextStyle,
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
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      selectedColor: Color.lerp(a?.selectedColor, b?.selectedColor, t),
      labelStyle: TextStyle.lerp(a?.labelStyle, b?.labelStyle, t),
      unselectedLabelTextStyle: TextStyle.lerp(
        a?.unselectedLabelTextStyle,
        b?.unselectedLabelTextStyle,
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
        unselectedLabelTextStyle,
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
        other.padding == padding &&
        other.selectedColor == selectedColor &&
        other.labelStyle == labelStyle &&
        other.unselectedLabelTextStyle == unselectedLabelTextStyle &&
        other.indicatorColor == indicatorColor &&
        other.indicatorHeight == indicatorHeight &&
        other.indicatorPadding == indicatorPadding &&
        other.indicatorSize == indicatorSize &&
        other.indicatorAnimationDuration == indicatorAnimationDuration;
  }
}
