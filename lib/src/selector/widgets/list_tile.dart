import 'package:flutter/material.dart';

import '../../constants.dart';
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
    required this.label,
    this.sublabel,
    this.labelStyle,
    this.sublabelStyle,
    this.selectedColor,
    this.textColor,
    this.selected = false,
    this.tileColor,
    this.selectedTileColor,
    this.leading,
    this.trailing,
    this.badge,
    this.enabled = true,
    this.onTap,
  });

  /// Called when the user taps this list tile.
  ///
  /// Inoperative if [enabled] is false.
  final GestureTapCallback? onTap;

  final String label;
  final String? sublabel;

  final TextStyle? labelStyle;
  final TextStyle? sublabelStyle;

  final bool selected;

  final Color? selectedColor;

  final Color? textColor;

  /// An optional icon to display before the label.
  final Widget? leading;

  /// An optional icon to display after the label.
  final Widget? trailing;

  final Color? tileColor;
  final Color? selectedTileColor;

  /// Whether to show a badge
  ///
  /// Visible when the item's children have selected entries.
  final String? badge;

  final bool enabled;

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
  TextStyle? get labelStyle => _textTheme.bodyMedium;

  @override
  TextStyle? get sublabelStyle => _textTheme.bodySmall;

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
