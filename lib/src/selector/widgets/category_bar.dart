import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../selector_entry.dart';
import '../selector_theme.dart';
import '../selector_theme_data.dart';
import 'category_bar_theme.dart';
import 'list_tile.dart';
import 'skeleton_box.dart';

/// Category bar used by cascading selectors.
///
/// The bar renders the category entries horizontally and indicates the current
/// selection via an animated indicator.
class SelectorCategoryBar<T extends SelectorEntry> extends StatelessWidget {
  const SelectorCategoryBar({
    super.key,
    required this.entries,
    required this.selectedCategories,
    required this.focusedIndex,
    this.scrollDirection = Axis.horizontal,
    this.size,
    this.padding,
    this.isScrollable = false,
    this.backgroundColor,
    this.selectedColor,
    this.labelStyle,
    this.selectedLabelStyle,
    this.selectedTileColor,
    this.indicatorColor,
    this.indicatorHeight,
    this.indicatorPadding,
    this.indicatorSize,
    this.indicatorAnimationDuration,
    required this.onTap,
  });

  final List<T> entries;

  final Set<T> selectedCategories;
  final int focusedIndex;

  final Axis scrollDirection;

  final double? size;

  final EdgeInsetsGeometry? padding;

  final bool isScrollable;

  final Color? backgroundColor;

  /// Selected color for text.
  final Color? selectedColor;
  final TextStyle? labelStyle;
  final TextStyle? selectedLabelStyle;

  final Color? selectedTileColor;

  final Color? indicatorColor;
  final double? indicatorHeight;
  final EdgeInsetsGeometry? indicatorPadding;
  final SelectorCategoryBarIndicatorSize? indicatorSize;
  final Duration? indicatorAnimationDuration;

  final ItemTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SelectorCategoryBarTheme defaults =
        _SelectorCategoryBarDefaults(context);

    final theme = SelectorCategoryBarTheme.of(context);

    final effctiveSize = size ?? theme.size ?? defaults.size!;

    final width = scrollDirection == Axis.vertical ? effctiveSize : null;
    // final height = scrollDirection == Axis.horizontal ? effctiveSize : null;

    final effectivePadding = padding ?? theme.padding ?? defaults.padding!;
    final containerPadding = isScrollable ? EdgeInsets.zero : effectivePadding;

    final effectiveBackgroundColor =
        backgroundColor ?? theme.backgroundColor ?? defaults.backgroundColor!;

    final effectiveSelectedColor =
        selectedColor ?? theme.selectedColor ?? defaults.selectedColor!;

    final effectiveLabelStyle =
        labelStyle ?? theme.labelStyle ?? defaults.labelStyle!;

    final effectiveSelectedLabelStyle = selectedLabelStyle ??
        theme.selectedLabelStyle ??
        defaults.selectedLabelStyle!;

    final effectiveSelectedTileColor = selectedTileColor ??
        theme.selectedTileColor ??
        defaults.selectedTileColor;

    final effectiveIndicatorColor =
        indicatorColor ?? theme.indicatorColor ?? defaults.indicatorColor!;

    final effectiveIndicatorHeight =
        indicatorHeight ?? theme.indicatorHeight ?? defaults.indicatorHeight!;

    final effectiveIndicatorPadding = indicatorPadding ??
        theme.indicatorPadding ??
        defaults.indicatorPadding!;

    final effectiveIndicatorSize =
        indicatorSize ?? theme.indicatorSize ?? defaults.indicatorSize!;

    final effectiveIndicatorAnimationDuration = indicatorAnimationDuration ??
        theme.indicatorAnimationDuration ??
        defaults.indicatorAnimationDuration!;

