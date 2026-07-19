import 'package:criteria_selector/criteria_selector.dart';
import 'package:flutter/material.dart';

import '../leyoujia/house_filters_repository.dart' as leyoujia;
import '../my_widgets.dart';
import '../zillow/house_filters_repository.dart' as zillow;
import 'playground_l10n.dart';
import 'playground_params.dart';

SelectorGridTileVariant _gridVariant(TileVariant v) => v == TileVariant.outlined
    ? SelectorGridTileVariant.outlined
    : SelectorGridTileVariant.filled;

SelectorChipVariant _chipVariant(TileVariant v) => v == TileVariant.outlined
    ? SelectorChipVariant.outlined
    : SelectorChipVariant.filled;

Widget _radioBuilder(BuildContext context, bool selected) =>
    MyRadio(value: selected);

Widget _checkboxBuilder(BuildContext context, bool selected) =>
    MyCheckbox(value: selected);

/// Loader trio (entries / current selection / reset selection) for a single
/// layout family. Keeping them together lets the playground swap the whole demo
/// data set (Zillow ↔ Leyoujia) behind one interface.
class LayoutLoaders {
  final Future<SelectorEntries> Function() entries;
  final SelectorEntries? Function() selected;
  final SelectorEntries? Function() reset;

  const LayoutLoaders({
    required this.entries,
    required this.selected,
    required this.reset,
  });
}

/// Abstracts the demo data set used by the playground so the same delegate
/// builder works for both the English (Zillow) and Simplified Chinese
/// (Leyoujia) data.
class PlaygroundDataSource {
  final LayoutLoaders cascading;
  final LayoutLoaders grid;
  final LayoutLoaders flatten;
  final LayoutLoaders list;

  const PlaygroundDataSource({
    required this.cascading,
    required this.grid,
    required this.flatten,
    required this.list,
  });

  /// English demo → Zillow data.
  factory PlaygroundDataSource.zillow(zillow.HouseFiltersRepository repo) {
    return PlaygroundDataSource(
      cascading: LayoutLoaders(
        entries: repo.fetchNeighborhoodData,
        selected: repo.fetchNeighborhoodSelectedData,
        reset: repo.fetchNeighborhoodResetData,
      ),
      grid: LayoutLoaders(
        entries: repo.fetchRoomsData,
        selected: repo.fetchRoomsSelectedData,
        reset: repo.fetchRoomsResetData,
      ),
      flatten: LayoutLoaders(
        entries: repo.fetchMoreData,
        selected: repo.fetchMoreSelectedData,
        reset: repo.fetchMoreResetData,
      ),
      list: LayoutLoaders(
        entries: repo.fetchSortData,
        selected: repo.fetchSortSelectedData,
        reset: repo.fetchSortResetData,
      ),
    );
  }

  /// Simplified Chinese demo → Leyoujia data.
  factory PlaygroundDataSource.leyoujia(leyoujia.HouseFiltersRepository repo) {
    return PlaygroundDataSource(
      cascading: LayoutLoaders(
        entries: repo.fetchRegionData,
        selected: repo.fetchRegionSelectedData,
        reset: repo.fetchRegionResetData,
      ),
      grid: LayoutLoaders(
        entries: repo.fetchBuyPriceData,
        selected: repo.fetchBuyPriceSelectedData,
        reset: repo.fetchBuyPriceResetData,
      ),
      flatten: LayoutLoaders(
        entries: repo.fetchFloorPlanBuyData,
        selected: repo.fetchFloorPlanBuySelectedData,
        reset: repo.fetchFloorPlanBuyResetData,
      ),
      list: LayoutLoaders(
        entries: repo.fetchSortBuyData,
        selected: repo.fetchSortBuySelectedData,
        reset: repo.fetchSortBuyResetData,
      ),
    );
  }
}

