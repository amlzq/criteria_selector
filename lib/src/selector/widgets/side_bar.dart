import 'package:flutter/material.dart';

import '../constants.dart';
import '../selector_entry.dart';
import '../selector_theme.dart';
import '../selector_theme_data.dart';
import 'badge.dart';
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

  /// The category entries to display as tiles in this sidebar.
  ///
  /// Each entry renders a [SelectorListTile]; the number of tiles equals the
  /// length of this list.
  final List<T> entries;

  /// The set of currently selected categories.
  ///
  /// A tile is rendered as selected when its entry is contained in this set,
  /// and its badge is shown accordingly.
  final Set<T> selectedCategories;

  /// The index of the tile that should be considered focused.
  ///
  /// The focused tile is highlighted via its selected appearance; this does
  /// not by itself change [selectedCategories].
  final int focusedIndex;

  /// The width of the sidebar.
  ///
  /// If null, [SelectorSideBarTheme.width] is used. If that is also null, the
  /// default is 80.0.
  final double? width;

  /// The color of the sidebar itself.
  ///
  /// If null, [SelectorSideBarTheme.backgroundColor] is used. If that is also
  /// null, the value is [SelectorThemeData.backgroundColor].
  final Color? backgroundColor;

  /// The padding around the sidebar's tiles.
  ///
  /// If null, [SelectorSideBarTheme.padding] is used. If that is also null, the
  /// value is [EdgeInsets.zero]. When [isScrollable] is true, this padding is
  /// ignored in favor of the inner scroll view's padding.
  final EdgeInsetsGeometry? padding;

  /// Whether this sidebar can be scrolled vertically.
  ///
  /// If true, the tiles are laid out at their natural height inside a scroll
  /// view. If false (the default), the tiles are expanded to divide the
  /// available height equally when the sidebar has a bounded height.
  final bool isScrollable;

  /// The color of the tile labels and badge when a tile is selected.
  ///
  /// If null, [SelectorSideBarTheme.selectedColor] is used. If that is also
  /// null, the value is [SelectorThemeData.selectedColor].
  final Color? selectedColor;

  /// The text style of the tile labels.
  ///
  /// If null, [SelectorSideBarTheme.labelStyle] is used. If that is also null,
  /// the value is [TextTheme.bodyLarge].
  final TextStyle? labelStyle;

  /// The background color of the selected tile.
  ///
  /// If null, [SelectorSideBarTheme.selectedTileColor] is used. If that is also
  /// null, no tile background is applied.
  final Color? selectedTileColor;

  /// Called when a tile is tapped.
  ///
  /// The callback receives the tapped tile's index and its [SelectorEntry].
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
        leading: SelectorBadge(
            color: entry.hasChildren && selected
                ? selectedColor
                : Colors.transparent),
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

  /// The width of the skeleton sidebar.
  ///
  /// If null, [SelectorSideBarTheme.width] is used. If that is also null, the
  /// default is 80.0.
  final double? width;

  /// The padding around the skeleton's tiles.
  ///
  /// If null, [SelectorSideBarTheme.padding] is used. If that is also null, the
  /// value is [EdgeInsets.zero].
  final EdgeInsetsGeometry? padding;

  /// The background color of the skeleton sidebar.
  ///
  /// If null, [SelectorSideBarTheme.backgroundColor] is used. If that is also
  /// null, the value is [SelectorThemeData.backgroundColor].
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
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
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
  TextStyle? get labelStyle => _textTheme.bodyLarge;

  @override
  TextStyle? get selectedLabelStyle => _textTheme.bodyMedium?.copyWith(
        color: _theme.selectedColor,
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
