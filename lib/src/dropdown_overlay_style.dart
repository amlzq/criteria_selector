import 'package:flutter/material.dart';

/// Visual configuration for [DropdownOverlay].
@immutable
class DropdownOverlayStyle {
  const DropdownOverlayStyle({
    this.maxHeightFactor,
    this.backgroundColor,
    this.decoration,
  });

  /// Panel height = maxHeightFactor * available height (space from the bottom of the bar to the bottom of the screen).
  /// Note: this only affects scrollable selector content with unconstrained height. For constrained content, height is determined by Wrap.
  /// Default value is [kDropdownOverlayMaxHeightFactor].
  final double? maxHeightFactor;

  /// Overrides the default value of [Selector.panelTheme.backgroundColor].
  final Color? backgroundColor;

  /// Optional decoration applied to the overlay material.
  final Decoration? decoration;

  DropdownOverlayStyle copyWith({
    double? maxHeightFactor,
    Color? backgroundColor,
    Decoration? decoration,
  }) {
    return DropdownOverlayStyle(
      maxHeightFactor: maxHeightFactor ?? this.maxHeightFactor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      decoration: decoration ?? this.decoration,
    );
  }

  @override
  int get hashCode => Object.hash(
        maxHeightFactor,
        backgroundColor,
        decoration,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DropdownOverlayStyle &&
        other.maxHeightFactor == maxHeightFactor &&
        other.backgroundColor == backgroundColor &&
        other.decoration == decoration;
  }
}
