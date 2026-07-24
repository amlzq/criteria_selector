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

/// Reusable delegates keyed by the params that affect the delegate identity.
///
/// Column count / aspect ratio / spacing ARE part of the key: the grid and
/// flatten delegates read `crossAxisCount`, `childAspectRatio` and the spacings
/// from the delegate at build time (see [GridSelectorDelegate] /
/// [FlattenSelectorDelegate]), so
/// excluding them would keep reusing a stale delegate and make the Columns /
/// Aspect / Spacing controls have no effect.
///
/// The delegate is still cached so that changing *other* params (e.g. seed
/// color, theme) does not discard the applied selection stored in
/// [SelectorDelegate.selectedData]; only the params in this key recreate it.
String _delegateKey(
  PlaygroundLanguage language,
  PlaygroundParams p,
) =>
    '${language.name}|${p.layout}|${p.selectionMode}|${p.tileVariant}|'
    '${p.crossAxisCount}|${p.childAspectRatio}|${p.spacing}';

/// Selection-identity key: the params that define *which* selection state a
/// delegate carries. Column count / aspect ratio / spacing are intentionally
/// excluded — those only affect rendering and are handled by [buildDelegate]
/// so the applied selection survives a Columns / Aspect / Spacing tweak.
String _selectionKey(PlaygroundLanguage language, PlaygroundParams p) =>
    '${language.name}|${p.layout}|${p.selectionMode}|${p.tileVariant}';

/// Builds (or reuses) a [SelectorDelegate] for the current [PlaygroundParams].
///
/// The delegate is cached in [delegateCache] (keyed by the full param set,
/// including column count / aspect ratio / spacing) so changing those renders
/// with a delegate that actually carries the new values — the library reads
/// `crossAxisCount`, `childAspectRatio` and the spacings from the delegate at
/// build time.
///
/// Because [handleApply] writes the applied selection back to the delegate via
/// [SelectorDelegate.selectedData], recreating the delegate on a Columns /
/// Aspect / Spacing tweak would otherwise drop that state. [selectionCache]
/// (keyed by the selection-identity params only) keeps the most recent delegate
/// for a given selection, and its `selectedData` is carried over to the freshly
/// built delegate so reopening the panel still restores the selection.
SelectorDelegate buildDelegate(
  PlaygroundParams p,
  PlaygroundDataSource data,
  PlaygroundLanguage language, {
  required Map<String, SelectorDelegate> delegateCache,
  required Map<String, SelectorDelegate> selectionCache,
}) {
  final key = _delegateKey(language, p);
  final existing = delegateCache[key];
  if (existing != null) return existing;
  final delegate = _createDelegate(p, data);
  final previous = selectionCache[_selectionKey(language, p)];
  if (previous != null && previous != delegate) {
    delegate.selectedData = previous.selectedData;
  }
  delegateCache[key] = delegate;
  selectionCache[_selectionKey(language, p)] = delegate;
  return delegate;
}

