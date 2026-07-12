import 'package:flutter/material.dart';

import 'dropdown_overlay_style.dart';

const kDropdownOverlayMaxHeightFactor = 0.7;

/// Overlay container that hosts an arbitrary [child] widget (typically a
/// [SelectorPanel]).
///
/// This widget is responsible only for the overlay backdrop, expand/collapse
/// animation, and max-height constraint. The content is supplied by the caller
/// via [child], keeping this widget a pure container.
///
/// It is typically displayed by [DropdownSelectorBar] via
/// [DropdownSelectorController].
class DropdownOverlay extends StatelessWidget {
  const DropdownOverlay({
    super.key,
    required this.child,
    required this.availableHeight,
    this.style,
    this.animation,
    this.onOverlayTap,
    this.alignment = Alignment.topCenter,
  });

  /// The content displayed inside the overlay.
  final Widget child;

  final double availableHeight;

  final DropdownOverlayStyle? style;

  final Animation<double>? animation;

  final GestureTapCallback? onOverlayTap;

  /// Horizontal/vertical alignment of the overlay content within the backdrop.
  ///
  /// Defaults to [Alignment.topCenter], which matches [DropdownSelectorBar].
  /// [DropdownSelectorButton] uses [Alignment.topLeft] so the panel anchors
  /// under the trigger instead of being centered on screen.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final DropdownOverlayStyle defaults = _DropdownOverlayDefaults(context);

    final maxHeightFactor = style?.maxHeightFactor ?? defaults.maxHeightFactor!;
    debugPrint('maxHeightFactor=$maxHeightFactor');

    debugPrint('availableHeight=$availableHeight');
    final maxHeight = availableHeight * maxHeightFactor.clamp(0.0, 1.0);

    final effectiveBackgroundColor =
        style?.backgroundColor ?? defaults.backgroundColor!;

    final effectiveAnimation = animation ?? const AlwaysStoppedAnimation(1.0);

    return AnimatedBuilder(
      animation: effectiveAnimation,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: child,
      ),
      builder: (context, child) {
        final t = effectiveAnimation.value;
        final barrierColor =
            Color.lerp(Colors.transparent, effectiveBackgroundColor, t) ??
                effectiveBackgroundColor;
        return Material(
          color: barrierColor,
          child: GestureDetector(
            onTap: () {
              debugPrint('overlay taped');
              onOverlayTap?.call();
            },
            behavior: HitTestBehavior.opaque,
            child: Align(
              alignment: alignment,
              child: FadeTransition(
                opacity: effectiveAnimation,
                child: SizeTransition(
                  sizeFactor: effectiveAnimation,
                  axisAlignment: -1.0,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DropdownOverlayDefaults extends DropdownOverlayStyle {
  const _DropdownOverlayDefaults(this.context)
      : super(maxHeightFactor: kDropdownOverlayMaxHeightFactor);

  final BuildContext context;
  // late final ColorScheme _colors = Theme.of(context).colorScheme;
  // late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => Colors.black54;
}
