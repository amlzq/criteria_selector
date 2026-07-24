## Next

* **DEPRECATION** rename `CriteriaSelectorLocalizations` → `SelectorLocalizations` and `CriteriaSelectorLocalizationsDelegate` → `SelectorLocalizationsDelegate` (old names kept as deprecated aliases).

## 0.2.1

* **FIX** persist selection so it is restored when the panel is reopened.

* **IMPROVEMENT** improve dark theme color in selector widgets.
* **IMPROVEMENT** add dartdoc comments to public API members.
* **IMPROVEMENT** remove `@immutable` annotations from enums.

* **PERF** refresh the overlay when delegates change.

## 0.2.0

* **FEATURE** add new components: `SelectorBox`, `DropdownSelectorButton`, `showSelector`, `showModalBottomSelector`.
* **FEATURE** add new APIs to `DropdownSelectorBar`: `onSelectorWillShow` / `onSelectorWillHide` and `direction`.
* **FEATURE** add new APIs to `DropdownSelectorController`: a listener API (`addChangeListener` / `addApplyListener` / `addResetListener`), `apply` for programmatic apply, and `select` to open the panel and preselect entries.
* **FEATURE** add convenience query helpers on `SelectorEntries` / `DropdownSelectorResult` (`findCategory`, `childIdsOf`, `childRangesOf`, `cascadingPairsOf`, `firstSelectedId`).
* **FEATURE** extend i18n support with `es`, `pt`, `id`, `vi`, `fr`, `de`, `ja`, and `ko` (reset / apply / multiple labels).

* **IMPROVEMENT** deprecate the `SelectorCategoryBar*` APIs and the `categoryBarTheme` properties in favor of the `TabBar` / `SideBar` equivalents and `tabBarTheme` / `sideBarTheme`.
* **IMPROVEMENT** adjust the theme defaults to better match the Material 3 visual style.

* **DEPRECATION** rename the `Dropselect*` public API to `Dropdown*` (old names kept as deprecated aliases).
* **DEPRECATION** rename the selector configuration types with a `Delegate` suffix and `DropdownSelectorBar.selectors` to `selectorDelegates` (old names kept as deprecated aliases).
* **DEPRECATION** deprecate `SelectorDelegate.dataFetcher` / `selectedDataFetcher` / `resetDataFetcher` in favor of `entriesLoader` / `selectedEntriesLoader` / `resetEntriesLoader`.

* For step-by-step rename tables, see [Migrate to 0.2.0](https://github.com/amlzq/criteria_selector/blob/main/MIGRATION.md#migrate-to-020).

## 0.1.1

* **FEATURE** add i18n for labels
* **FEATURE** CascadingSelector added isScrollable
* **FEATURE** animate dropdown overlay via controller

## 0.1.0

* **FEATURE** unify category prop and add chip wrap
* **FEATURE** make SelectorCategoryBar scrollable
* **FEATURE** add isScrollable option to DropselectTabBar
* **FEATURE** add expansion tile and category configs
* **FEATURE** add expansionTileTheme and rename chipBarThemeData
* **IMPROVEMENT** replace MediaQuery.of with MediaQuery.sizeOf

## 0.0.1

* initial release.
