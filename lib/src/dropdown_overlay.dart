import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'dropdown_overlay_style.dart';

const kDropdownOverlayMaxHeightFactor = 0.7;

/// Minimum inset kept between the overlay panel and the screen edges.
const kDropdownOverlayScreenMargin = 0.0;

/// Vertical placement strategy for the selector overlay relative to its trigger
/// (a [DropdownSelectorButton] or [DropdownSelectorBar]).
enum DropdownSelectorDirection {
  /// Always present the panel below the trigger.
  below,

  /// Always present the panel above the trigger.
  above,

  /// Decide automatically: prefer below, but flip above when there is more
  /// room there. The panel is always clamped horizontally so it stays on
  /// screen (mirroring the behavior of [PopupMenuButton]).
  adaptive,
}

/// Overlay container that hosts an arbitrary [child] widget (typically a
/// [SelectorPanel]).
///
/// This widget is responsible for the overlay backdrop, expand/collapse
/// animation, max-height constraint, and on-screen positioning. Given the
/// global [targetRect] of the trigger and a [direction], it keeps the panel
/// fully visible by translating it (never scaling it) within the screen, and
/// flips above the trigger when [DropdownSelectorDirection.adaptive] is used
/// and space below is tight. Compared to the previous "shrink to fit the
/// available side" approach, the panel now keeps its intrinsic size, exactly
/// like [PopupMenuButton].
class DropdownOverlay extends StatelessWidget {
  const DropdownOverlay({
    super.key,
    required this.child,
    this.style,
    this.animation,
    this.onOverlayTap,
    this.targetRect,
    this.direction = DropdownSelectorDirection.adaptive,
    this.screenMargin = kDropdownOverlayScreenMargin,
  });

  /// The content displayed inside the overlay.
  final Widget child;

  final DropdownOverlayStyle? style;

  final Animation<double>? animation;

  final GestureTapCallback? onOverlayTap;

  /// Global rect of the trigger (button or bar), used to position the panel
  /// relative to the trigger and to keep it within the screen. When null, the
  /// panel is centered horizontally near the top of the screen.
  final Rect? targetRect;

  /// Vertical placement strategy. Defaults to [DropdownSelectorDirection.adaptive].
  final DropdownSelectorDirection direction;

  /// Minimum inset between the panel and the screen edges.
  final double screenMargin;

  static bool _resolveGrowUp(
    Rect? targetRect,
    Size screenSize,
    DropdownSelectorDirection direction,
  ) {
    final rect = targetRect;
    if (rect == null) return false;
    final belowSpace = screenSize.height - rect.bottom;
    final aboveSpace = rect.top;
    switch (direction) {
      case DropdownSelectorDirection.below:
        return false;
      case DropdownSelectorDirection.above:
        return true;
      case DropdownSelectorDirection.adaptive:
        return belowSpace < aboveSpace;
    }
  }

  static double _resolveAvailableHeight(
    Rect? targetRect,
    Size screenSize,
    bool growUp,
  ) {
    final rect = targetRect;
    if (rect == null) return screenSize.height;
    return growUp ? rect.top : (screenSize.height - rect.bottom);
  }

