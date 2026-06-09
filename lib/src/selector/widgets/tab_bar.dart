import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../selector_entry.dart';
import '../selector_theme.dart';
import '../selector_theme_data.dart';
import 'skeleton_box.dart';
import 'tab_bar_theme.dart';

@immutable
enum SelectorTabBarIndicatorSize {
  tab,
  label,
}

class SelectorTabBar<T extends SelectorEntry> extends StatelessWidget {
  const SelectorTabBar({
    super.key,
    required this.entries,
    required this.selectedCategories,
    required this.focusedIndex,
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

  final EdgeInsetsGeometry? padding;

  final bool isScrollable;

  final Color? backgroundColor;

  /// Selected color for text.
  final Color? selectedColor;

  final TextStyle? labelStyle;

  final TextStyle? selectedLabelStyle;

  final Color? selectedTileColor;

  /// The color of the line that appears below the selected tab.
  final Color? indicatorColor;

  final double? indicatorHeight;

  /// The padding for the indicator.
  final EdgeInsetsGeometry? indicatorPadding;

  /// Defines how the selected tab indicator's size is computed.
  final SelectorTabBarIndicatorSize? indicatorSize;

  final Duration? indicatorAnimationDuration;

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
    final SelectorTabBarTheme defaults = _SelectorTabBarDefaults(context);
    final theme = SelectorTabBarTheme.of(context);

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

    final tabs = List<Widget>.generate(entries.length, (int index) {
      final entry = entries[index] as SelectorCategoryEntry;
      final selected = selectedCategories.contains(entry);
      final label = entry.name ?? '';
      final textStyle = selected ? selectedLabelStyle : labelStyle;

      Widget tab = _Tab(
        label: label,
        isScrollable: isScrollable,
        selected: selected,
        padding: effectivePadding,
        selectedColor: effectiveSelectedColor,
        textStyle: effectiveLabelStyle,
        selectedLabelStyle: effectiveSelectedLabelStyle,
        selectedTileColor: effectiveSelectedTileColor,
        indicatorColor: effectiveIndicatorColor,
        indicatorHeight: effectiveIndicatorHeight,
        indicatorPadding: effectiveIndicatorPadding,
        indicatorSize: effectiveIndicatorSize,
        indicatorAnimationDuration: effectiveIndicatorAnimationDuration,
        onTap: () => onTap(index, entry),
      );

      if (isScrollable) {
        const double horizontalPadding = 4.5;
        final double labelWidth =
            _measureLabelWidth(context, label, effectiveLabelStyle);
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

    return Container(
      padding: containerPadding,
      color: effectiveBackgroundColor,
      child: isScrollable
          ? ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(overscroll: false),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                padding: padding,
                child: row,
              ),
            )
          : row,
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isScrollable,
    required this.selected,
    required this.padding,
    required this.selectedColor,
    required this.textStyle,
    required this.selectedLabelStyle,
    required this.selectedTileColor,
    required this.indicatorColor,
    required this.indicatorHeight,
    required this.indicatorPadding,
    required this.indicatorSize,
    required this.indicatorAnimationDuration,
    required this.onTap,
  });

  final String label;

  final bool selected;

  final bool isScrollable;

  final EdgeInsetsGeometry padding;

  final Color? selectedColor;

  final TextStyle textStyle;

  final TextStyle selectedLabelStyle;

  final Color? selectedTileColor;

  final Color indicatorColor;

  final double indicatorHeight;

  final EdgeInsetsGeometry indicatorPadding;

  final SelectorTabBarIndicatorSize indicatorSize;

  final Duration indicatorAnimationDuration;

  final GestureTapCallback onTap;

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
    final fontSize = textStyle.fontSize ?? 14;
    return InkWell(
      onTap: onTap,
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
              indicatorSize == SelectorTabBarIndicatorSize.label
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
  }
}

/// Loading skeleton for [SelectorTabBar].
class SelectorTabBarSkeleton extends StatelessWidget {
  const SelectorTabBarSkeleton({
    super.key,
    this.padding,
    this.backgroundColor,
  });

  final EdgeInsetsGeometry? padding;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final SelectorTabBarTheme defaults = _SelectorTabBarDefaults(context);
    final theme = SelectorTabBarTheme.of(context);

    final effectivePadding = padding ?? theme.padding ?? defaults.padding!;

    final effectiveBackgroundColor =
        backgroundColor ?? theme.backgroundColor ?? defaults.backgroundColor!;

    return Container(
      padding: effectivePadding,
      color: effectiveBackgroundColor,
      child: SkeletonBox(
        child: Row(
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

class _SelectorTabBarDefaults extends SelectorTabBarTheme {
  _SelectorTabBarDefaults(this.context) : super();

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
  SelectorTabBarIndicatorSize? get indicatorSize =>
      SelectorTabBarIndicatorSize.tab;

  @override
  Duration? get indicatorAnimationDuration => const Duration(milliseconds: 200);
}
