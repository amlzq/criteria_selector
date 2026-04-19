import 'package:flutter/material.dart';

import 'constants.dart';
import 'selector/cascading_selector.dart';
import 'selector/flatten_selector.dart';
import 'selector/grid_selector.dart';
import 'selector/list_selector.dart';
import 'selector/widgets/widgets.dart';
import 'selector_entry.dart';

/// Builds the action bar shown at the bottom of the selector panel.
///
/// Implementations should trigger [onResetTap] and [onApplyTap] from UI controls
/// (e.g. buttons).
typedef SelectorActionBarBuilder = Widget Function(
  BuildContext context, {
  required VoidCallback onResetTap,
  required VoidCallback onApplyTap,
});

/// Base configuration for a selector.
///
/// A [Selector] is responsible for:
/// - Defining how entries are fetched and restored (via fetcher callbacks).
/// - Defining UI/theme overrides (colors and per-widget themes).
/// - Building the selector body widget and a loading skeleton.
///
/// The actual selection state is managed by [SelectorController] and widgets
/// under `src/selector/`.
abstract class Selector {
  Selector({
    this.selectionMode = SelectionMode.single,
    this.dataFetcher,
    this.selectedDataFetcher,
    this.resetDataFetcher,
    this.actionBarBuilder,
    this.selectedColor,
    this.onSelectedColor,
    this.backgroundColor,
    this.onBackgroundColor,
    this.backgroundColorHigh,
    this.backgroundColorHighest,
    this.onBackgroundColorHighest,
    this.actionBarTheme,
    this.categoryBarTheme,
    this.gridTileTheme,
    this.listTileTheme,
    this.fieldTileTheme,
    this.chipBarThemeData,
    this.skeletonBuilder,
  });

  /// Selection mode applied to category entries.
  final SelectionMode selectionMode;

  /// Fetches the full selectable entries for this selector.
  ///
  /// When provided, the selector panel can display a loading skeleton while
  /// awaiting the result.
  final Future<SelectorEntries> Function()? dataFetcher;
  Future<SelectorEntries>? data;

  /// Returns the previously selected entries to restore.
  ///
  /// This is typically used for restoring state when reopening the selector.
  final SelectorEntries? Function()? selectedDataFetcher;
  SelectorEntries? selectedData;

  /// Returns the selection that should be used when "Reset" is tapped.
  final SelectorEntries? Function()? resetDataFetcher;
  SelectorEntries? resetData;

  /// Optional builder to customize the action bar UI.
  final SelectorActionBarBuilder? actionBarBuilder;

  /// The background color used for selected entries.
  final Color? selectedColor;

  /// Text/icon color used on top of [selectedColor].
  final Color? onSelectedColor;

  /// Base background color used by the selector panel.
  final Color? backgroundColor;

  /// Text/icon color used on top of [backgroundColor].
  final Color? onBackgroundColor;

  /// A higher-contrast background color used for elevated sections.
  final Color? backgroundColorHigh;

  /// The highest-contrast background color (often used for nested levels).
  final Color? backgroundColorHighest;

  /// Text/icon color used on top of [backgroundColorHighest].
  final Color? onBackgroundColorHighest;

  /// Theme overrides for the action bar widget.
  final SelectorActionBarTheme? actionBarTheme;

  /// Theme overrides for the category bar widget.
  final SelectorCategoryBarTheme? categoryBarTheme;

  /// Theme overrides for grid tiles.
  final SelectorGridTileTheme? gridTileTheme;

  /// Theme overrides for list tiles.
  final SelectorListTileTheme? listTileTheme;

  /// Theme overrides for range field tiles.
  final SelectorFieldTileTheme? fieldTileTheme;

  /// Theme overrides for the selected chips bar.
  final SelectorChipBarTheme? chipBarThemeData;

  /// Optional builder for the loading skeleton.
  final WidgetBuilder? skeletonBuilder;

  /// Builds the selector body widget.
  ///
  /// [entries] are the full selectable entries. [previousSelected] represents
  /// a previously applied selection, if any.
  Widget buildBody(
    BuildContext context,
    List<SelectorEntry> entries,
    Set<SelectorEntry>? previousSelected,
  );

  /// Builds the loading skeleton.
  Widget buildSkeleton(BuildContext context);
}

/// A cascading selector for tree-structured data.
///
/// This layout shows categories on the left and a cascading list to the right.
class CascadingSelector extends Selector {
  CascadingSelector({
    this.categoryBackgroundColor,
    this.terminalBackgroundColor,
    this.checkboxBuilder,
    this.radioBuilder,
    super.selectionMode = SelectionMode.single,
    super.dataFetcher,
    super.selectedDataFetcher,
    super.resetDataFetcher,
    super.actionBarBuilder,
    super.selectedColor,
    super.onSelectedColor,
    super.backgroundColor,
    super.onBackgroundColor,
    super.backgroundColorHigh,
    super.backgroundColorHighest,
    super.onBackgroundColorHighest,
    super.actionBarTheme,
    super.categoryBarTheme,
    super.gridTileTheme,
    super.listTileTheme,
    super.fieldTileTheme,
    super.chipBarThemeData,
    super.skeletonBuilder,
  });

  /// Background color used for the category column.
  final Color? categoryBackgroundColor;

