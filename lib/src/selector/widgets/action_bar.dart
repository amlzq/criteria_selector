import 'package:flutter/material.dart';

import '../../i18n/localizations.dart';
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

  /// The color of the action bar's background.
  ///
  /// If null, the value from the surrounding [SelectorActionBarTheme] or the
  /// default is used.
  final Color? backgroundColor;

  /// The padding around the action bar's contents.
  ///
  /// Defaults to [EdgeInsets.symmetric] with a horizontal inset of 12.0 and a
  /// vertical inset of 8.0.
  final EdgeInsetsGeometry? padding;

  /// The flex factor to apply to the reset button's [Expanded] parent.
  ///
  /// Defaults to 4.
  final int? resetFlex;

  /// The flex factor to apply to the apply button's [Expanded] parent.
  ///
  /// Defaults to 6.
  final int? applyFlex;

  /// The visual style of the reset button.
  ///
  /// If null, the value from the surrounding [SelectorActionBarTheme] or the
  /// default is used.
  final ButtonStyle? resetButtonStyle;

  /// The visual style of the apply button.
  ///
  /// If null, the value from the surrounding [SelectorActionBarTheme] or the
  /// default is used.
  final ButtonStyle? applyButtonStyle;

  /// The text label for the reset button.
  ///
  /// If null, the localized "Reset" string is used, falling back to `"Reset"`.
  final String? resetText;

  /// The text label for the apply button.
  ///
  /// If null, the localized "Apply" string is used, falling back to `"Apply"`.
  final String? applyText;

  /// Called when the user taps the reset button.
  ///
  /// If null, the button is disabled.
  final GestureTapCallback? onResetTap;

  /// Called when the user taps the apply button.
  ///
  /// If null, the button is disabled.
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

    final localizations = SelectorLocalizations.of(context);

    final effectiveResetText = resetText ?? localizations?.reset ?? 'Reset';

    final effectiveApplyText = applyText ?? localizations?.apply ?? 'Apply';

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
}
