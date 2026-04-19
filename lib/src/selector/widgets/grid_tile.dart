import 'package:flutter/material.dart';

import '../selector_theme.dart';
import '../selector_theme_data.dart';
import 'grid_tile_theme.dart';

/// A grid tile used by selector grid layouts.
///
/// The tile supports selected/disabled states and can be rendered as filled or
/// outlined depending on [variant].
class SelectorGridTile extends StatelessWidget {
  const SelectorGridTile({
    super.key,
    required this.label,
    this.sublabel,
    this.selected = false,
    this.selectedColor,
    this.textColor,
    this.tileColor,
    this.selectedTileColor,
    this.leading,
    this.trailing,
    this.variant,
    this.enabled = true,
    this.onTap,
  });

  /// Called when the user taps this list tile.
  ///
  /// Inoperative if [enabled] is false.
  final GestureTapCallback? onTap;

  final bool enabled;

  final String label;
  final String? sublabel;

  final bool selected;

  final Color? selectedColor;

  final Color? textColor;

  final Color? tileColor;
  final Color? selectedTileColor;

  /// An optional icon to display before the label.
  final Widget? leading;

  /// An optional icon to display after the label.
  final Widget? trailing;

  final SelectorGridTileVariant? variant;

  @override
  Widget build(BuildContext context) {
    final SelectorGridTileTheme defaults = _SelectorGridTileDefaults(context);
    final theme = SelectorGridTileTheme.of(context);

    final effectiveSelectedColor =
        selectedColor ?? theme.selectedColor ?? defaults.selectedColor!;

    final effectiveVariant = variant ?? theme.variant ?? defaults.variant!;

    final selectedBackground =
        effectiveVariant == SelectorGridTileVariant.filled
            ? (selectedTileColor ?? effectiveSelectedColor)
            : null;

    final selectedTextColor = effectiveVariant == SelectorGridTileVariant.filled
        ? (ThemeData.estimateBrightnessForColor(
                    selectedBackground ?? effectiveSelectedColor) ==
                Brightness.dark
            ? Colors.white
            : Colors.black)
        : effectiveSelectedColor;

    final effectiveTextColor = enabled
        ? selected
            ? selectedTextColor
            : textColor ?? theme.textColor ?? defaults.textColor!
        : Colors.grey[500];

    final backgroundColor = effectiveVariant == SelectorGridTileVariant.filled
        ? (selected ? selectedBackground : Colors.grey[100])
        : Colors.transparent;

    final borderColor = selected ? effectiveSelectedColor : Colors.grey[500]!;

    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: effectiveVariant == SelectorGridTileVariant.outlined
              ? Border.all(
                  color: borderColor,
                  width: 1.2,
                )
              : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: effectiveTextColor,
            fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _SelectorGridTileDefaults extends SelectorGridTileTheme {
  _SelectorGridTileDefaults(this.context) : super();

  final BuildContext context;
  late final SelectorThemeData _theme = SelectorTheme.of(context);
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get selectedColor => _theme.selectedColor;

  @override
  Color? get textColor => _theme.onBackgroundColorHighest;

  @override
  TextStyle? get labelStyle => _textTheme.bodyMedium;

  @override
  TextStyle? get sublabelStyle => _textTheme.bodySmall;

  @override
  SelectorGridTileVariant? get variant => SelectorGridTileVariant.outlined;
}