  /// Background color used for the terminal (deepest) column.
  final Color? terminalBackgroundColor;

  /// Optional custom radio widget builder.
  final ToggleWidgetBuilder? radioBuilder;

  /// Optional custom checkbox widget builder.
  final ToggleWidgetBuilder? checkboxBuilder;

  @override
  Widget buildBody(
    BuildContext context,
    List<SelectorEntry> entries,
    Set<SelectorEntry>? previousSelected,
  ) {
    return CascadingSelectorView(
      entries: entries,
      previousSelected: previousSelected,
    );
  }

  @override
  Widget buildSkeleton(BuildContext context) {
    return skeletonBuilder?.call(context) ??
        CascadingSelectorSkeleton(backgroundColor: backgroundColor);
  }
}

/// A single-column list selector.
class ListSelector extends Selector {
  ListSelector({
    this.checkboxBuilder,
    this.radioBuilder,
    super.selectionMode = SelectionMode.single,
    super.dataFetcher,
    super.selectedDataFetcher,
    super.resetDataFetcher,
    super.actionBarBuilder,
    super.selectedColor,
    super.onSelectedColor,
    super.backgroundColor,
    super.onBackgroundColor,
    super.backgroundColorHigh,
    super.backgroundColorHighest,
    super.onBackgroundColorHighest,
    super.actionBarTheme,
    super.categoryBarTheme,
    super.gridTileTheme,
    super.listTileTheme,
    super.fieldTileTheme,
    super.chipBarThemeData,
    super.skeletonBuilder,
  });

  /// Optional custom radio widget builder.
  final ToggleWidgetBuilder? radioBuilder;

  /// Optional custom checkbox widget builder.
  final ToggleWidgetBuilder? checkboxBuilder;

  @override
  Widget buildBody(
    BuildContext context,
    List<SelectorEntry> entries,
    Set<SelectorEntry>? previousSelected,
  ) {
    return ListSelectorView(
      entries: entries,
      previousSelected: previousSelected,
    );
  }

  @override
  Widget buildSkeleton(BuildContext context) {
    return skeletonBuilder?.call(context) ??
        ListSelectorSkeleton(selectionMode: selectionMode);
  }
}

/// A grid selector.
class GridSelector extends Selector {
  GridSelector({
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.tileVariant,
    super.selectionMode = SelectionMode.single,
    super.dataFetcher,
    super.selectedDataFetcher,
    super.resetDataFetcher,
    super.actionBarBuilder,
    super.selectedColor,
    super.onSelectedColor,
    super.backgroundColor,
    super.onBackgroundColor,
    super.backgroundColorHigh,
    super.backgroundColorHighest,
    super.onBackgroundColorHighest,
    super.actionBarTheme,
    super.categoryBarTheme,
    super.gridTileTheme,
    super.listTileTheme,
    super.fieldTileTheme,
    super.chipBarThemeData,
    super.skeletonBuilder,
  });

  /// Number of columns in the grid.
  final int crossAxisCount;

  /// Spacing between rows.
  final double mainAxisSpacing;

  /// Spacing between columns.
  final double crossAxisSpacing;

  /// Child aspect ratio for each tile.
  final double childAspectRatio;

  /// Optional tile variant to control visual style.
  final SelectorGridTileVariant? tileVariant;

  @override
  Widget buildBody(
    BuildContext context,
    List<SelectorEntry> entries,
    Set<SelectorEntry>? previousSelected,
  ) {
    return GridSelectorView(
      entries: entries,
      previousSelected: previousSelected,
    );
  }

  @override
  Widget buildSkeleton(BuildContext context) {
    return skeletonBuilder?.call(context) ??
        GridSelectorSkeleton(
          itemCount: 15,
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        );
  }
}

/// A "flatten" selector that renders children in a grid while keeping the
/// hierarchy behavior.
class FlattenSelector extends Selector {
  FlattenSelector({
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    super.selectionMode = SelectionMode.single,
    super.dataFetcher,
    super.selectedDataFetcher,
    super.resetDataFetcher,
    super.actionBarBuilder,
    super.selectedColor,
    super.onSelectedColor,
    super.backgroundColor,
    super.onBackgroundColor,
    super.backgroundColorHigh,
    super.backgroundColorHighest,
    super.onBackgroundColorHighest,
    super.actionBarTheme,
    super.categoryBarTheme,
    super.gridTileTheme,
    super.listTileTheme,
    super.fieldTileTheme,
    super.chipBarThemeData,
    super.skeletonBuilder,
  });

  /// Number of columns in the flattened grid.
  final int crossAxisCount;

  /// Spacing between rows.
  final double mainAxisSpacing;

  /// Spacing between columns.
  final double crossAxisSpacing;

  /// Child aspect ratio for each tile.
  final double childAspectRatio;

  @override
  Widget buildBody(
    BuildContext context,
    List<SelectorEntry> entries,
    Set<SelectorEntry>? previousSelected,
  ) {
    return FlattenSelectorView(
      entries: entries,
      previousSelected: previousSelected,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
    );
  }

  @override
  Widget buildSkeleton(BuildContext context) {
    return skeletonBuilder?.call(context) ??
        PlattenSelectorSkeleton(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        );
  }
}