/// Builds a [SelectorDelegate] for the current [PlaygroundParams], reusing the
/// data loaders from the active [PlaygroundDataSource].
SelectorDelegate buildDelegate(PlaygroundParams p, PlaygroundDataSource data) {
  final chipBarTheme =
      SelectorChipBarTheme(variant: _chipVariant(p.tileVariant));

  switch (p.layout) {
    case Layout.cascading:
      return CascadingSelectorDelegate(
        entriesLoader: data.cascading.entries,
        selectedEntriesLoader: data.cascading.selected,
        resetEntriesLoader: data.cascading.reset,
        selectionMode: p.selectionMode,
        radioBuilder: _radioBuilder,
        checkboxBuilder: _checkboxBuilder,
        chipBarTheme: chipBarTheme,
      );
    case Layout.grid:
      // Grid / Flatten delegates use the default radio & checkbox widgets, so
      // the custom [MyRadio]/[MyCheckbox] builders are not forwarded here.
      return GridSelectorDelegate(
        entriesLoader: data.grid.entries,
        selectedEntriesLoader: data.grid.selected,
        resetEntriesLoader: data.grid.reset,
        selectionMode: p.selectionMode,
        crossAxisCount: p.crossAxisCount,
        childAspectRatio: p.childAspectRatio,
        crossAxisSpacing: p.spacing,
        mainAxisSpacing: p.spacing,
        gridTileTheme:
            SelectorGridTileTheme(variant: _gridVariant(p.tileVariant)),
        chipBarTheme: chipBarTheme,
      );
    case Layout.flatten:
      return FlattenSelectorDelegate(
        entriesLoader: data.flatten.entries,
        selectedEntriesLoader: data.flatten.selected,
        resetEntriesLoader: data.flatten.reset,
        selectionMode: p.selectionMode,
        crossAxisCount: p.crossAxisCount,
        childAspectRatio: p.childAspectRatio,
        crossAxisSpacing: p.spacing,
        mainAxisSpacing: p.spacing,
        gridTileTheme:
            SelectorGridTileTheme(variant: _gridVariant(p.tileVariant)),
        chipBarTheme: chipBarTheme,
      );
    case Layout.list:
      return ListSelectorDelegate(
        entriesLoader: data.list.entries,
        selectedEntriesLoader: data.list.selected,
        resetEntriesLoader: data.list.reset,
        selectionMode: p.selectionMode,
        listTileTheme: const SelectorListTileTheme(),
        radioBuilder: _radioBuilder,
        checkboxBuilder: _checkboxBuilder,
        chipBarTheme: chipBarTheme,
      );
  }
}

/// Builds the widget shown on the phone screen for the chosen entry point.
///
/// Dialog / bottom-sheet triggers use a nested [Builder] context so that
/// [showSelector] / [showModalBottomSelector] pick up the phone's local
/// (parameter-driven) theme rather than the surrounding app theme.
Widget buildPhoneScreen(
  PlaygroundParams p,
  SelectorDelegate delegate,
  PlaygroundL10n l10n,
) {
  switch (p.entryPoint) {
    case EntryPoint.box:
      return Scaffold(
        appBar: AppBar(title: Text(l10n.phoneBoxTitle)),
        body: SelectorBox(
          // [SelectorBox] builds its [SelectorController] once from the
          // delegate (selection mode + initial/reset selection) and never
          // updates it on delegate changes. Key the box by the delegate-
          // affecting params so it re-initializes from the current delegate
          // whenever those change.
          key: ValueKey(
            '${l10n.language}|${p.layout}|${p.selectionMode}|${p.tileVariant}|'
            '${p.crossAxisCount}|${p.childAspectRatio}|${p.spacing}',
          ),
          delegate: delegate,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    case EntryPoint.dropdownBar:
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.phoneDropdownBarTitle),
          bottom: DropdownSelectorBar(
            tabs: <DropdownTab>[DropdownTab(label: l10n.filterLabel)],
            selectorDelegates: <SelectorDelegate>[delegate],
          ),
        ),
        body: Center(
          child: Text(l10n.tapBarHint),
        ),
      );
    case EntryPoint.dropdownButton:
      return Scaffold(
        appBar: AppBar(title: Text(l10n.phoneDropdownButtonTitle)),
        body: Center(
          child: DropdownSelectorButton(
            selectorDelegate: delegate,
            label: l10n.filterLabel,
          ),
        ),
      );
    case EntryPoint.dialog:
      return Scaffold(
        appBar: AppBar(title: Text(l10n.phoneDialogTitle)),
        body: Center(
          child: Builder(
            builder: (ctx) => FilledButton(
              onPressed: () => showSelector(
                context: ctx,
                delegate: delegate,
                useRootNavigator: false,
              ),
              child: Text(l10n.openSelector),
            ),
          ),
        ),
      );
    case EntryPoint.bottomSheet:
      return Scaffold(
        appBar: AppBar(title: Text(l10n.phoneBottomSheetTitle)),
        body: Center(
          child: Builder(
            builder: (ctx) => FilledButton(
              onPressed: () =>
                  showModalBottomSelector(context: ctx, delegate: delegate),
              child: Text(l10n.openSelector),
            ),
          ),
        ),
      );
  }
}
