import 'package:flutter/material.dart';

/// Visual configuration for [DropdownOverlay].
@immutable
class DropdownOverlayStyle {
  const DropdownOverlayStyle({
    this.maxHeightFactor,
    @Deprecated(
        'Use [barrierColor] instead; this always controlled the scrim color.')
    this.backgroundColor,
    this.minWidth,
    this.maxWidth,
    this.barrierColor,
    this.barrierIntercept = true,
  });

  /// Panel height = maxHeightFactor * available height (space from the bottom of the bar to the bottom of the screen).
  /// Note: this only affects scrollable selector content with unconstrained height. For constrained content, height is determined by Wrap.
  /// Default value is [kDropdownOverlayMaxHeightFactor].
  final double? maxHeightFactor;

  /// @deprecated This has always controlled the scrim (backdrop) color, not the
  /// panel background. Use [barrierColor] instead.
  @Deprecated(
      'Use [barrierColor] instead; this always controlled the scrim color.')
  final Color? backgroundColor;

  /// Minimum width of the overlay content (e.g. to keep it at least as wide as
  /// the trigger button). When null, no minimum width is enforced.
  final double? minWidth;

  /// Maximum width of the overlay content. Used to prevent the panel from
  /// overflowing the screen on either side. When null, no maximum width is
  /// enforced (the previous behavior).
  final double? maxWidth;

  /// Color of the scrim (backdrop) behind the overlay content.
  ///
  /// Defaults to [Colors.transparent] (no visible scrim). Pass a color such as
  /// [Colors.black54] to show a dimming backdrop behind the overlay content.
  final Color? barrierColor;

  /// Whether the scrim intercepts pointer events.
  ///
  /// - `true` (default): tapping the scrim dismisses the overlay (current
  ///   behavior).
  /// - `false`: the scrim is translucent and taps pass through to the widgets
  ///   below; the overlay is not dismissed by tapping the scrim.
  final bool barrierIntercept;

  DropdownOverlayStyle copyWith({
    double? maxHeightFactor,
    Color? backgroundColor,
    double? minWidth,
    double? maxWidth,
    Color? barrierColor,
    bool? barrierIntercept,
  }) {
    return DropdownOverlayStyle(
      maxHeightFactor: maxHeightFactor ?? this.maxHeightFactor,
      // ignore: deprecated_member_use_from_same_package
      backgroundColor: backgroundColor ?? this.backgroundColor,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      barrierColor: barrierColor ?? this.barrierColor,
      barrierIntercept: barrierIntercept ?? this.barrierIntercept,
    );
  }

  @override
  int get hashCode => Object.hash(
        maxHeightFactor,
        // ignore: deprecated_member_use_from_same_package
        backgroundColor,
        minWidth,
        maxWidth,
        barrierColor,
        barrierIntercept,
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
        // ignore: deprecated_member_use_from_same_package
        other.backgroundColor == backgroundColor &&
        other.minWidth == minWidth &&
        other.maxWidth == maxWidth &&
        other.barrierColor == barrierColor &&
        other.barrierIntercept == barrierIntercept;
  }
}
