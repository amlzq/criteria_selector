import 'package:flutter/material.dart';

/// Visual configuration for [DropselectOverlay].
class DropselectOverlayStyle {
  /// Overrides the default value of [Selector.overlayStyle.height].
  // final double? height;

  /// Panel height = maxHeightFactor * available height (space from the bottom of the bar to the bottom of the screen).
  /// Note: this only affects scrollable selector content with unconstrained height. For constrained content, height is determined by Wrap.
  /// Default value is [kDropselectOverlayMaxHeightFactor].
  final double? maxHeightFactor;

  /// Overrides the default value of [Selector.panelTheme.backgroundColor].
  final Color? backgroundColor;

  /// Optional decoration applied to the overlay material.
  final Decoration? decoration;

  DropselectOverlayStyle({
    // this.height,
    this.maxHeightFactor,
    this.backgroundColor,
    this.decoration,
  });

  DropselectOverlayStyle copyWith({
    double? maxHeightFactor,
    Color? backgroundColor,
    Decoration? decoration,
  }) {
    return DropselectOverlayStyle(
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
    return other is DropselectOverlayStyle &&
        other.maxHeightFactor == maxHeightFactor &&
        other.backgroundColor == backgroundColor &&
        other.decoration == decoration;
  }
}
