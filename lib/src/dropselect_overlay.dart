import 'package:flutter/material.dart';

import 'dropselect_overlay_style.dart';

const kDropselectOverlayMaxHeightFactor = 0.7;

/// Overlay container that hosts an arbitrary [child] widget (typically a
/// [SelectorPanel]).
///
/// This widget is responsible only for the overlay backdrop, expand/collapse
/// animation, and max-height constraint. The content is supplied by the caller
/// via [child], keeping this widget a pure container.
///
/// It is typically displayed by [DropselectTabBar] via
/// [DropselectTabController].
class DropselectOverlay extends StatelessWidget {
  const DropselectOverlay({
    super.key,
    required this.child,
    required this.availableHeight,
    this.style,
    this.animation,
    this.onOverlayTap,
  });

  /// The content displayed inside the overlay.
  final Widget child;

  final double availableHeight;

  final DropselectOverlayStyle? style;

  final Animation<double>? animation;

  final GestureTapCallback? onOverlayTap;

  @override
  Widget build(BuildContext context) {
    final DropselectOverlayStyle defaults = _DropselectOverlayDefaults(context);

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
              alignment: Alignment.topCenter,
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

class _DropselectOverlayDefaults extends DropselectOverlayStyle {
  const _DropselectOverlayDefaults(this.context)
      : super(maxHeightFactor: kDropselectOverlayMaxHeightFactor);

  final BuildContext context;
  // late final ColorScheme _colors = Theme.of(context).colorScheme;
  // late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => Colors.black54;
}
