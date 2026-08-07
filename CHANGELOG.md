## Next

* **DEPRECATION** rename the selector lifecycle callbacks on `PopupSelectBar` and `PopupSelectButton` — `onSelectorShowed` / `onSelectorHidden` / `onSelectorWillShow` / `onSelectorWillHide` → `onSelectShowed` / `onSelectHidden` / `onSelectWillShow` / `onSelectWillHide`. The old names are retained as deprecated constructor parameters and getters that delegate to the new names (passing both at the same call site triggers an assertion) and will be removed in a future minor version.

* **DEPRECATION** rename `PopupSelectController.hideSelector` → `hideSelect`, `toggleSelector` → `toggleSelect`, and `isSelectorShowing` → `isSelectShowing` to drop the redundant `Selector` wording. The old names are retained as deprecated methods / getters that delegate to the new names and will be removed in a future minor version.

* **BREAKING** remove all deprecated aliases, parameters, getters and methods introduced in 0.5.0 by the `Select*` / `PopupSelect*` renaming. This includes: the `Selector*Entry*` / `SelectorEntries` aliases, `SelectorBox`, `showSelector`, `showModalBottomSelector`, `SelectorTheme` / `SelectorThemeData`, `SelectorPanelTheme`, `SelectorDelegate` / `CascadingSelectorDelegate` / `ListSelectorDelegate` / `GridSelectorDelegate` / `FlattenSelectorDelegate`, `SelectorController` / `SelectorControllerProvider`, `SelectorCallback`, `SelectorLayout` / `SelectorListLayout` / `SelectorGridLayout` / `SelectorChipLayout` / `SelectorRangeLayout`, `SelectorLocalizations` / `SelectorLocalizationsDelegate`, `SelectorLabelLoader` / `SelectorLabelState`, `DropdownOverlayStyle`, `kSelectorListTileHeight`, the `DropdownSelector*` → `PopupSelect*` aliases (`DropdownSelectorBar`, `DropdownTab`, `DropdownSelectController`, `DropdownTabData`, `DropdownSelectControllerProvider`, `DropdownSelectorBarTheme`, `DropdownSelectorButton`, `DropdownSelectorButtonTheme`, `DropdownSelectorButtonVariant`, `DropdownSelectorButtonResultCallback`, `DropdownSelectorButtonWillToggleCallback`, `kDropdownSelectorButtonHeight`, `DropdownSelectorDirection`), and the `selectorDelegates` / `selectorTheme` / `selectorDelegate` parameters and getters, `previousSelectorDelegate`, `selectorController` and `attachSelectorDelegates` members. Use the `Select*` / `PopupSelect*` names instead; see the [Migration guide](https://github.com/amlzq/criteria_selector/blob/main/MIGRATION.md#migrate-to-050) for the full old → new tables.

* **FEATURE** `FlattenSelect` now consumes `SelectCategoryEntry.layout` via an exhaustive `switch (layout)`, matching the behavior already present in `ListSelect` / `GridSelect`. Each category's right-side content renders as a `SelectListView`, `SelectGridView`, `SelectChipBar`, `SelectRangeView`, or `SelectCounter` depending on its layout, with the grid/list/counter/range layout-specific parameters (`crossAxisCount`, spacing, `childAspectRatio`, `toText`, etc.) and the delegate theme overrides (grid/field/chip) honored. When `layout` is null, it falls back to the grid using the widget's own `crossAxisCount` / `mainAxisSpacing` / `crossAxisSpacing` / `childAspectRatio`, so existing default behavior is unchanged.

## 0.6.0

* **BUGFIX** fix `SelectRangeView` to honor the two-entry arrangement produced by `fetchPriceData`-style delegates: the range entry drives the slider and the custom entry drives the field display, with values written to the custom entry and `onChanged` only returning that custom entry.

* **BUGFIX** `SelectRangeView` now restores the previously selected range from `selectedEntries` instead of always starting at the full extremes, also once a selection first becomes available after an initial empty build.

* **BUGFIX** in `GridSelect`, tapping the reset button now resets only the currently focused category via the new `SelectController.resetCategoryState` / `StateTree.resetCategory` API, instead of resetting every category.

* **FEATURE** add `SelectRangeView.fieldVariant` (`SelectFieldTileVariant?`), applied to the two `SelectFieldTile`s below the slider.

* **IMPROVEMENT** `SelectFieldTile` now mirrors `SelectGridTile` by deriving the text color from the background brightness for selected filled tiles.

* **FEATURE** add `SelectCounterLayout` as a new `SelectLayout` sealed subclass and the `SelectCounter` widget (`lib/src/selector/widgets/counter.dart`). `ListSelector` and `GridSelector` now route such categories to a single-valued stepper with `-` / value / `+` buttons, rendered in Material 3 filled style and disabled at the two extremes.

* **BREAKING** remove the deprecated `SelectOverlayStyle.backgroundColor` constructor / `copyWith` parameter and getter (introduced in 0.5.0). Use `barrierColor` to set the scrim (backdrop) color instead; this field always controlled the scrim color, not the panel background. The `barrierColor` / `barrierIntercept` / `minWidth` / `maxWidth` behavior is unchanged.

* **BREAKING** remove the deprecated `listConfig` / `gridConfig` / `chipConfig` fields and constructor / `copyWith` parameters on `SelectCategoryEntry` and the deprecated `SelectorListConfig` / `SelectorGridConfig` / `SelectorChipConfig` classes (introduced in 0.4.0). Use the single `SelectCategoryEntry.layout` property of the sealed `SelectLayout` type (`SelectListLayout` / `SelectGridLayout` / `SelectChipLayout`) instead; see [Migration guide](https://github.com/amlzq/criteria_selector/blob/main/MIGRATION.md#migrate-to-040).

* **BREAKING** remove the deprecated `SelectBox.onChangeTap` argument and `onChangeTap` getter (introduced in 0.4.0). Use `onChanged` on `SelectView` instead; see [Migration guide](https://github.com/amlzq/criteria_selector/blob/main/MIGRATION.md#migrate-to-040).

## 0.5.0

* **DEPRECATION** rename many public widgets, themes, delegates, entries, controller, callback and related types to a consistent `Select*` / `PopupSelect*` naming (drop the redundant `Selector` / `DropdownSelector` prefix). This covers the list/range/sidebar/tab bar widgets and themes, the panel-content widgets and themes, the overlay and label types, the sealed layout descriptors, the delegate types and `selectorDelegates` / `selectorDelegate` / `previousSelectorDelegate` / `attachSelectorDelegates` members, the `Selector*Entry*` types, the i18n classes, `DropdownSelector*` → `PopupSelect*`, `SelectorBox` → `SelectView`, `showSelector` → `showSelect`, `showModalBottomSelector` → `showModalBottomSelect`, the controller/theme types and `PopupSelectController.selectorController` → `selectController`, and the `selectorTheme` → `selectTheme` parameter. The old names are kept as deprecated type aliases / parameters / members that behave identically and will be removed in a future minor version. Package-internal symbols are renamed cleanly without a deprecated alias. Migrate call sites to the `Select*` / `PopupSelect*` names to clear the deprecation warnings; see the [Migration guide](https://github.com/amlzq/criteria_selector/blob/main/MIGRATION.md#migrate-to-050) for the full old → new tables.

* **FEATURE** `GridSelector` now consumes `SelectCategoryEntry.layout` via an exhaustive `switch (layout)`, matching the behavior already present in `ListSelector`. Each category renders as a `SelectListView`, `SelectGridView`, `SelectChipBar`, or `SelectRangeView` depending on its layout. `GridSelectDelegate` gains optional `radioBuilder` / `checkboxBuilder` parameters for the `SelectListLayout` branch. When `layout` is null the default `SelectListLayout` is used; when `layout` is `SelectGridLayout`, its own grid parameters (`crossAxisCount` etc.) take precedence over the delegate-level defaults.

* **BREAKING** remove the deprecated `CriteriaSelectorLocalizations` / `CriteriaSelectorLocalizationsDelegate` typedef aliases (introduced in 0.3.0). Use `SelectorLocalizations` / `SelectorLocalizationsDelegate` instead; see [Migration guide](https://github.com/amlzq/criteria_selector/blob/main/MIGRATION.md#migrate-to-030).

* **BREAKING** remove the deprecated `DropdownSelectorResult` class, `DropdownSelectorController.onChanged` / `onApplied` / `onReset` fields, `DropdownTabLabelGetter` typedef, `legacyLabelGetter` fields on `DropdownTabData` and `DropdownTab`, and the `fromLegacyResultCallback` / `fromLegacyLabelGetter` / `fromTabLabelGetter` adapter functions (introduced in 0.3.0). Use the listener API (`addChangeListener` / `addApplyListener` / `addResetListener`) on `DropdownSelectorController`, the `(DropdownTabData tabData, SelectorEntries selected)` callback signature directly, and the `SelectorLabelLoader` / `labelLoader` for label building; see [Migration guide](https://github.com/amlzq/criteria_selector/blob/main/MIGRATION.md#migrate-to-030).

## 0.4.0

* **FEATURE** add `SelectorRangeLayout` as a new `SelectorLayout` sealed subclass. The existing `switch (layout)` in `ListSelector` now routes to `SelectorRangeView`, which composes `SelectorRangeSlider` + a paired two-text-field row with bidirectional sync and `focusListener` callback.

* **DEPRECATION** `SelectorCategoryEntry` previously exposed three mutually-exclusive, nullable fields `listConfig` / `gridConfig` / `chipConfig`. They are replaced by a single `layout` property of the new sealed `SelectorLayout` type. The old fields remain available as deprecated getters/constructor parameters that map to `SelectorListLayout` / `SelectorGridLayout` / `SelectorChipLayout` and will be removed in a future minor version.

* **DEPRECATION** rename `SelectBox.onChangeTap` → `SelectBox.onChanged`. The old `onChangeTap` argument and `onChangeTap` getter are retained as deprecated members for backward compatibility and will be removed in a future minor version. Passing both `onChanged` and `onChangeTap` triggers an assertion.

* **BREAKING** remove the deprecated `Dropselect*` public API aliases (introduced in 0.2.0). Use the `Dropdown*` / `DropdownSelector*` names instead.

* **BREAKING** remove the deprecated `Selector` / `CascadingSelector` / `ListSelector` / `GridSelector` / `FlattenSelector` type aliases and the `DropdownSelectorBar.selectors` parameter (introduced in 0.2.0). Use the `*Delegate` types and `selectorDelegates` parameter instead.

* **BREAKING** remove the deprecated `SelectorDelegate.dataFetcher` / `selectedDataFetcher` / `resetDataFetcher` parameters (introduced in 0.2.0). Use `entriesLoader` / `selectedEntriesLoader` / `resetEntriesLoader` instead.

* **BREAKING** remove the deprecated `SelectorCategoryBar` / `SelectorCategoryBarSkeleton` / `SelectorCategoryBarTheme` / `SelectorCategoryBarIndicatorSize` widgets and types, the `SelectorThemeData.categoryBarTheme` property, and the `SelectorDelegate.categoryBarTheme` parameter (introduced in 0.2.0). Use `SelectorTabBar` / `SelectorSideBar` and `tabBarTheme` / `sideBarTheme` instead.

* see [Migration guide](https://github.com/amlzq/criteria_selector/blob/main/MIGRATION.md#migrate-to-020).

## 0.3.0

* **DEPRECATION** rename `CriteriaSelectorLocalizations` → `SelectorLocalizations` and `CriteriaSelectorLocalizationsDelegate` → `SelectorLocalizationsDelegate` (old names kept as deprecated aliases).

* **DEPRECATION** change `DropdownSelectorResultCallback` to `void Function(DropdownTabData tabData, SelectorEntries selected)` (was `void Function(DropdownSelectorResult)`) and `DropdownTabLabelGetter` to `String Function(DropdownTabData, SelectorEntries)` (was `String Function(DropdownSelectorResult)`); callbacks now receive the tab metadata and selected entries directly, so a `DropdownSelectorResult` no longer needs to be unwrapped.

* **DEPRECATION** type `DropdownTab.labelGetter` / `DropdownTabData.labelGetter` as `SelectorLabelLoader` (`String Function(SelectorEntries)`) instead of the deprecated `DropdownTabLabelGetter`; the tab metadata argument is no longer passed to the canonical loader.

* **DEPRECATION** deprecate `DropdownSelectorResult` (and the `DropselectResult` alias); it is now only needed to keep an existing legacy `void Function(DropdownSelectorResult)` callback working, and will be removed in a future minor version.

* **DEPRECATION** keep `DropdownSelectorController.onChanged` / `onApplied` on the legacy `void Function(DropdownSelectorResult)` signature; they will be removed in a future minor version.

* **DEPRECATION** keep `DropdownTabLabelGetter` as a backward-compatible alias and add a deprecated `legacyLabelGetter` field on `DropdownTab` / `DropdownTabData` to forward the live `DropdownTabData` to legacy getters.

* **IMPROVEMENT** add `DropdownSelectorButton.labelLoader` (`SelectorLabelLoader?`) to build the trigger label from the applied selection; it is stored on the shared `SelectorLabelState.labelLoader` and resolved via `SelectorLabelState.resolvedLabelLoader`, so single-trigger buttons and multi-tab bars now share one code path.

* **IMPROVEMENT** add `fromLegacyResultCallback`, `fromLegacyLabelGetter`, and `fromTabLabelGetter` helpers (in `selector/constants.dart`) to adapt legacy callbacks / label getters to the current signatures.

* see [Migrate to 0.3.0](https://github.com/amlzq/criteria_selector/blob/main/MIGRATION.md#migrate-to-030).

## 0.2.1

* **BUGFIX** persist selection so it is restored when the panel is reopened.

* **IMPROVEMENT** improve dark theme color in selector widgets.
* **IMPROVEMENT** add dartdoc comments to public API members.
* **IMPROVEMENT** remove `@immutable` annotations from enums.
* **IMPROVEMENT** refresh the overlay when delegates change.

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
