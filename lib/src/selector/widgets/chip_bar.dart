import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector_entry.dart';
import '../selector_theme.dart';
import '../selector_theme_data.dart';
import 'chip_bar_theme.dart';
import 'extensions.dart';

/// Default height for [SelectorChipBar].
const kSelectorChipBarHeight = 44.0;

/// A horizontal chip bar for selecting among sibling entries.
///
/// This widget is commonly used as a "quick filter" row (e.g. showing children
/// of a selected entry). Selection state is provided by [selectedEntries] and user
/// interactions are reported via [onItemTap].
class SelectorChipBar<T extends SelectorEntry> extends StatelessWidget {
  const SelectorChipBar({
    super.key,
    this.category,
    required this.entries,
    this.selectedEntries,
    this.selectionMode = SelectionMode.single,
    this.isWrapable = false,
    this.showTitle = true,
    this.backgroundColor,
    this.padding,
    this.variant,
    this.chipColor,
    this.selectedChipColor,
    this.labelStyle,
    this.selectedLabelStyle,
    required this.onItemTap,
  });

  /// The parent [SelectorEntry] whose [SelectorEntry.name] is displayed as the
  /// bar's title when [showTitle] is true.
  final SelectorEntry? category;

  /// The sibling entries to display as chips in the bar.
  final List<T> entries;

  /// The set of currently selected entries.
  ///
  /// Chips whose entry is contained in this set are rendered in the selected
  /// state. When null, no chip is considered selected.
  final SelectorEntries? selectedEntries;

  /// How many chips can be selected at the same time.
  ///
  /// Defaults to [SelectionMode.single].
  final SelectionMode selectionMode;

  /// Whether the chip bar is wrapable.
  final bool isWrapable;

  /// Whether to show the category title.
  final bool showTitle;

  /// The color of the chip bar's background.
  ///
  /// If null, the value from the surrounding [SelectorChipBarTheme] or the
  /// default is used.
  final Color? backgroundColor;

  /// The padding around the chip bar's contents.
  ///
  /// Defaults to [EdgeInsets.only] with a left inset of 12.0, or
  /// [EdgeInsets.zero] when [isWrapable] is true.
  final EdgeInsetsGeometry? padding;

  /// The visual style of the chips.
  ///
  /// See [SelectorChipVariant] for the available styles. Defaults to
  /// [SelectorChipVariant.filled].
  final SelectorChipVariant? variant;

  /// The color of an unselected chip.
  ///
  /// When [variant] is [SelectorChipVariant.filled] this is used as the chip's
  /// background color; otherwise it is used as the chip's border color.
  final Color? chipColor;

  /// The color of a selected chip.
  ///
  /// When [variant] is [SelectorChipVariant.filled] this is used as the chip's
  /// background color; otherwise it is used as the chip's border and label
  /// color.
  final Color? selectedChipColor;

  /// The text style for an unselected chip's [label].
  ///
  /// If null, the value from the surrounding [SelectorChipBarTheme] or the
  /// default is used.
  final TextStyle? labelStyle;

  /// The text style for a selected chip's [label].
  ///
  /// If null, the value from the surrounding [SelectorChipBarTheme] or the
  /// default is used.
  final TextStyle? selectedLabelStyle;

  /// Called when the user taps a chip.
  ///
  /// The [index] of the tapped entry within [entries] and the tapped entry
  /// itself are passed to the callback.
  final ItemTapCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    final theme = SelectorChipBarTheme.of(context);

    final effectiveVariant =
        variant ?? theme.variant ?? SelectorChipVariant.filled;

    final defaults = _SelectorChipBarDefaults(context, effectiveVariant);

    final effectiveBackgroundColor =
        backgroundColor ?? theme.backgroundColor ?? defaults.backgroundColor!;

    final effectivePadding = padding ??
        theme.padding ??
        (isWrapable ? defaults.padding! : const EdgeInsets.only(left: 12));

    final effectiveChipColor =
        chipColor ?? theme.chipColor ?? defaults.chipColor!;

    final effectiveSelectedChipColor = selectedChipColor ??
        theme.selectedChipColor ??
        defaults.selectedChipColor!;

