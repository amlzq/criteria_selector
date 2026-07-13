# Migration Guide

This document collects the breaking renames across the public API of
`criteria_selector`, organized by change. The old names are kept as deprecated
type/constant/parameter aliases during the deprecation period and will be removed
in the next major version.

> Migration for every entry below is a **pure rename** — each old symbol is the
> exact same type/value as its new counterpart, so simply replace the name in
> your code.

## `Dropselect*` → `Dropdown*`

The public API was renamed from `Dropselect*` to `Dropdown*` for clarity.

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

## `Selector` types → `*Delegate`

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
| `DropdownSelectorBar(selectors: ...)` | `DropdownSelectorBar(selectorDelegates: ...)` |
| `SelectorPanel(selector: ...)` | `CriteriaSelector(delegate: ...)` |
| `DropdownSelectorController.previousSelector` | `DropdownSelectorController.previousSelectorDelegate` |
| `DropdownSelectorController.attachSelectors(...)` | `DropdownSelectorController.attachSelectorDelegates(...)` |
| `CascadingSelector.selector` / `ListSelector.selector` / `GridSelector.selector` / `FlattenSelector.selector` | `...View.delegate` |

## Loader parameter names

The loader parameters on `SelectorDelegate` were renamed for consistency.

| Old | New |
| --- | --- |
| `SelectorDelegate.dataFetcher` | `SelectorDelegate.entriesLoader` |
| `SelectorDelegate.selectedDataFetcher` | `SelectorDelegate.selectedEntriesLoader` |
| `SelectorDelegate.resetDataFetcher` | `SelectorDelegate.resetEntriesLoader` |