  @override
  Widget build(BuildContext context) {
    final DropdownOverlayStyle defaults = _DropdownOverlayDefaults(context);

    final maxHeightFactor = style?.maxHeightFactor ?? defaults.maxHeightFactor!;

    final effectiveBarrierColor = style?.barrierColor ??
        // ignore: deprecated_member_use_from_same_package
        style?.backgroundColor ??
        defaults.barrierColor!;
    final intercept = style?.barrierIntercept ?? true;

    final effectiveAnimation = animation ?? const AlwaysStoppedAnimation(1.0);

    final screenSize = MediaQuery.sizeOf(context);
    final bool growUp = _resolveGrowUp(targetRect, screenSize, direction);
    final double availableHeight =
        _resolveAvailableHeight(targetRect, screenSize, growUp);

    final maxHeight = availableHeight * maxHeightFactor.clamp(0.0, 1.0);

    final minWidth = style?.minWidth;
    final maxWidth = style?.maxWidth;
    Widget content = child;
    if (minWidth != null || maxWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth ?? 0.0,
          maxWidth: maxWidth ?? double.infinity,
        ),
        child: content,
      );
    }
    content = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: content,
    );

    return AnimatedBuilder(
      animation: effectiveAnimation,
      child: content,
      builder: (context, child) {
        final t = effectiveAnimation.value;
        final barrierColor =
            Color.lerp(Colors.transparent, effectiveBarrierColor, t) ??
                effectiveBarrierColor;

        // Screen rect in Stack-local coordinates.
        // Stack origin = trigger's top-left (from CompositedTransformFollower
        // with offset: Offset.zero), so the screen's top-left corner is at
        // (-targetRect.left, -targetRect.top) in Stack space.
        final screenRect = targetRect != null
            ? Rect.fromLTWH(-targetRect!.left, -targetRect!.top,
                screenSize.width, screenSize.height)
            : Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);

        return Stack(
          clipBehavior:
              Clip.none, // Allow barrier/panel to extend beyond bounds
          children: [
            // Barrier layer: covers only the direction-specific half of the screen.
            // - direction=below (growUp=false): covers area below the trigger
            // - direction=above (growUp=true):  covers area above the trigger
            // The trigger (Bar/Button) itself is never covered, so no ClipPath needed.
            if (targetRect != null)
              Positioned(
                left: -targetRect!.left,
                top: growUp ? -targetRect!.top : targetRect!.height,
                width: screenSize.width,
                height: growUp
                    ? targetRect!.top
                    : (screenSize.height - targetRect!.bottom),
                child: _buildBarrier(
                  intercept: intercept,
                  onOverlayTap: onOverlayTap,
                  barrierColor: barrierColor,
                ),
              )
            else
              Positioned.fromRect(
                rect: screenRect,
                child: _buildBarrier(
                  intercept: intercept,
                  onOverlayTap: onOverlayTap,
                  barrierColor: barrierColor,
                ),
              ),
            // Panel layer: positioned by CustomSingleChildLayout, renders on top.
            // below: panel y > 0 (within Stack)
            // above: panel y < 0 (outside Stack, rendered via clipBehavior: Clip.none)
            CustomSingleChildLayout(
              delegate: _DropdownOverlayPositionDelegate(
                targetRect: targetRect,
                screenSize: screenSize,
                growUp: growUp,
                margin: screenMargin,
              ),
              child: FadeTransition(
                opacity: effectiveAnimation,
                child: SizeTransition(
                  sizeFactor: effectiveAnimation,
                  axisAlignment: growUp ? 1.0 : -1.0,
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the barrier widget that captures taps and shows the backdrop color.
  Widget _buildBarrier({
    required bool intercept,
    required GestureTapCallback? onOverlayTap,
    required Color barrierColor,
  }) {
    return GestureDetector(
      onTap: intercept ? onOverlayTap : null,
      behavior:
          intercept ? HitTestBehavior.opaque : HitTestBehavior.translucent,
      child: ColoredBox(color: barrierColor),
    );
  }
}

/// Positions the overlay child relative to the trigger rect, keeping it fully
/// on screen by translating it. This mirrors the strategy used by
/// [PopupMenuButton]'s [positionDependentBox] (preserve size, clamp position)
/// rather than scaling the panel down.
class _DropdownOverlayPositionDelegate extends SingleChildLayoutDelegate {
  _DropdownOverlayPositionDelegate({
    required this.targetRect,
    required this.screenSize,
    required this.growUp,
    required this.margin,
  });

  final Rect? targetRect;
  final Size screenSize;
  final bool growUp;
  final double margin;

  @override
  Size getSize(BoxConstraints constraints) => constraints.constrain(screenSize);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxW = math.max(0.0, screenSize.width - margin * 2);
    final double maxH;
    final rect = targetRect;
    if (rect == null) {
      maxH = screenSize.height - margin * 2;
    } else {
      maxH = (growUp ? rect.top : screenSize.height - rect.bottom) - margin;
    }
    return BoxConstraints(
      maxWidth: maxW,
      maxHeight: math.max(0.0, maxH),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final rect = targetRect;
    if (rect == null) {
      // No anchor: center horizontally near the top.
      final dx = (screenSize.width - childSize.width) / 2;
      return Offset(dx, margin);
    }

    // Horizontal: anchor the panel's left edge at the trigger's left edge,
    // then clamp so the whole panel stays within [margin, screenW - margin].
    double left = rect.left;
    final maxLeft = screenSize.width - margin - childSize.width;
    if (left > maxLeft) left = maxLeft;
    if (left < margin) left = margin;

    // Vertical: below the trigger, or above it when [growUp] is set. The
    // returned offset is relative to the trigger's top-left corner (the
    // CompositedTransformFollower origin).
    final double top = growUp ? rect.top - childSize.height : rect.bottom;
    return Offset(left - rect.left, top - rect.top);
  }

  @override
  bool shouldRelayout(covariant _DropdownOverlayPositionDelegate old) =>
      old.targetRect != targetRect ||
      old.screenSize != screenSize ||
      old.growUp != growUp ||
      old.margin != margin;
}

class _DropdownOverlayDefaults extends DropdownOverlayStyle {
  const _DropdownOverlayDefaults(this.context)
      : super(maxHeightFactor: kDropdownOverlayMaxHeightFactor);

  final BuildContext context;

  @override
  Color? get barrierColor => Colors.transparent;
}
