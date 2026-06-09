import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../selector_entry.dart';
import '../selector_theme.dart';
import '../selector_theme_data.dart';
import 'list_tile.dart';
import 'side_bar_theme.dart';
import 'skeleton_box.dart';

class SelectorSideBar<T extends SelectorEntry> extends StatelessWidget {
  const SelectorSideBar({
    super.key,
    required this.entries,
    required this.selectedCategories,
    required this.focusedIndex,
    this.width,
    this.backgroundColor,
    this.padding,
    this.isScrollable = false,
    this.selectedColor,
    this.labelStyle,
    this.selectedTileColor,
    required this.onTap,
  });

  final List<T> entries;

  final Set<T> selectedCategories;

  final int focusedIndex;

  final double? width;

  final Color? backgroundColor;

  final EdgeInsetsGeometry? padding;

  final bool isScrollable;

  /// Selected color for text.
  final Color? selectedColor;

  final TextStyle? labelStyle;

  final Color? selectedTileColor;

  final ItemTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SelectorSideBarTheme defaults = _SelectorSideBarDefaults(context);
    final theme = SelectorSideBarTheme.of(context);

    final effectiveBackgroundColor =
        backgroundColor ?? theme.backgroundColor ?? defaults.backgroundColor!;

    final effectivePadding = padding ?? theme.padding ?? defaults.padding!;
    final containerPadding = isScrollable ? EdgeInsets.zero : effectivePadding;

    final effctiveWidth = width ?? theme.width ?? defaults.width!;

    final effectiveSelectedColor =
        selectedColor ?? theme.selectedColor ?? defaults.selectedColor!;

    final effectiveLabelStyle =
        labelStyle ?? theme.labelStyle ?? defaults.labelStyle!;

    final effectiveSelectedTileColor = selectedTileColor ??
        theme.selectedTileColor ??
        defaults.selectedTileColor;

    final tiles = List<Widget>.generate(entries.length, (int index) {
      final entry = entries[index];
      final selected = selectedCategories.contains(entry);
      final focused = focusedIndex == index;
      return SelectorListTile(
        label: entry.name ?? '',
        selected: focused,
        labelStyle: effectiveLabelStyle,
        selectedColor: effectiveSelectedColor,
        selectedTileColor: effectiveSelectedTileColor,
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
        return Column(mainAxisSize: MainAxisSize.min, children: tiles);
      },
    );

    return Container(
      width: effctiveWidth,
      padding: containerPadding,
      color: effectiveBackgroundColor,
      child: isScrollable
          ? ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(overscroll: false),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: padding,
                child: column,
              ),
            )
          : column,
    );
  }
}

/// Loading skeleton for [SelectorSideBar].
class SelectorSideBarSkeleton extends StatelessWidget {
  const SelectorSideBarSkeleton({
    super.key,
    this.width,
    this.padding,
    this.backgroundColor,
  });

  final double? width;

  final EdgeInsetsGeometry? padding;

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final SelectorSideBarTheme defaults = _SelectorSideBarDefaults(context);
    final theme = SelectorSideBarTheme.of(context);

    final effctiveWidth = width ?? theme.width ?? defaults.width!;

    final effectivePadding = padding ?? theme.padding ?? defaults.padding!;

    final effectiveBackgroundColor =
        backgroundColor ?? theme.backgroundColor ?? defaults.backgroundColor!;

    return Container(
      width: effctiveWidth,
      padding: effectivePadding,
      color: effectiveBackgroundColor,
      child: SkeletonBox(
        child: Column(
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
        ),
      ),
    );
  }
}

class _SelectorSideBarDefaults extends SelectorSideBarTheme {
  _SelectorSideBarDefaults(this.context) : super();

  final BuildContext context;
  late final SelectorThemeData _theme = SelectorTheme.of(context);
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _theme.backgroundColor;

  @override
  double? get width => 80;

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
  Duration? get indicatorAnimationDuration => const Duration(milliseconds: 200);
}
