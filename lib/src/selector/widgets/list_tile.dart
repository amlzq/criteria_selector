import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector_theme.dart';
import '../selector_theme_data.dart';
import 'list_tile_theme.dart';

/// Default height for [SelectorListTile].
const kSelectorListTileHeight = 44.0;

/// Base list tile used by selector views.
///
/// This tile supports a selected state, optional badge, and optional trailing
/// toggle widgets (radio/checkbox) used by [SelectorRadioListTile] and
/// [SelectorCheckboxListTile].
class SelectorListTile extends StatelessWidget {
  const SelectorListTile({
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
    this.badge,
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

  /// The text style for SelectorListTile's [label].
  final TextStyle? labelStyle;

  /// The text style for SelectorListTile's [sublabel].
  final TextStyle? sublabelStyle;

  /// Defines the background color of `SelectorListTile` when [selected] is false.
  final Color? tileColor;

  /// Defines the background color of `SelectorListTile` when [selected] is true.
  final Color? selectedTileColor;

  /// A widget to display top-trailing.
  final String? badge;

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
    final SelectorListTileTheme defaults = _SelectorLisTileDefaults(context);
    final theme = SelectorListTileTheme.of(context);

    final effectiveSelectedColor =
        selectedColor ?? theme.selectedColor ?? defaults.selectedColor;

    final effectiveTextColor = enabled
        ? selected
            ? effectiveSelectedColor
            : textColor ?? theme.textColor ?? defaults.textColor
        : Colors.grey[500];

    Widget content = Text(
      label,
      style: TextStyle(
        fontSize: 14,
        color: effectiveTextColor,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final isSublabelVisible = sublabel?.isNotEmpty ?? false;
    if (isSublabelVisible) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          content,
          Text(
            sublabel ?? '',
            style: TextStyle(
              fontSize: 12,
              color: effectiveTextColor,
              fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    final isBadgeVisible = badge != null;
    if (isBadgeVisible) {
      content = Badge(
        smallSize: 10,
        backgroundColor: effectiveSelectedColor,
        label: (badge?.isNotEmpty ?? false) ? Text(badge!) : null,
        child: content,
      );
    }

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        height: kSelectorListTileHeight,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        color: selected ? selectedTileColor : tileColor,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) leading!,
            Expanded(child: content),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _SelectorLisTileDefaults extends SelectorListTileTheme {
  _SelectorLisTileDefaults(this.context) : super();

  final BuildContext context;
  late final SelectorThemeData _theme = SelectorTheme.of(context);
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get textColor => _theme.onBackgroundColorHighest;

  @override
  TextStyle? get labelStyle => _textTheme.bodyLarge;

  @override
  TextStyle? get sublabelStyle => _textTheme.bodyMedium;

  @override
  Color? get selectedColor => _theme.selectedColor;

  @override
  ToggleWidgetBuilder? get radioBuilder => (context, selected) {
        const value = 1;
        var groupValue = 2;
        if (selected) groupValue = value;
        return IgnorePointer(
          child: Radio<int>(
            groupValue: groupValue,
            value: value,
            onChanged: (int? newValue) {},
          ),
        );
      };

  @override
  ToggleWidgetBuilder? get checkboxBuilder => (context, checked) {
        return IgnorePointer(
          child: Checkbox(
            value: checked,
            onChanged: (bool? newValue) {},
          ),
        );
      };
}

/// A selector list tile with a checkbox trailing widget.
class SelectorCheckboxListTile extends StatelessWidget {
  final String label;
  final String? sublabel;

  final bool enabled;

  final bool checked;
  final Color? checkColor;

  final ToggleWidgetBuilder? checkboxBuilder;

  /// Called when the user taps this list tile.
  ///
  /// Inoperative if [enabled] is false.
  final GestureTapCallback? onTap;

  const SelectorCheckboxListTile({
    super.key,
    required this.label,
    this.sublabel,
    this.enabled = true,
    required this.checked,
    this.checkColor,
    this.checkboxBuilder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final SelectorListTileTheme defaults = _SelectorLisTileDefaults(context);
    final theme = SelectorListTileTheme.of(context);

    final effectiveCheckbox = checkboxBuilder?.call(context, checked) ??
        theme.checkboxBuilder?.call(context, checked) ??
        defaults.checkboxBuilder!(context, checked);

    return SelectorListTile(
      label: label,
      sublabel: sublabel,
      enabled: enabled,
      onTap: onTap,
      trailing: effectiveCheckbox,
    );
  }
}

/// A selector list tile with a radio trailing widget.
class SelectorRadioListTile extends StatelessWidget {
  final String label;
  final String? sublabel;

  final bool enabled;

  final bool selected;
  final ToggleWidgetBuilder? radioBuilder;

  /// Called when the user taps this list tile.
  ///
  /// Inoperative if [enabled] is false.
  final GestureTapCallback? onTap;

  const SelectorRadioListTile({
    super.key,
    required this.label,
    this.sublabel,
    this.enabled = true,
    required this.selected,
    this.radioBuilder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final SelectorListTileTheme defaults = _SelectorLisTileDefaults(context);
    final theme = SelectorListTileTheme.of(context);

    final effectiveRadio = radioBuilder?.call(context, selected) ??
        theme.radioBuilder?.call(context, selected) ??
        defaults.radioBuilder!(context, selected);

    return SelectorListTile(
      label: label,
      sublabel: sublabel,
      enabled: enabled,
      onTap: onTap,
      trailing: effectiveRadio,
    );
  }
}
