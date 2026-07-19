import 'package:flutter/material.dart';

import 'dropdown_overlay.dart';
import 'dropdown_overlay_style.dart';
import 'dropdown_selector_controller.dart';
import 'selector/selector_panel.dart';
import 'selector/selector_theme_data.dart';

/// Shared host that wires a trigger widget (a [DropdownSelectorBar] or a
/// [DropdownSelectorButton]) to its selector overlay.
///
/// This widget owns the boilerplate that used to be duplicated verbatim in both
/// triggers:
/// - [DropdownSelectorControllerProvider] to expose the [controller] to
///   descendants (e.g. [SelectorPanel]).
/// - [CompositedTransformTarget] + [OverlayPortal] + [CompositedTransformFollower]
///   to anchor the overlay to the trigger's actual painted position, which is
///   robust to scrolling and ancestor transforms ([DropdownOverlay] relies on
///   this follower to make the Stack origin equal the screen's top-left).
/// - [DropdownOverlay] to position, animate, and clip the [SelectorPanel].
///
/// The trigger only supplies its own UI ([triggerChild]) plus the already
/// resolved [style], [selectorTheme], and [direction], and optionally whether
/// the panel should keep at least the trigger's width ([minWidthFromTrigger]).
///
/// This widget is package-internal (kept in `lib/src/` and not re-exported from
/// the public API barrel).
class SelectorOverlayHost extends StatelessWidget {
  const SelectorOverlayHost({
    super.key,
    required this.controller,
    required this.direction,
    required this.style,
    required this.selectorTheme,
    required this.triggerChild,
    this.minWidthFromTrigger = false,
  });

  final DropdownSelectorController controller;
  final DropdownSelectorDirection direction;
  final DropdownOverlayStyle? style;
  final SelectorThemeData? selectorTheme;

  /// When true, the overlay panel's [DropdownOverlayStyle.minWidth] defaults to
  /// the trigger's width ([DropdownSelectorButton]). When false, any explicit
  /// [style.minWidth] is used as-is ([DropdownSelectorBar]).
  final bool minWidthFromTrigger;

  /// The trigger UI (the bar or the button) that toggles the overlay.
  final Widget triggerChild;

  /// Rect of this host (= the trigger) expressed in the coordinate system of
  /// the [overlay] it is inserted into, used by [DropdownOverlay] to position
  /// the panel relative to the trigger and keep it on screen.
  ///
  /// Measuring relative to the overlay (rather than the global root) lets the
  /// overlay render correctly inside a scoped overlay — for example a phone
  /// preview that wraps the selector in its own [Navigator]/[Overlay], possibly
  /// behind a [FittedBox] transform. When [overlay] is `null` (no scoped
  /// overlay, i.e. the default root overlay) the result is identical to the
  /// previous root-global measurement, so behavior is unchanged for normal use.
  Rect _targetRect(RenderBox? renderBox, RenderBox? overlayBox) {
    if (renderBox == null) return Rect.zero;
    final offset = overlayBox == null
        ? renderBox.localToGlobal(Offset.zero)
        : renderBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    return Rect.fromLTWH(
      offset.dx,
      offset.dy,
      renderBox.size.width,
      renderBox.size.height,
    );
  }

  Size _targetSize(RenderBox? renderBox) => renderBox?.size ?? Size.zero;

  @override
  Widget build(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    // Resolve the overlay the portal is inserted into so the trigger rect can
    // be measured relative to it (see [_targetRect]).
    final overlayBox =
        Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    final targetRect = _targetRect(renderBox, overlayBox);

    // Keep the panel at least as wide as the trigger when requested (button).
    // An explicit style.minWidth always wins; any style maxWidth still applies
    // as a hard cap. DropdownOverlay translates the panel to stay on screen
    // rather than shrinking it.
    final resolvedStyle = minWidthFromTrigger
        ? (style ?? const DropdownOverlayStyle()).copyWith(
            minWidth: style?.minWidth ??
                (_targetSize(renderBox).width > 0
                    ? _targetSize(renderBox).width
                    : null),
          )
        : style;

    return DropdownSelectorControllerProvider(
      controller: controller,
      child: CompositedTransformTarget(
        link: controller.layerLink,
        child: OverlayPortal(
          controller: controller.portalCtrl,
          overlayChildBuilder: (context) {
            return CompositedTransformFollower(
              link: controller.layerLink,
              showWhenUnlinked: false,
              // Shift the follower origin from the trigger's top-left to the
              // screen's top-left. This ensures the Stack's hit-test bounds
              // (size = screenSize, origin = (0,0)) cover the entire screen,
              // so taps on panel areas that extend left of the trigger (when
              // the panel is clamped on screen) are not silently dropped.
              offset: Offset(-targetRect.left, -targetRect.top),
              child: DropdownOverlay(
                targetRect: targetRect,
                direction: direction,
                style: resolvedStyle,
                animation: controller.overlayAnimation,
                onOverlayTap: () => controller.hideSelector(),
                child: SelectorPanel(
                  controller: controller.selectorController,
                  delegate: controller.previousSelectorDelegate!,
                  selectorTheme: selectorTheme,
                ),
              ),
            );
          },
          child: triggerChild,
        ),
      ),
    );
  }
}
