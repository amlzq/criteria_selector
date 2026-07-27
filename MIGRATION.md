# Migration Guide

## MIGRATE TO Next

The i18n classes were renamed to drop the redundant `Criteria` prefix. This is a
pure rename — each old symbol is the exact same type as its new counterpart, so
simply replace the name in your code.

| Old | New |
| --- | --- |
| `CriteriaSelectorLocalizations` | `SelectorLocalizations` |
| `CriteriaSelectorLocalizationsDelegate` | `SelectorLocalizationsDelegate` |

### `DropdownSelectorResultCallback` / `DropdownTabLabelGetter` now take `(tabData, selected)`

`DropdownSelectorResultCallback` and `DropdownTabLabelGetter` previously received a
single `DropdownSelectorResult`. They now receive the tab metadata and the selected
entries directly:

```dart
// Before
DropdownSelectorBar(
  onChanged: (DropdownSelectorResult result) { /* ... */ },
  onApplied: (DropdownSelectorResult result) { /* ... */ },
);

// After
DropdownSelectorBar(
  onChanged: (DropdownTabData tabData, SelectorEntries selected) { /* ... */ },
  onApplied: (DropdownTabData tabData, SelectorEntries selected) { /* ... */ },
);
```

`DropdownTabLabelGetter` changes the same way:

```dart
// Before
DropdownTab(labelGetter: (DropdownSelectorResult result) => '...');

// After
DropdownTab(labelGetter: (DropdownTabData tabData, SelectorEntries selected) => '...');
```

The `DropdownSelectorResult` class is unchanged and is still useful for querying the
selection (for example `childIdsOf`, `firstSelectedId`). To keep an existing legacy
callback with minimal changes, wrap it with the new adapter helpers:

```dart
onChanged: fromLegacyResultCallback((DropdownSelectorResult result) {
  // existing legacy code that uses `result`
}),
```

Backward compatibility is also preserved on `DropdownSelectorController`:
`onChanged` / `onApplied` still accept the legacy `void Function(DropdownSelectorResult)`
signature (they are deprecated and will be removed in a future major version), so
existing `addChangeListener` / `addApplyListener` call sites that you have not yet
migrated continue to compile.

### `DropdownSelectorResult` is deprecated

The `DropdownSelectorResult` class still works, but it is now deprecated and will be
removed in a future major version. You only need to construct it to keep an existing
legacy `void Function(DropdownSelectorResult)` callback working. Prefer consuming the
tab metadata and the selected entries directly:

```dart
// Before
DropdownSelectorBar(
  onApplied: (DropdownSelectorResult result) {
    final ids = result.childIdsOf('bedrooms');
    final tabIndex = result.tabIndex;
  },
);

// After — read the values straight from the arguments
DropdownSelectorBar(
  onApplied: (DropdownTabData tabData, SelectorEntries selected) {
    final ids = selected.childIdsOf('bedrooms');
    final tabIndex = tabData.index;
  },
);
```

The convenience accessors previously provided by `DropdownSelectorResult` all have a
direct equivalent:

| `DropdownSelectorResult` | Replacement |
| --- | --- |
| `result.tabData` | the `tabData` argument |
| `result.selected` | the `selected` argument |
| `result.tabIndex` | `tabData.index` |
| `result.tabTag` | `tabData.tag` |
| `result.childIdsOf(id)` | `selected.childIdsOf(id)` |
| `result.childRangesOf(id)` | `selected.childRangesOf(id)` |
| `result.firstSelectedId` | `selected.firstSelectedId` |
| `result.cascadingPairsOf(firstId)` | `selected.cascadingPairsOf(firstId)` |
| `result.findCategory(...)` | `selected.findCategory(...)` |
| `result.findIdsAtLevel(...)` | `selected.findIdsAtLevel(...)` |
| `result.findChildrenAtLevel(...)` | `selected.findChildrenAtLevel(...)` |
| `result.findExtrasAtLevel(...)` | `selected.findExtrasAtLevel(...)` |

If you must keep a legacy handler untouched for now, wrap it with `fromLegacyResultCallback`
(see the previous section). The `DropselectResult` rename alias is deprecated as well.