    final selectedTextColor = effectiveVariant == SelectorChipVariant.filled
        ? (ThemeData.estimateBrightnessForColor(effectiveSelectedChipColor) ==
                Brightness.dark
            ? Colors.white
            : Colors.black)
        : effectiveSelectedChipColor;

    final effectiveLabelStyle =
        (labelStyle ?? theme.labelStyle ?? defaults.labelStyle!)
            .copyWith(inherit: true);

    final effectiveSelectedLabelStyle = (selectedLabelStyle ??
            theme.selectedLabelStyle ??
            defaults.selectedLabelStyle!)
        .copyWith(inherit: true, color: selectedTextColor);

    final children = [
      for (final entry in entries.asMap().entries)
        (() {
          final index = entry.key;
          final item = entry.value as SelectorChildEntry;
          final selected = (selectedEntries?.contains(item) ?? false);
          return _Chip(
            label: item.name ?? '',
            selected: selected,
            variant: effectiveVariant,
            color: effectiveChipColor,
            selectedColor: effectiveSelectedChipColor,
            labelStyle: effectiveLabelStyle,
            selectedLabelStyle: effectiveSelectedLabelStyle,
            enabled: item.enabled,
            onTap: () => onItemTap(index, item),
          );
        })(),
    ];

    return Container(
      height: isWrapable ? null : kSelectorChipBarHeight,
      color: effectiveBackgroundColor,
      padding: effectivePadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // const SizedBox(width: 12),
          if (category != null && showTitle) Text(category?.name ?? ''),
          if (category != null && showTitle) const SizedBox(width: 12),
          Expanded(
            child: isWrapable
                ? Wrap(spacing: 12, runSpacing: 12, children: children)
                : SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          children.separateWith(const SizedBox(width: 12)),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    this.selected = false,
    required this.variant,
    required this.color,
    required this.selectedColor,
    required this.labelStyle,
    required this.selectedLabelStyle,
    this.enabled = true,
    required this.onTap,
  });

  final String label;

  final bool selected;

  final SelectorChipVariant variant;

  final Color color;
  final Color selectedColor;

  final TextStyle labelStyle;
  final TextStyle selectedLabelStyle;

  final bool enabled;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled
        ? selected
            ? selectedColor
            : color
        : Colors.grey[500]!;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: variant == SelectorChipVariant.filled ? effectiveColor : null,
          border: variant == SelectorChipVariant.filled
              ? null
              : Border.all(color: effectiveColor, width: 1.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: selected ? selectedLabelStyle : labelStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _SelectorChipBarDefaults extends SelectorChipBarTheme {
  _SelectorChipBarDefaults(
    this.context, [
    SelectorChipVariant? variant,
  ]) : super(variant: variant);

  final BuildContext context;

  late final SelectorThemeData _theme = SelectorTheme.of(context);
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _theme.backgroundColor;

  @override
  EdgeInsetsGeometry? get padding => EdgeInsets.zero;

  /// Default [chipColor] based on [variant].
  ///
  /// Mirrors [_SelectorGridTileDefaults.tileColor]: a light tint derived from
  /// [SelectorThemeData.onBackgroundColorHighest] toward white in light theme;
  /// blends surface colors for harmony in dark theme.
  @override
  Color? get chipColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      final blendAmount = variant == SelectorChipVariant.outlined ? 0.2 : 0.35;
      return Color.lerp(
          _theme.backgroundColor, _theme.backgroundColorHighest, blendAmount);
    }
    if (variant == SelectorChipVariant.outlined) {
      return Color.lerp(_theme.onBackgroundColorHighest, Colors.white, 0.55);
    }
    return Color.lerp(_theme.onBackgroundColorHighest, Colors.white, 0.8);
  }

  /// Default [selectedChipColor].
  ///
  /// Mirrors [_SelectorGridTileDefaults.selectedTileColor]: blends with
  /// background in dark theme for a harmonious look.
  @override
  Color? get selectedChipColor {
    final baseSelected = _theme.selectedColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Color.lerp(_theme.backgroundColor, baseSelected, 0.35);
    }
    return baseSelected;
  }

  @override
  TextStyle? get labelStyle => _textTheme.labelLarge?.copyWith(
        color: _theme.onBackgroundColorHighest,
      );

  @override
  TextStyle? get selectedLabelStyle => _textTheme.labelLarge?.copyWith(
        color: _theme.onSelectedColor,
      );
}
