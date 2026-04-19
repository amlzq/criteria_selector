import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../selector_theme.dart';

/// Theme configuration for [SelectorActionBar].
@immutable
class SelectorActionBarTheme with Diagnosticable {
  /// Background color of the action bar.
  final Color? backgroundColor;

  /// Outer padding of the action bar content.
  final EdgeInsets? padding;

  /// Flex for the reset button in the row.
  final int? resetFlex;

  /// Flex for the apply button in the row.
  final int? applyFlex;

  /// Label text for the reset action.
  final String? resetText;

  /// Label text for the apply action.
  final String? applyText;

  /// Button style override for the reset button.
  final ButtonStyle? resetButtonStyle;

  /// Button style override for the apply button.
  final ButtonStyle? applyButtonStyle;

  const SelectorActionBarTheme({
    this.backgroundColor,
    this.padding,
    this.resetFlex,
    this.applyFlex,
    this.resetText,
    this.applyText,
    this.resetButtonStyle,
    this.applyButtonStyle,
  });

  /// Returns a copy of this theme with the given fields replaced.
  SelectorActionBarTheme copyWith({
    Color? backgroundColor,
    EdgeInsets? padding,
    int? resetFlex,
    int? applyFlex,
    String? resetText,
    String? applyText,
    ButtonStyle? resetButtonStyle,
    ButtonStyle? applyButtonStyle,
  }) {
    return SelectorActionBarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      resetFlex: resetFlex ?? this.resetFlex,
      applyFlex: applyFlex ?? this.applyFlex,
      resetText: resetText ?? this.resetText,
      applyText: applyText ?? this.applyText,
      resetButtonStyle: resetButtonStyle ?? this.resetButtonStyle,
      applyButtonStyle: applyButtonStyle ?? this.applyButtonStyle,
    );
  }

  static SelectorActionBarTheme of(BuildContext context) {
    return SelectorTheme.of(context).actionBarTheme;
  }

  /// Linearly interpolates between two action bar themes.
  static SelectorActionBarTheme lerp(
      SelectorActionBarTheme? a, SelectorActionBarTheme? b, double t) {
    if (identical(a, b) && a != null) {
      return a;
    }
    return SelectorActionBarTheme(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      padding: EdgeInsets.lerp(a?.padding, b?.padding, t),
      resetFlex: a?.resetFlex ?? b?.resetFlex ?? 1.toInt(),
      applyFlex: a?.applyFlex ?? b?.applyFlex ?? 1.toInt(),
      resetText: a?.resetText ?? b?.resetText ?? 'Reset',
      applyText: a?.applyText ?? b?.applyText ?? 'Apply',
      resetButtonStyle:
          ButtonStyle.lerp(a?.resetButtonStyle, b?.resetButtonStyle, t),
      applyButtonStyle:
          ButtonStyle.lerp(a?.applyButtonStyle, b?.applyButtonStyle, t),
    );
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        padding,
        resetFlex,
        applyFlex,
        resetText,
        applyText,
        resetButtonStyle,
        applyButtonStyle,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SelectorActionBarTheme &&
        other.backgroundColor == backgroundColor &&
        other.padding == padding &&
        other.resetFlex == resetFlex &&
        other.applyFlex == applyFlex &&
        other.resetText == resetText &&
        other.applyText == applyText &&
        other.resetButtonStyle == resetButtonStyle &&
        other.applyButtonStyle == applyButtonStyle;
  }
}