    return Container(
      width: width,
      // height: height,
      padding: containerPadding,
      color: effectiveBackgroundColor,
      child: scrollDirection == Axis.vertical
          ? _VerticalBar(
              entries: entries,
              selectedCategories: selectedCategories,
              focusedIndex: focusedIndex,
              isScrollable: isScrollable,
              padding: effectivePadding,
              selectedColor: effectiveSelectedColor,
              labelStyle: effectiveLabelStyle,
              selectedLabelStyle: effectiveSelectedLabelStyle,
              selectedTileColor: effectiveSelectedTileColor,
              // indicatorColor: effectiveIndicatorColor,
              // indicatorHeight: effectiveIndicatorHeight,
              // indicatorPadding: effectiveIndicatorPadding,
              // indicatorSize: effectiveIndicatorSize,
              // indicatorAnimationDuration: effectiveIndicatorAnimationDuration,
              onTap: onTap,
            )
          : _HorizontalBar(
              entries: entries,
              selectedCategories: selectedCategories,
              focusedIndex: focusedIndex,
              isScrollable: isScrollable,
              padding: effectivePadding,
              selectedColor: effectiveSelectedColor,
              labelStyle: effectiveLabelStyle,
              selectedLabelStyle: effectiveSelectedLabelStyle,
              selectedTileColor: effectiveSelectedTileColor,
              indicatorColor: effectiveIndicatorColor,
              indicatorHeight: effectiveIndicatorHeight,
              indicatorPadding: effectiveIndicatorPadding,
              indicatorSize: effectiveIndicatorSize,
              indicatorAnimationDuration: effectiveIndicatorAnimationDuration,
              onTap: onTap,
            ),
    );
  }
}

class _HorizontalBar<T extends SelectorEntry> extends StatelessWidget {
  const _HorizontalBar({
    super.key,
    required this.entries,
    required this.selectedCategories,
    required this.focusedIndex,
    required this.isScrollable,
    required this.padding,
    this.selectedColor,
    required this.labelStyle,
    required this.selectedLabelStyle,
    this.selectedTileColor,
    required this.indicatorColor,
    required this.indicatorHeight,
    required this.indicatorPadding,
    required this.indicatorSize,
    required this.indicatorAnimationDuration,
    required this.onTap,
  });

  final List<T> entries;
  final Set<T> selectedCategories;
  final int focusedIndex;

  final bool isScrollable;
  final EdgeInsetsGeometry padding;

  final Color? selectedColor;
  final TextStyle labelStyle;
  final TextStyle selectedLabelStyle;

  final Color? selectedTileColor;

  final Color indicatorColor;
  final double indicatorHeight;
  final EdgeInsetsGeometry indicatorPadding;
  final SelectorCategoryBarIndicatorSize indicatorSize;
  final Duration indicatorAnimationDuration;

  final ItemTapCallback onTap;

