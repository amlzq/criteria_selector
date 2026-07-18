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
    final theme = SelectorGridTileTheme.of(context);

    final effectiveSelectedColor = selectedColor ?? theme.selectedColor;

    final effectiveVariant =
        variant ?? theme.variant ?? SelectorGridTileVariant.filled;

    final defaults =
        _SelectorGridTileDefaults(context, enabled, selected, effectiveVariant);

    final effectiveTileColor =
        tileColor ?? theme.tileColor ?? defaults.tileColor!;

    final effectiveSelectedTileColor = selectedTileColor ??
        theme.selectedTileColor ??
        defaults.selectedTileColor!;

    final tileBackgroundColor =
        effectiveVariant == SelectorGridTileVariant.filled
            ? (selected ? effectiveSelectedTileColor : effectiveTileColor)
            : Colors.transparent;

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
        : Colors.grey[500]!;

    // For the outlined variant the border reuses the tile colors: the normal
    // border uses [tileColor] and the selected border uses [selectedTileColor],
    // keeping the styling consistent with [SelectorFieldTile].
    final effectiveBorder = effectiveVariant == SelectorGridTileVariant.filled
        ? null
        : Border.all(
            color: selected ? effectiveSelectedTileColor : effectiveTileColor,
            width: 1.2);

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
  _SelectorGridTileDefaults(
    this.context,
    this.isEnabled,
    this.isSelected, [
    this.variant,
  ]) : super();

  final BuildContext context;
  final bool isEnabled;
  final bool isSelected;
  final SelectorGridTileVariant? variant;

  late final SelectorThemeData _theme = SelectorTheme.of(context);
  late final ColorScheme _colorScheme = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get selectedColor => _theme.selectedColor;

  @override
  Color? get textColor => _theme.onBackgroundColorHighest;

  @override
  TextStyle? get labelStyle => _textTheme.bodyLarge;

  @override
  TextStyle? get sublabelStyle => _textTheme.bodyMedium;

  /// Default [tileColor] based on [variant].
  ///
  /// - **outlined**: uses `outline` for visible borders (deeper than `outlineVariant`).
  /// - **filled**: uses a very light surface container color for subtle backgrounds.
  @override
  Color? get tileColor {
    if (variant == SelectorGridTileVariant.outlined) {
      return _colorScheme.outline; // Deeper border color for clarity
    }
    return _colorScheme.surfaceContainerLow; // Light, unobtrusive background
  }

  /// Default [selectedTileColor] based on [variant].
  ///
  /// - **outlined**: subtle tint for selected border emphasis.
  /// - **filled**: very light tint for selected background indication.
  @override
  Color? get selectedTileColor {
    if (variant == SelectorGridTileVariant.outlined) {
      return _theme.selectedColor
          .withOpacity(0.20); // Moderate emphasis for borders
    }
    return _theme.selectedColor
        .withOpacity(0.12); // Subtle tint for backgrounds
  }
}
