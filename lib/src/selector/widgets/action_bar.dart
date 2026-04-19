import 'package:flutter/material.dart';

import '../selector_theme.dart';
import '../selector_theme_data.dart';
import 'action_bar_theme.dart';
import 'skeleton_box.dart';

/// Action bar for selector panels.
///
/// This widget typically renders "Reset" and "Apply" actions and can be styled
/// via [SelectorActionBarTheme] or per-instance overrides.
class SelectorActionBar extends StatelessWidget {
  const SelectorActionBar({
    super.key,
    this.backgroundColor,
    this.padding,
    this.resetFlex,
    this.applyFlex,
    this.resetButtonStyle,
    this.applyButtonStyle,
    this.resetText,
    this.applyText,
    this.onResetTap,
    this.onApplyTap,
  });

  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  final int? resetFlex;
  final int? applyFlex;

  final ButtonStyle? resetButtonStyle;
  final ButtonStyle? applyButtonStyle;

  final String? resetText;
  final String? applyText;

  final GestureTapCallback? onResetTap;
  final GestureTapCallback? onApplyTap;

  @override
  Widget build(BuildContext context) {
    final SelectorActionBarTheme defaults = _SelectorActionBarDefaults(context);
    final theme = SelectorActionBarTheme.of(context);

    final effectiveBackgroundColor =
        backgroundColor ?? theme.backgroundColor ?? defaults.backgroundColor!;

    final effectivePadding = padding ?? theme.padding ?? defaults.padding!;

    final effectiveResetFlex =
        resetFlex ?? theme.resetFlex ?? defaults.resetFlex!;

    final effectiveApplyFlex =
        applyFlex ?? theme.applyFlex ?? defaults.applyFlex!;

    final effectiveResetText =
        resetText ?? theme.resetText ?? defaults.resetText!;

    final effectiveApplyText =
        applyText ?? theme.applyText ?? defaults.applyText!;

    final effectiveResetButtonStyle =
        resetButtonStyle ?? theme.resetButtonStyle ?? defaults.resetButtonStyle;

    final effectiveApplyButtonStyle =
        applyButtonStyle ?? theme.applyButtonStyle ?? defaults.applyButtonStyle;

    return Container(
      color: effectiveBackgroundColor,
      padding: effectivePadding,
      child: Row(
        children: [
          Expanded(
            flex: effectiveResetFlex,
            child: FilledButton.tonal(
              onPressed: onResetTap,
              style: effectiveResetButtonStyle,
              child: Text(effectiveResetText),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: effectiveApplyFlex,
            child: FilledButton(
              onPressed: onApplyTap,
              style: effectiveApplyButtonStyle,
              child: Text(effectiveApplyText),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading skeleton for [SelectorActionBar].
class SelectorActionBarSkeleton extends StatelessWidget {
  const SelectorActionBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: SkeletonTile(
                height: 48,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: SkeletonTile(
                height: 48,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorActionBarDefaults extends SelectorActionBarTheme {
  _SelectorActionBarDefaults(this.context) : super();

  final BuildContext context;
  late final SelectorThemeData _theme = SelectorTheme.of(context);

  @override
  Color? get backgroundColor => _theme.backgroundColor;

  @override
  EdgeInsets? get padding =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

  @override
  int? get resetFlex => 4;

  @override
  int? get applyFlex => 6;

  @override
  String? get resetText => 'Reset';

  @override
  String? get applyText => 'Apply';
}
