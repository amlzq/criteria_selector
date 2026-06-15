import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../selector_theme.dart';

@immutable
class SelectorExpansionTileTheme with Diagnosticable {
  const SelectorExpansionTileTheme({
    this.titleStyle,
    this.titlePadding,
    this.selectedColor,
    this.childPadding,
    this.animationDuration,
    this.expansionCurve,
    this.collapseCurve,
  });

  /// Overrides the default value of [SelectorExpansionTile.titleStyle].
  final TextStyle? titleStyle;

  /// Overrides the default value of [SelectorExpansionTile.selectedColor].
  final EdgeInsetsGeometry? titlePadding;

  /// Overrides the default value of [SelectorExpansionTile.selectedColor].
  final Color? selectedColor;

  /// Overrides the default value of [SelectorExpansionTile.childPadding].
  final EdgeInsetsGeometry? childPadding;

  /// Overrides the default value of [SelectorExpansionTile.animationDuration].
  final Duration? animationDuration;

  /// Overrides the default value of [SelectorExpansionTile.expansionCurve].
  final Curve? expansionCurve;

  /// Overrides the default value of [SelectorExpansionTile.collapseCurve].
  final Curve? collapseCurve;

  SelectorExpansionTileTheme copyWith({
    TextStyle? titleStyle,
    EdgeInsetsGeometry? titlePadding,
    Color? selectedColor,
    EdgeInsetsGeometry? childPadding,
    Duration? animationDuration,
    Curve? expansionCurve,
    Curve? collapseCurve,
  }) {
    return SelectorExpansionTileTheme(
      titleStyle: titleStyle ?? this.titleStyle,
      titlePadding: titlePadding ?? this.titlePadding,
      selectedColor: selectedColor ?? this.selectedColor,
      childPadding: childPadding ?? this.childPadding,
      animationDuration: animationDuration ?? this.animationDuration,
      expansionCurve: expansionCurve ?? this.expansionCurve,
      collapseCurve: collapseCurve ?? this.collapseCurve,
    );
  }

  static SelectorExpansionTileTheme of(BuildContext context) {
    return SelectorTheme.of(context).expansionTileTheme;
  }

  static SelectorExpansionTileTheme lerp(
      SelectorExpansionTileTheme? a, SelectorExpansionTileTheme? b, double t) {
    if (identical(a, b) && a != null) {
      return a;
    }
    return SelectorExpansionTileTheme(
      titleStyle: TextStyle.lerp(
        a?.titleStyle,
        b?.titleStyle,
        t,
      ),
      titlePadding: EdgeInsetsGeometry.lerp(
        a?.titlePadding,
        b?.titlePadding,
        t,
      ),
      selectedColor: Color.lerp(
        a?.selectedColor,
        b?.selectedColor,
        t,
      ),
      childPadding: EdgeInsetsGeometry.lerp(
        a?.childPadding,
        b?.childPadding,
        t,
      ),
      animationDuration: t < 0.5 ? a?.animationDuration : b?.animationDuration,
      expansionCurve: t < 0.5 ? a?.expansionCurve : b?.expansionCurve,
      collapseCurve: t < 0.5 ? a?.collapseCurve : b?.collapseCurve,
    );
  }

  @override
  int get hashCode => Object.hash(
        titleStyle,
        titlePadding,
        selectedColor,
        childPadding,
        animationDuration,
        expansionCurve,
        collapseCurve,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SelectorExpansionTileTheme &&
        other.titleStyle == titleStyle &&
        other.titlePadding == titlePadding &&
        other.selectedColor == selectedColor &&
        other.childPadding == childPadding &&
        other.animationDuration == animationDuration &&
        other.expansionCurve == expansionCurve &&
        other.collapseCurve == collapseCurve;
  }
}
