import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../selector_entry.dart';
import '../selector_theme.dart';
import '../selector_theme_data.dart';
import 'chip_bar_theme.dart';

/// Default height for [SelectorChipBar].
const kSelectorChipBarHeight = 44.0;

/// A horizontal chip bar for selecting among sibling entries.
///
/// This widget is commonly used as a "quick filter" row (e.g. showing children
/// of a selected node). Selection state is provided by [selectedItems] and user
/// interactions are reported via [onItemTap].
class SelectorChipBar<T extends SelectorEntry> extends StatelessWidget {
  const SelectorChipBar({
    super.key,
    this.label,
    required this.items,
    this.selectedItems,
    this.variant,
    this.color,
    this.labelStyle,
    this.selectedColor,
    this.selectedLabelStyle,
    this.backgroundColor,
    required this.onItemTap,
    this.padding,
    this.selectionMode = SelectionMode.single,
  });

  final String? label;

  final List<T> items;
  final SelectorEntries? selectedItems;

  final SelectorChipVariant? variant;
  final Color? color;
  final TextStyle? labelStyle;
  final Color? selectedColor;
  final TextStyle? selectedLabelStyle;

  final Color? backgroundColor;

  final ItemTapCallback onItemTap;

  final EdgeInsetsGeometry? padding;

  final SelectionMode selectionMode;

  @override
  Widget build(BuildContext context) {
    final _SelectorChipBarDefaults defaults = _SelectorChipBarDefaults(context);
    final theme = SelectorChipBarTheme.of(context);

    final effectiveVariant = variant ?? theme.variant ?? defaults.variant!;

    final effectiveBackgroundColor =
        backgroundColor ?? theme.backgroundColor ?? defaults.backgroundColor!;

    final effectivePadding = padding ?? theme.padding ?? defaults.padding!;

    // Resolve unselected color
    final effectiveColor = color ??
        theme.color ??
        labelStyle?.color ??
        theme.labelStyle?.color ??
        defaults.color!;

    // Resolve selected color
    final effectiveSelectedColor = selectedColor ??
        theme.selectedColor ??
        selectedLabelStyle?.color ??
        theme.selectedLabelStyle?.color ??
        defaults.selectedColor!;

    final effectiveLabelStyle =
        (labelStyle ?? theme.labelStyle ?? defaults.labelStyle!)
            .copyWith(inherit: true);

    final effectiveSelectedLabelStyle = (selectedLabelStyle ??
            theme.selectedLabelStyle ??
            defaults.selectedLabelStyle!)
        .copyWith(inherit: true);

    return Container(
      height: kSelectorChipBarHeight,
      color: effectiveBackgroundColor,
      padding: effectivePadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 12),
          Text(label ?? ''),
          const SizedBox(width: 12),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as SelectorChildEntry;
                final selected = (selectedItems?.contains(item) ?? false);

                final textStyle = selected
                    ? effectiveSelectedLabelStyle
                    : effectiveLabelStyle;

                return ChoiceChip(
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  showCheckmark: false,
                  label: DefaultTextStyle(
                    style: textStyle,
                    child: Text(item.name ?? ''),
                  ),
                  // labelPadding: EdgeInsets.zero,
                  selectedColor: effectiveSelectedColor,
                  side: effectiveVariant == SelectorChipVariant.filled
                      ? BorderSide.none
                      : BorderSide(
                          color:
                              selected ? effectiveSelectedColor : Colors.grey,
                        ),
                  selected: selected,
                  onSelected: (_) => onItemTap(index, item),
                );

                // return Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 8),
                //   alignment: Alignment.center,
                //   decoration: BoxDecoration(
                //     color: Colors.grey[200],
                //     borderRadius: BorderRadius.circular(4),
                //   ),
                //   child: Text(item.name ?? ''),
                // );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 12),
            ),
          ),
          const SizedBox(width: 12),
        ],
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
  Color? get color => _theme.onBackgroundColorHighest;

  @override
  TextStyle? get labelStyle => _textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        color: _theme.onBackgroundColorHighest,
      );

  @override
  Color? get selectedColor => _theme.selectedColor;

  @override
  TextStyle? get selectedLabelStyle => _textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        color: _theme.onSelectedColor,
      );
}
