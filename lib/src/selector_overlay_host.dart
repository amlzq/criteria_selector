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
///   this follower to make the Stack origin equal the trigger's top-left).
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

  /// Global rect of this host (= the trigger), used by [DropdownOverlay] to
  /// position the panel relative to the trigger and keep it on screen.
  Rect _targetRect(RenderBox? renderBox) {
    if (renderBox == null) return Rect.zero;
    final offset = renderBox.localToGlobal(Offset.zero);
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
    final targetRect = _targetRect(renderBox);

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
              offset: Offset.zero,
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