### `DropdownSelectorButton` no longer exposes tab metadata

`DropdownSelectorButton` is a single trigger with no tab concept, so its
lifecycle callbacks no longer receive `DropdownTabData` (or a `tabData` argument):

| Callback | Before | After |
| --- | --- | --- |
| `onChanged` | `void Function(DropdownTabData, SelectorEntries)` | `void Function(SelectorEntries)` (typedef `SelectorResultCallback`) |
| `onApplied` | `void Function(DropdownTabData, SelectorEntries)` | `void Function(SelectorEntries)` |
| `onSelectorShowed` / `onSelectorHidden` | `void Function(DropdownTabData)` | `void Function()` |
| `onSelectorWillShow` / `onSelectorWillHide` | `FutureOr<bool> Function(DropdownTabData)` | `FutureOr<bool> Function()` |

Internally the button now stores a `SelectorLabelState` (a new, tab-agnostic base
class) instead of a faked `DropdownTabData(index: 0, ...)`. `DropdownSelectorBar`
is unaffected — it still uses `DropdownTabData` and the `(tabData, selected)`
callbacks.

```dart
// Before
DropdownSelectorButton(
  onChanged: (tabData, selected) {
    final result = DropdownSelectorResult(tabData: tabData, selected: selected);
    _handle(result);
  },
  onSelectorShowed: (tabData) { /* ... */ },
);

// After
DropdownSelectorButton(
  onChanged: (selected) {
    _handle(selected);
  },
  onSelectorShowed: () { /* ... */ },
);
```

If you previously keyed behaviour off `tabData.index` to distinguish multiple
buttons, give each button its own handler (or a domain argument) instead — the
`index` branch was always `0` for a standalone button and is no longer available.

### `DropdownTab.labelLoader` now takes `(selected)` instead of `(tabData, selected)`

The label builder has been refactored to the tab-agnostic typedef
`SelectorLabelLoader` (`String Function(SelectorEntries selected)`). The old
`DropdownTabLabelGetter` (`String Function(DropdownTabData, SelectorEntries)`)
is kept as a deprecated alias for backward compatibility.

| API | Before | After |
| --- | --- | --- |
| `DropdownTab.labelLoader` | `DropdownTabLabelGetter?` (`(tabData, selected)`) | `SelectorLabelLoader?` (`(selected)`) |
| `DropdownTabData.labelGetter` | `DropdownTabLabelGetter?` | `SelectorLabelLoader?` (getter; also keeps `labelLoader` / `legacyLabelGetter`) |

Migration options:

```dart
// 1. New canonical form — drop the unused tabData argument
DropdownTab(
  label: 'Price',
  labelLoader: (SelectorEntries selected) => '${selected.length} selected',
);

// 2. Keep a legacy (tabData, selected) getter compiling — wrap with the adapter
DropdownTab(
  label: 'Price',
  labelLoader: fromTabLabelGetter((tabData, selected) => '...'),
);

// 3. Keep receiving the live tab metadata losslessly — use the legacy field
DropdownTab(
  label: 'Price',
  legacyLabelGetter: (tabData, selected) => '${tabData.tag}: ${selected.length}',
);
```

`fromTabLabelGetter` drops the tab metadata (a placeholder tab is passed), so
getters that relied on `tabData` should use `legacyLabelGetter` (option 3), which
forwards the live `DropdownTabData`, or be rewritten to the new signature.

## MIGRATE TO 0.2.0
The old names are kept as deprecated type/constant/parameter aliases during the deprecation period and will be removed in the next major version.

> The rename tables below (`Dropselect*` → `Dropdown*`, `Selector*` →
> `*Delegate`, and the loader parameters) are **pure renames** — each old symbol
> is the exact same type/value as its new counterpart, so simply replace the name
> in your code. The `SelectorCategoryBar*` section is a widget split, not a
> rename; follow its mapping notes instead.

### Dropselect* → Dropdown* / DropdownSelector*

The public API was renamed from `Dropselect*` to `Dropdown*` / `DropdownSelector*` for clarity.

