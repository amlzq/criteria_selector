import 'package:flutter/material.dart';

import 'dropselect_overlay_style.dart';
import 'selector/selector_theme_data.dart';

/// Theme extension for [DropselectTabBar].
///
/// Add this extension to your app theme to override default tab bar visuals
/// and overlay styles.
@immutable
class DropselectTabBarTheme extends ThemeExtension<DropselectTabBarTheme> {
  const DropselectTabBarTheme({
    this.height,
    this.backgroundColor,
    this.labelColor,
    this.labelStyle,
    this.unselectedLabelColor,
    this.unselectedLabelStyle,
    this.indicator,
    this.unselectedIndicator,
    this.overlayStyle,
    this.selectorTheme,
  });

  /// Overrides the default value of [DropselectTabBar.height].
  final double? height;

  /// Overrides the default value of [DropselectTabBar.backgroundColor].
  final Color? backgroundColor;

  /// Overrides the default selected tab label color.
  final Color? labelColor;

  /// Overrides the default selected tab label style.
  final TextStyle? labelStyle;

  /// Overrides the default unselected tab label color.
  final Color? unselectedLabelColor;

  /// Overrides the default unselected tab label style.
  final TextStyle? unselectedLabelStyle;

  /// Default indicator for the selected state.
  final Widget? indicator;

  /// Default indicator for the unselected state.
  final Widget? unselectedIndicator;

  /// Default overlay style applied to [DropselectOverlay].
  final DropselectOverlayStyle? overlayStyle;

  /// Default theme overrides applied to selector widgets inside the overlay.
  final SelectorThemeData? selectorTheme;

  @override
  DropselectTabBarTheme copyWith({
    double? height,
    Color? backgroundColor,
    Color? labelColor,
    TextStyle? labelStyle,
    Color? unselectedLabelColor,
    TextStyle? unselectedLabelStyle,
    Widget? indicator,
    Widget? unselectedIndicator,
    DropselectOverlayStyle? overlayStyle,
    SelectorThemeData? selectorTheme,
  }) {
    return DropselectTabBarTheme(
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      labelColor: labelColor ?? this.labelColor,
      labelStyle: labelStyle ?? this.labelStyle,
      unselectedLabelColor: unselectedLabelColor ?? this.unselectedLabelColor,
      unselectedLabelStyle: unselectedLabelStyle ?? this.unselectedLabelStyle,
      indicator: indicator ?? this.indicator,
      unselectedIndicator: unselectedIndicator ?? this.unselectedIndicator,
      overlayStyle: overlayStyle ?? this.overlayStyle,
      selectorTheme: selectorTheme ?? this.selectorTheme,
    );
  }

  static DropselectTabBarTheme? maybeOf(BuildContext context) {
    return Theme.of(context).extension<DropselectTabBarTheme>();
  }

  @override
  int get hashCode => Object.hash(
        height,
        backgroundColor,
        labelColor,
        labelStyle,
        unselectedLabelColor,
        unselectedLabelStyle,
        indicator,
        unselectedIndicator,
        overlayStyle,
        selectorTheme,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DropselectTabBarTheme &&
        other.height == height &&
        other.backgroundColor == backgroundColor &&
        other.labelColor == labelColor &&
        other.labelStyle == labelStyle &&
        other.unselectedLabelColor == unselectedLabelColor &&
        other.unselectedLabelStyle == unselectedLabelStyle &&
        other.indicator == indicator &&
        other.unselectedIndicator == unselectedIndicator &&
        other.overlayStyle == overlayStyle &&
        other.selectorTheme == selectorTheme;
  }

  @override
  ThemeExtension<DropselectTabBarTheme> lerp(
      covariant ThemeExtension<DropselectTabBarTheme>? other, double t) {
    if (other is! DropselectTabBarTheme) {
      return this;
    }
    return DropselectTabBarTheme(
      height: height != null && other.height != null
          ? height! + (other.height! - height!) * t
          : t < 0.5
              ? height
              : other.height,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      labelColor: Color.lerp(labelColor, other.labelColor, t),
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t),
      unselectedLabelColor:
          Color.lerp(unselectedLabelColor, other.unselectedLabelColor, t),
      unselectedLabelStyle:
          TextStyle.lerp(unselectedLabelStyle, other.unselectedLabelStyle, t),
      indicator: indicator,
      unselectedIndicator: unselectedIndicator,
      overlayStyle: overlayStyle,
      selectorTheme:
          SelectorThemeData.lerp(selectorTheme, other.selectorTheme, t),
    );
  }
}
