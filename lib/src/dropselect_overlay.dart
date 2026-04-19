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
    this.onChangeTap,
    this.onApplyTap,
    this.onResetTap,
    this.onOverlayTap,
    required this.availableHeight,
    this.selectorTheme,
  });

  final Selector selector;

  final DropselectOverlayStyle? style;

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

    return Material(
      color: effectiveBackgroundColor,
      child: GestureDetector(
        onTap: () {
          debugPrint('overlay taped');
          onOverlayTap?.call();
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: SelectorPanel(
                selector: selector,
                onChangeTap: onChangeTap,
                onApplyTap: onApplyTap,
                onResetTap: onResetTap,
                selectorTheme: selectorTheme,
              ),
            ),
          ],
        ),
      ),
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