SelectorDelegate _createDelegate(
    PlaygroundParams p, PlaygroundDataSource data) {
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
/// Wrapped in a stateful [EntryPointScreen] so the latest `onChanged` /
/// `onApplied` values can be captured and displayed in a footer panel.
///
/// Dialog / bottom-sheet triggers use a nested [Builder] context so that
/// [showSelector] / [showModalBottomSelector] pick up the phone's local
/// (parameter-driven) theme rather than the surrounding app theme.
Widget buildPhoneScreen(
  PlaygroundParams p,
  SelectorDelegate delegate,
  PlaygroundL10n l10n, {
  required PlaygroundDataSource data,
  required Map<String, SelectorDelegate> delegateCache,
  required Map<String, SelectorDelegate> selectionCache,
}) {
  // Keyed by the entry point so switching entry points resets the captured
  // callback results (each entry point exposes different callbacks).
  return EntryPointScreen(
    key: ValueKey(p.entryPoint),
    params: p,
    delegate: delegate,
    l10n: l10n,
    data: data,
    delegateCache: delegateCache,
    selectionCache: selectionCache,
  );
}

/// Stateful phone screen for a chosen entry point.
///
/// Besides rendering the trigger widget, it captures the latest values fired
/// by the selector's `onChanged` / `onApplied` callbacks and shows them in a
/// footer panel ([_ResultPanel]) so playground users can inspect what each
/// callback returns.
///
/// [SelectorBox] applies immediately and hides the action bar, so its
/// [SelectorBox.onChangeTap] is mirrored into both fields. [showSelector] /
/// [showModalBottomSelector] deliver their result through the returned
/// [Future], which is shown as the applied value (no `onChanged` exists for
/// these entry points).
class EntryPointScreen extends StatefulWidget {
  const EntryPointScreen({
    required this.params,
    required this.delegate,
    required this.l10n,
    required this.data,
    required this.delegateCache,
    required this.selectionCache,
    super.key,
  });

  final PlaygroundParams params;
  final SelectorDelegate delegate;
  final PlaygroundL10n l10n;
  final PlaygroundDataSource data;
  final Map<String, SelectorDelegate> delegateCache;
  final Map<String, SelectorDelegate> selectionCache;

  @override
  State<EntryPointScreen> createState() => _EntryPointScreenState();
}

class _EntryPointScreenState extends State<EntryPointScreen> {
  Object? _lastChanged;
  Object? _lastApplied;

  void _onChanged(Object? value) => setState(() => _lastChanged = value);
  void _onApplied(Object? value) => setState(() => _lastApplied = value);

  /// Builds a selector delegate for one tab of the dropdown bar, using the
  /// current playground params but a fixed layout family so each tab shows a
  /// distinct selector (cascading / grid / flatten / list).
  SelectorDelegate _tabDelegate(Layout layout) {
    final tabParams = widget.params.copyWith(layout: layout);
    return buildDelegate(
      tabParams,
      widget.data,
      widget.l10n.language,
      delegateCache: widget.delegateCache,
      selectionCache: widget.selectionCache,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.params;
    final l10n = widget.l10n;
    final resultPanel = _ResultPanel(
      l10n: l10n,
      changed: _lastChanged,
      applied: _lastApplied,
    );

    switch (p.entryPoint) {
      case EntryPoint.box:
        return Scaffold(
          appBar: AppBar(title: Text(l10n.phoneBoxTitle)),
          body: Column(
            children: <Widget>[
              Expanded(
                child: SelectorBox(
                  // The box owns a [SelectorController] that is created once from
                  // the delegate and NOT re-created on delegate changes. Key it by
                  // the params that must reset that controller (language / layout
                  // / selection mode / tile variant). Columns / aspect ratio /
                  // spacing are deliberately excluded: those now live in the
                  // delegate cache key, so changing them yields a *new* delegate
                  // object while the box stays mounted — `widget.delegate` updates
                  // live and [SelectorPanel] rebuilds with the new grid, and the
                  // box keeps its in-progress selection instead of losing it.
                  key: ValueKey(
                    '${l10n.language}|${p.layout}|${p.selectionMode}|'
                    '${p.tileVariant}',
                  ),
                  delegate: widget.delegate,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  onChangeTap: (selected) {
                    // SelectorBox applies immediately: change == apply.
                    _onChanged(selected);
                    _onApplied(selected);
                  },
                ),
              ),
              resultPanel,
            ],
          ),
        );
      case EntryPoint.dropdownBar:
        final tabDelegates = <SelectorDelegate>[
          _tabDelegate(Layout.cascading),
          _tabDelegate(Layout.grid),
          _tabDelegate(Layout.flatten),
          _tabDelegate(Layout.list),
        ];
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.phoneDropdownBarTitle),
            bottom: DropdownSelectorBar(
              tabs: <DropdownTab>[
                DropdownTab(label: l10n.layoutCascading),
                DropdownTab(label: l10n.layoutGrid),
                DropdownTab(label: l10n.layoutFlatten),
                DropdownTab(label: l10n.layoutList),
              ],
              selectorDelegates: tabDelegates,
              onChanged: (tabData, selected) => _onChanged(
                  DropdownSelectorResult(tabData: tabData, selected: selected)),
              onApplied: (tabData, selected) => _onApplied(
                  DropdownSelectorResult(tabData: tabData, selected: selected)),
            ),
          ),
          body: Column(
            children: <Widget>[
              Expanded(child: Center(child: Text(l10n.tapBarHint))),
              resultPanel,
            ],
          ),
        );
      case EntryPoint.dropdownButton:
        return Scaffold(
          appBar: AppBar(title: Text(l10n.phoneDropdownButtonTitle)),
          body: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: DropdownSelectorButton(
                    selectorDelegate: widget.delegate,
                    label: l10n.filterLabel,
                    onChanged: (tabData, selected) => _onChanged(
                        DropdownSelectorResult(
                            tabData: tabData, selected: selected)),
                    onApplied: (tabData, selected) => _onApplied(
                        DropdownSelectorResult(
                            tabData: tabData, selected: selected)),
                  ),
                ),
              ),
              resultPanel,
            ],
          ),
        );
      case EntryPoint.dialog:
        return Scaffold(
          appBar: AppBar(title: Text(l10n.phoneDialogTitle)),
          body: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Builder(
                    builder: (ctx) => FilledButton(
                      onPressed: () async {
                        final result = await showSelector(
                          context: ctx,
                          delegate: widget.delegate,
                          useRootNavigator: false,
                        );
                        _onApplied(result);
                      },
                      child: Text(l10n.openSelector),
                    ),
                  ),
                ),
              ),
              resultPanel,
            ],
          ),
        );
      case EntryPoint.bottomSheet:
        return Scaffold(
          appBar: AppBar(title: Text(l10n.phoneBottomSheetTitle)),
          body: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Builder(
                    builder: (ctx) => FilledButton(
                      onPressed: () async {
                        final result = await showModalBottomSelector(
                          context: ctx,
                          delegate: widget.delegate,
                        );
                        _onApplied(result);
                      },
                      child: Text(l10n.openSelector),
                    ),
                  ),
                ),
              ),
              resultPanel,
            ],
          ),
        );
    }
  }
}

/// Footer panel that shows the most recent `onChanged` / `onApplied` values
/// for the active entry point.
class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.l10n,
    this.changed,
    this.applied,
  });

  final PlaygroundL10n l10n;
  final Object? changed;
  final Object? applied;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final valueStyle = theme.textTheme.bodySmall;

    String format(Object? value) => value == null ? '—' : value.toString();

    return SizedBox(
      width: double.infinity,
      height: 112,
      child: DecoratedBox(
        decoration: BoxDecoration(color: background),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.resultPanelTitle, style: labelStyle),
              const SizedBox(height: 4),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${l10n.onChangedLabel}: ${format(changed)}',
                        style: valueStyle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.onAppliedLabel}: ${format(applied)}',
                        style: valueStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