| Old | New |
| --- | --- |
| `DropselectTabBar` | `DropdownSelectorBar` |
| `DropselectTab` | `DropdownTab` |
| `DropselectTabBarTheme` | `DropdownSelectorBarTheme` |
| `DropselectTabController` | `DropdownSelectorController` |
| `DropselectTabControllerProvider` | `DropdownSelectorControllerProvider` |
| `DropselectTabData` | `DropdownTabData` |
| `DropselectResult` | `DropdownSelectorResult` |
| `DropselectOverlay` | `DropdownOverlay` |
| `DropselectOverlayStyle` | `DropdownOverlayStyle` |
| `DropselectResultCallback` | `DropdownSelectorResultCallback` |
| `DropselectTabLabelGetter` | `DropdownTabLabelGetter` |
| `kDropselectTabBarHeight` | `kDropdownSelectorBarHeight` |
| `kDropselectOverlayMaxHeightFactor` | `kDropdownOverlayMaxHeightFactor` |

### `Selector` types → `*Delegate`

The selector configuration types were renamed with a `Delegate` suffix to better
convey their role. The `DropdownSelectorBar.selectors` parameter was likewise
renamed to `selectorDelegates`.

| Old | New |
| --- | --- |
| `Selector` | `SelectorDelegate` |
| `CascadingSelector` | `CascadingSelectorDelegate` |
| `ListSelector` | `ListSelectorDelegate` |
| `GridSelector` | `GridSelectorDelegate` |
| `FlattenSelector` | `FlattenSelectorDelegate` |
| `DropselectTabBar(selectors: ...)` | `DropdownSelectorBar(selectorDelegates: ...)` |
| `DropselectTabController.previousSelector` | `DropdownSelectorController.previousSelectorDelegate` |
| `DropselectTabController.attachSelectors(...)` | `DropdownSelectorController.attachSelectorDelegates(...)` |
| `CascadingSelector.selector` / `ListSelector.selector` / `GridSelector.selector` / `FlattenSelector.selector` | `CascadingSelector.delegate` / `ListSelector.delegate` / `GridSelector.delegate` / `FlattenSelector.delegate` |

### Loader parameter names

The loader parameters on `SelectorDelegate` were renamed for consistency.

| Old | New |
| --- | --- |
| `SelectorDelegate.dataFetcher` | `SelectorDelegate.entriesLoader` |
| `SelectorDelegate.selectedDataFetcher` | `SelectorDelegate.selectedEntriesLoader` |
| `SelectorDelegate.resetDataFetcher` | `SelectorDelegate.resetEntriesLoader` |

### SelectorCategoryBar* → TabBar / SideBar

`SelectorCategoryBar` was split into a horizontal `SelectorTabBar` and a
vertical `SelectorSideBar`; the old `scrollDirection` axis is now chosen by
which widget you instantiate. The matching skeleton and theme types were split
the same way, and `SelectorThemeData.categoryBarTheme` was replaced by
`tabBarTheme` / `sideBarTheme`. This is **not** a pure rename — map each
symbol and property to its new home:

| Old | New |
| --- | --- |
| `SelectorCategoryBar` (horizontal) | `SelectorTabBar` |
| `SelectorCategoryBar` (vertical) | `SelectorSideBar` |
| `SelectorCategoryBarSkeleton` (horizontal) | `SelectorTabBarSkeleton` |
| `SelectorCategoryBarSkeleton` (vertical) | `SelectorSideBarSkeleton` |
| `SelectorCategoryBarTheme` | `SelectorTabBarTheme` / `SelectorSideBarTheme` |
| `SelectorCategoryBarIndicatorSize` | `SelectorTabBarIndicatorSize` |
| `SelectorThemeData.categoryBarTheme` | `SelectorThemeData.tabBarTheme` / `sideBarTheme` |

Mapping notes:
- `indicatorColor` / `indicatorHeight` / `indicatorPadding` / `indicatorAnimationDuration` move to `SelectorTabBar` / `SelectorTabBarTheme`.
- `indicatorSize` (`SelectorCategoryBarIndicatorSize`) maps to `SelectorTabBarIndicatorSize`.
- `size`: for a vertical bar use `SelectorSideBar.width`; for a horizontal bar wrap `SelectorTabBar` with `SizedBox(height: ...)`.
