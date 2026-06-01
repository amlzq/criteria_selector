import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../selector_entry.dart';
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

  final SelectorEntry? category;

  final List<T> entries;
  final SelectorEntries? selectedEntries;

  final SelectionMode selectionMode;

  /// Whether the chip bar is wrapable.
  final bool isWrapable;

  /// Whether to show the category title.
  final bool showTitle;

  final Color? backgroundColor;

  final EdgeInsetsGeometry? padding;

  final SelectorChipVariant? variant;

  final Color? chipColor;
  final Color? selectedChipColor;

  final TextStyle? labelStyle;
  final TextStyle? selectedLabelStyle;

  final ItemTapCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    final _SelectorChipBarDefaults defaults = _SelectorChipBarDefaults(context);
    final theme = SelectorChipBarTheme.of(context);

    final effectiveVariant = variant ?? theme.variant ?? defaults.variant!;

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

    final effectiveLabelStyle =
        (labelStyle ?? theme.labelStyle ?? defaults.labelStyle!)
            .copyWith(inherit: true);

    final effectiveSelectedLabelStyle = (selectedLabelStyle ??
            theme.selectedLabelStyle ??
            defaults.selectedLabelStyle!)
        .copyWith(inherit: true);

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
    super.key,
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
    final effectiveColor = selected ? selectedColor : color;
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
          style: labelStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _SelectorChipBarDefaults extends SelectorChipBarTheme {
  _SelectorChipBarDefaults(this.context) : super();

  final BuildContext context;
  late final SelectorThemeData _theme = SelectorTheme.of(context);
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _theme.backgroundColor;

  @override
  EdgeInsetsGeometry? get padding => EdgeInsets.zero;

  @override
  SelectorChipVariant? get variant => SelectorChipVariant.filled;

  @override
  Color? get chipColor => _theme.backgroundColorHighest;

  @override
  Color? get selectedChipColor => _theme.selectedColor;

  @override
  TextStyle? get labelStyle => _textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        color: _theme.onBackgroundColorHighest,
      );

  @override
  TextStyle? get selectedLabelStyle => _textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        color: _theme.onSelectedColor,
      );
}
