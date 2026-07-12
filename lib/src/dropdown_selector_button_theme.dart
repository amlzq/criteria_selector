import 'package:flutter/material.dart';

import 'dropdown_overlay_style.dart';
import 'selector/selector_theme_data.dart';

/// Theme extension for [DropdownSelectorButton].
///
/// Add this extension to your app theme to override the default visuals of the
/// three button variants (elevated / filled / outlined) and the overlay/selector
/// styles used when the panel is opened.
@immutable
class DropdownSelectorButtonTheme
    extends ThemeExtension<DropdownSelectorButtonTheme> {
  const DropdownSelectorButtonTheme({
    this.backgroundColor,
    this.foregroundColor,
    this.overlayColor,
    this.shadowColor,
    this.surfaceTintColor,
    this.side,
    this.shape,
    this.textStyle,
    this.iconColor,
    this.padding,
    this.elevation,
    this.overlayStyle,
    this.selectorTheme,
  });

  /// Overrides the default value of the button background color.
  final Color? backgroundColor;

  /// Overrides the default value of the button foreground (label/icon) color.
  final Color? foregroundColor;

  /// Splash/highlight color used on press/hover.
  final Color? overlayColor;

  /// Overrides the default value of [Material.shadowColor].
  final Color? shadowColor;

  /// Overrides the default value of [Material.surfaceTintColor].
  final Color? surfaceTintColor;

  /// Border used by the button (mainly relevant for the outlined variant).
  final BorderSide? side;

  /// Shape of the button. The [side] is merged into it automatically.
  final OutlinedBorder? shape;

  /// Overrides the default label text style.
  final TextStyle? textStyle;

  /// Overrides the default value of the trailing icon color.
  final Color? iconColor;

  /// Overrides the default button padding.
  final EdgeInsetsGeometry? padding;

  /// Overrides the default button elevation.
  final double? elevation;

  /// Default overlay style applied to [DropdownOverlay].
  final DropdownOverlayStyle? overlayStyle;

  /// Default theme overrides applied to selector widgets inside the overlay.
  final SelectorThemeData? selectorTheme;

  @override
  DropdownSelectorButtonTheme copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? overlayColor,
    Color? shadowColor,
    Color? surfaceTintColor,
    BorderSide? side,
    OutlinedBorder? shape,
    TextStyle? textStyle,
    Color? iconColor,
    EdgeInsetsGeometry? padding,
    double? elevation,
    DropdownOverlayStyle? overlayStyle,
    SelectorThemeData? selectorTheme,
  }) {
    return DropdownSelectorButtonTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      overlayColor: overlayColor ?? this.overlayColor,
      shadowColor: shadowColor ?? this.shadowColor,
      surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
      side: side ?? this.side,
      shape: shape ?? this.shape,
      textStyle: textStyle ?? this.textStyle,
      iconColor: iconColor ?? this.iconColor,
      padding: padding ?? this.padding,
      elevation: elevation ?? this.elevation,
      overlayStyle: overlayStyle ?? this.overlayStyle,
      selectorTheme: selectorTheme ?? this.selectorTheme,
    );
  }

  /// Returns the [DropdownSelectorButtonTheme] from the nearest [Theme], or null.
  static DropdownSelectorButtonTheme? maybeOf(BuildContext context) {
    return Theme.of(context).extension<DropdownSelectorButtonTheme>();
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        overlayColor,
        shadowColor,
        surfaceTintColor,
        side,
        shape,
        textStyle,
        iconColor,
        padding,
        elevation,
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
    return other is DropdownSelectorButtonTheme &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.overlayColor == overlayColor &&
        other.shadowColor == shadowColor &&
        other.surfaceTintColor == surfaceTintColor &&
        other.side == side &&
        other.shape == shape &&
        other.textStyle == textStyle &&
        other.iconColor == iconColor &&
        other.padding == padding &&
        other.elevation == elevation &&
        other.overlayStyle == overlayStyle &&
        other.selectorTheme == selectorTheme;
  }

  @override
  ThemeExtension<DropdownSelectorButtonTheme> lerp(
      covariant ThemeExtension<DropdownSelectorButtonTheme>? other, double t) {
    if (other is! DropdownSelectorButtonTheme) {
      return this;
    }
    return DropdownSelectorButtonTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t),
      overlayColor: Color.lerp(overlayColor, other.overlayColor, t),
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t),
      surfaceTintColor:
          Color.lerp(surfaceTintColor, other.surfaceTintColor, t),
      side: side != null && other.side != null
          ? BorderSide.lerp(side!, other.side!, t)
          : t < 0.5
              ? side
              : other.side,
      shape: ShapeBorder.lerp(shape, other.shape, t) as OutlinedBorder?,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      iconColor: Color.lerp(iconColor, other.iconColor, t),
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t),
      elevation: elevation != null && other.elevation != null
          ? elevation! + (other.elevation! - elevation!) * t
          : t < 0.5
              ? elevation
              : other.elevation,
      overlayStyle: overlayStyle,
      selectorTheme:
          SelectorThemeData.lerp(selectorTheme, other.selectorTheme, t),
    );
  }
}
