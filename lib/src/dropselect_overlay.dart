import 'package:flutter/material.dart';

import 'constants.dart';
import 'dropselect_overlay_style.dart';
import 'selector.dart';
import 'selector/selector_panel.dart';
import 'selector/selector_theme_data.dart';

const kDropselectOverlayMaxHeightFactor = 0.7;

/// Overlay container that hosts a [SelectorPanel].
///
/// This widget is typically displayed by [DropselectTabBar] via
/// [DropselectTabController].
class DropselectOverlay extends StatelessWidget {
  const DropselectOverlay({
    super.key,
    required this.selector,
    required this.style,
    this.animation,
    this.onChangeTap,
    this.onApplyTap,
    this.onResetTap,
    this.onOverlayTap,
    required this.availableHeight,
    this.selectorTheme,
  });

  final Selector selector;

  final DropselectOverlayStyle? style;

  final Animation<double>? animation;

  final SelectorCallback? onChangeTap;

  final SelectorCallback? onApplyTap;

  final VoidCallback? onResetTap;

  final GestureTapCallback? onOverlayTap;

  final double availableHeight;

  final SelectorThemeData? selectorTheme;

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
        child: SelectorPanel(
          selector: selector,
          onChangeTap: onChangeTap,
          onApplyTap: onApplyTap,
          onResetTap: onResetTap,
          selectorTheme: selectorTheme,
        ),
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
  _DropselectOverlayDefaults(this.context)
      : super(maxHeightFactor: kDropselectOverlayMaxHeightFactor);

  final BuildContext context;
  // late final ColorScheme _colors = Theme.of(context).colorScheme;
  // late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => Colors.black54;
}