  double _measureLabelWidth(
      BuildContext context, String label, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
      maxLines: 1,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = List<Widget>.generate(entries.length, (int index) {
      final entry = entries[index] as SelectorCategoryEntry;
      final selected = selectedCategories.contains(entry);
      final label = entry.name ?? '';
      final textStyle = selected ? selectedLabelStyle : labelStyle;
      final fontSize = textStyle.fontSize ?? 14;

      Widget tab = InkWell(
        onTap: () => onTap(index, entry),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final resolvedIndicatorPadding =
                indicatorPadding.resolve(Directionality.of(context));
            final double maxIndicatorWidth =
                (constraints.maxWidth - resolvedIndicatorPadding.horizontal)
                    .clamp(0.0, double.infinity)
                    .toDouble();
            final double labelIndicatorWidth = _measureLabelWidth(
              context,
              label,
              textStyle,
            ).clamp(0.0, maxIndicatorWidth).toDouble();
            final double indicatorWidth =
                indicatorSize == SelectorCategoryBarIndicatorSize.label
                    ? labelIndicatorWidth
                    : maxIndicatorWidth;
            return Container(
              color: selected ? selectedTileColor : null,
              padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 6),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: textStyle,
                    strutStyle: StrutStyle(
                      fontSize: fontSize,
                      height: 20 / fontSize,
                      forceStrutHeight: true,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: indicatorPadding,
                    child: Align(
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: indicatorAnimationDuration,
                        curve: Curves.easeOut,
                        height: indicatorHeight,
                        width: selected ? indicatorWidth : 0,
                        decoration: BoxDecoration(
                          color: indicatorColor,
                          borderRadius:
                              BorderRadius.circular(indicatorHeight / 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      if (isScrollable) {
        const double horizontalPadding = 4.5;
        final double labelWidth = _measureLabelWidth(context, label, textStyle);
        tab = SizedBox(width: labelWidth + horizontalPadding * 2, child: tab);
      } else {
        tab = Expanded(child: tab);
      }

      return tab;
    });

    final row = Row(
      mainAxisSize: isScrollable ? MainAxisSize.min : MainAxisSize.max,
      children: tabs,
    );

    if (!isScrollable) {
      return row;
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: padding,
        child: row,
      ),
    );
  }
}

class _VerticalBar<T extends SelectorEntry> extends StatelessWidget {
  const _VerticalBar({
    required this.entries,
    required this.selectedCategories,
    required this.focusedIndex,
    required this.isScrollable,
    required this.padding,
    this.selectedTileColor,
    this.selectedColor,
    this.labelStyle,
    this.selectedLabelStyle,
    required this.onTap,
  });

  final List<T> entries;
  final Set<T> selectedCategories;
  final int focusedIndex;

  final bool isScrollable;
  final EdgeInsetsGeometry padding;

  final Color? selectedTileColor;

  final Color? selectedColor;
  final TextStyle? labelStyle;
  final TextStyle? selectedLabelStyle;

  final ItemTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tiles = List<Widget>.generate(entries.length, (int index) {
      final entry = entries[index];
      final selected = selectedCategories.contains(entry);
      final focused = focusedIndex == index;
      return SelectorListTile(
        label: entry.name ?? '',
        selected: focused,
        selectedTileColor: selectedTileColor,
        leading: Container(
          width: 12,
          alignment: Alignment.centerLeft,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: entry.hasChildren && selected
                  ? selectedColor
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ),
        onTap: () => onTap(index, entry),
      );
    });

    final column = LayoutBuilder(
      builder: (context, constraints) {
        if (!isScrollable && constraints.hasBoundedHeight) {
          return Column(
            children: tiles.map((tile) => Expanded(child: tile)).toList(),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: tiles,
        );
      },
    );

    if (!isScrollable) {
      return column;
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: padding,
        child: column,
      ),
    );
  }
}

/// Loading skeleton for [SelectorCategoryBar].
class SelectorCategoryBarSkeleton extends StatelessWidget {
  const SelectorCategoryBarSkeleton({
    super.key,
    this.scrollDirection = Axis.horizontal,
    this.size,
    this.padding,
    this.backgroundColor,
  });

  final Axis scrollDirection;

  final double? size;

  final EdgeInsetsGeometry? padding;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final SelectorCategoryBarTheme defaults =
        _SelectorCategoryBarDefaults(context);
    final theme = SelectorCategoryBarTheme.of(context);

    final effctiveSize = size ?? theme.size ?? defaults.size!;
    final width = scrollDirection == Axis.vertical ? effctiveSize : null;
    // final height = scrollDirection == Axis.horizontal ? effctiveSize : null;

    final effectivePadding = padding ?? theme.padding ?? defaults.padding!;

    final effectiveBackgroundColor =
        backgroundColor ?? theme.backgroundColor ?? defaults.backgroundColor!;

    return Container(
      width: width,
      // height: height,
      padding: effectivePadding,
      color: effectiveBackgroundColor,
      child: SkeletonBox(
        child: scrollDirection == Axis.vertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonTile(
                    width: double.infinity,
                    height: 40,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 10),
                  SkeletonTile(
                    width: double.infinity,
                    height: 40,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 10),
                  SkeletonTile(
                    width: double.infinity,
                    height: 40,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 10),
                  SkeletonTile(
                    width: double.infinity,
                    height: 40,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: SkeletonTile(
                      width: double.infinity,
                      height: 40,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 36),
                  Expanded(
                    child: SkeletonTile(
                      width: double.infinity,
                      height: 40,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SelectorCategoryBarDefaults extends SelectorCategoryBarTheme {
  _SelectorCategoryBarDefaults(this.context) : super();

  final BuildContext context;
  late final SelectorThemeData _theme = SelectorTheme.of(context);
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _theme.backgroundColor;

  @override
  double? get size => 80;

  @override
  EdgeInsetsGeometry? get padding => EdgeInsets.zero;

  @override
  Color? get selectedColor => _theme.selectedColor;

  @override
  TextStyle? get labelStyle => _textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        color: selectedColor,
      );

  @override
  TextStyle? get selectedLabelStyle => _textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        color: _theme.onBackgroundColorHighest,
      );

  @override
  Color? get indicatorColor => selectedColor;

  @override
  double? get indicatorHeight => 2;

  @override
  EdgeInsetsGeometry? get indicatorPadding => EdgeInsets.zero;

  @override
  SelectorCategoryBarIndicatorSize? get indicatorSize =>
      SelectorCategoryBarIndicatorSize.tab;

  @override
  Duration? get indicatorAnimationDuration => const Duration(milliseconds: 200);
}
