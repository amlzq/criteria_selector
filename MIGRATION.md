# Migration Guide

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
