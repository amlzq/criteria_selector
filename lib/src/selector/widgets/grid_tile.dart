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
    this.leading,
    required this.label,
    this.sublabel,
    this.trailing,
    this.selectedColor,
    this.textColor,
    this.labelStyle,
    this.sublabelStyle,
    this.tileColor,
    this.selectedTileColor,
    this.variant,
    this.selected = false,
    this.enabled = true,
    this.onTap,
  });

  /// An optional icon to display before the label.
  final Widget? leading;

  /// The primary content of the list label.
  final String label;

  /// Additional content displayed below the label.
  final String? sublabel;

  /// A widget to display after the label.
  final Widget? trailing;

  /// Defines the color used for icons and text when the list label is selected.
  final Color? selectedColor;

  /// Defines the text color for the [label], [sublabel], [leading], and [trailing].
  final Color? textColor;

  /// The text style for SelectorGridTile's [label].
  final TextStyle? labelStyle;

  /// The text style for SelectorGridTile's [sublabel].
  final TextStyle? sublabelStyle;

  /// Defines the background color of `SelectorGridTile` when [selected] is false.
  final Color? tileColor;

  /// Defines the background color of `SelectorGridTile` when [selected] is true.
  final Color? selectedTileColor;

  final SelectorGridTileVariant? variant;

  /// If this tile is also [enabled] then icons and text are rendered with the same color.
  final bool selected;

  /// Whether this list tile is interactive.
  final bool enabled;

  /// Called when the user taps this list tile.
  ///
  /// Inoperative if [enabled] is false.
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final SelectorGridTileTheme defaults = _SelectorGridTileDefaults(context);
    final theme = SelectorGridTileTheme.of(context);

    final effectiveSelectedColor =
        selectedColor ?? theme.selectedColor ?? defaults.selectedColor!;

    final effectiveVariant = variant ?? theme.variant ?? defaults.variant!;

    final effectiveTileColor =
        effectiveVariant == SelectorGridTileVariant.filled
            ? tileColor ?? theme.tileColor ?? defaults.tileColor!
            : Colors.transparent;

    final effectiveSelectedTileColor =
        effectiveVariant == SelectorGridTileVariant.filled
            ? selectedTileColor ??
                theme.selectedTileColor ??
                defaults.selectedTileColor
            : Colors.transparent;

    final tileBackgroundColor = selected
        ? effectiveSelectedTileColor ?? effectiveTileColor
        : effectiveTileColor;

    final effectiveBorder = effectiveVariant == SelectorGridTileVariant.filled
        ? null
        : Border.all(color: tileBackgroundColor, width: 1.2);

    final selectedTextColor = effectiveVariant == SelectorGridTileVariant.filled
        ? (ThemeData.estimateBrightnessForColor(tileBackgroundColor) ==
                Brightness.dark
            ? Colors.white
            : effectiveSelectedColor)
        : effectiveSelectedColor;

    final effectiveTextColor = enabled
        ? selected
            ? selectedTextColor
            : textColor ?? theme.textColor ?? defaults.textColor!
        : Colors.grey[500];

    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tileBackgroundColor,
          border: effectiveBorder,
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
  SelectorGridTileVariant? get variant => SelectorGridTileVariant.filled;

  @override
  Color? get tileColor => _theme.backgroundColorHighest;
}
