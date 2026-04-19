import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../selector_entry.dart';
import '../selector_theme.dart';
import '../selector_theme_data.dart';
import 'category_bar_theme.dart';
import 'skeleton_box.dart';

/// Category bar used by cascading selectors.
///
/// The bar renders the category entries horizontally and indicates the current
/// selection via an animated indicator.
class SelectorCategoryBar<T extends SelectorEntry> extends StatelessWidget {
  const SelectorCategoryBar({
    super.key,
    required this.entries,
    required this.selectedCategoryIndex,
    this.padding,
    this.backgroundColor,
    this.selectedColor,
    this.labelStyle,
    this.unselectedLabelTextStyle,
    this.indicatorColor,
    this.indicatorHeight,
    this.indicatorPadding,
    this.indicatorSize,
    this.indicatorAnimationDuration,
    required this.onTap,
  });

  final List<T> entries;
  final int selectedCategoryIndex;

  final EdgeInsetsGeometry? padding;

  final Color? backgroundColor;
  final Color? selectedColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelTextStyle;

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

    final effectivePadding = padding ?? theme.padding ?? defaults.padding!;

    final effectiveBackgroundColor =
        backgroundColor ?? theme.backgroundColor ?? defaults.backgroundColor;

    final effectiveSelectedColor =
        selectedColor ?? theme.selectedColor ?? defaults.selectedColor!;

    final effectiveLabelTextStyle =
        labelStyle ?? theme.labelStyle ?? defaults.labelStyle;

    final effectiveUnselectedLabelTextStyle = unselectedLabelTextStyle ??
        theme.unselectedLabelTextStyle ??
        defaults.unselectedLabelTextStyle;

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

    return ColoredBox(
      color: effectiveBackgroundColor ?? Colors.transparent,
      child: Padding(
        padding: effectivePadding,
        child: Row(
          children: List.generate(entries.length, (int index) {
            final item = entries[index] as SelectorCategoryEntry;
            final selected = index == selectedCategoryIndex;
            final label = item.name ?? '';
            final textStyle = selected
                ? (effectiveLabelTextStyle ?? const TextStyle(fontSize: 14))
                    .copyWith(
                    color: effectiveLabelTextStyle?.color ??
                        theme.labelStyle?.color ??
                        effectiveSelectedColor,
                  )
                : (effectiveUnselectedLabelTextStyle ??
                        const TextStyle(fontSize: 14, color: Colors.black))
                    .copyWith(
                    color: effectiveUnselectedLabelTextStyle?.color ??
                        theme.unselectedLabelTextStyle?.color ??
                        Colors.black,
                  );
            final fontSize = textStyle.fontSize ?? 14;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(index, item),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final resolvedIndicatorPadding = effectiveIndicatorPadding
                        .resolve(Directionality.of(context));
                    final double maxIndicatorWidth = (constraints.maxWidth -
                            resolvedIndicatorPadding.horizontal)
                        .clamp(0.0, double.infinity)
                        .toDouble();
                    final double labelIndicatorWidth = _measureLabelWidth(
                      context,
                      label,
                      textStyle,
                    ).clamp(0.0, maxIndicatorWidth).toDouble();
                    final double indicatorWidth = effectiveIndicatorSize ==
                            SelectorCategoryBarIndicatorSize.label
                        ? labelIndicatorWidth
                        : maxIndicatorWidth;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.5, vertical: 6),
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
                            padding: effectiveIndicatorPadding,
                            child: Align(
                              alignment: Alignment.center,
                              child: AnimatedContainer(
                                duration: effectiveIndicatorAnimationDuration,
                                curve: Curves.easeOut,
                                height: effectiveIndicatorHeight,
                                width: selected ? indicatorWidth : 0,
                                decoration: BoxDecoration(
                                  color: effectiveIndicatorColor,
                                  borderRadius: BorderRadius.circular(
                                      effectiveIndicatorHeight / 2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

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
}

/// Loading skeleton for [SelectorCategoryBar].
class SelectorCategoryBarSkeleton extends StatelessWidget {
  const SelectorCategoryBarSkeleton({
    super.key,
    this.padding,
  });

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final SelectorCategoryBarTheme defaults =
        _SelectorCategoryBarDefaults(context);
    final effectivePadding = padding ?? defaults.padding!;
    return Padding(
      padding: effectivePadding,
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

class _SelectorCategoryBarDefaults extends SelectorCategoryBarTheme {
  _SelectorCategoryBarDefaults(this.context) : super();

  final BuildContext context;
  late final SelectorThemeData _theme = SelectorTheme.of(context);
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _theme.backgroundColor;

  @override
  EdgeInsetsGeometry? get padding =>
      const EdgeInsets.symmetric(vertical: 10, horizontal: 12);

  @override
  Color? get selectedColor => _theme.selectedColor;

  @override
  TextStyle? get labelStyle => _textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        color: selectedColor,
      );

  @override
  TextStyle? get unselectedLabelTextStyle => _textTheme.bodyMedium?.copyWith(
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
