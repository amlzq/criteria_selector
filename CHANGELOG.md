## Next

* **DEPRECATION** the selector configuration types are renamed to drop the redundant `Selector` prefix: `SelectorDelegate` → `SelectDelegate`, `CascadingSelectorDelegate` → `CascadingSelectDelegate`, `ListSelectorDelegate` → `ListSelectDelegate`, `GridSelectorDelegate` → `GridSelectDelegate`, and `FlattenSelectorDelegate` → `FlattenSelectDelegate`. The source file `lib/src/selector/selector_delegate.dart` was renamed to `lib/src/selector/select_delegate.dart` and the unit test `test/selector/selector_delegate_test.dart` → `test/selector/select_delegate_test.dart`. The `PopupSelectBar.selectorDelegates` parameter/property was renamed to `selectDelegates`, the `PopupSelectButton.selectorDelegate` parameter/property to `selectDelegate`, `PopupSelectController.previousSelectorDelegate` to `previousSelectDelegate`, and `PopupSelectController.attachSelectorDelegates` to `attachSelectDelegates`. The old names are retained as deprecated type aliases (e.g. `typedef SelectorDelegate = SelectDelegate;`), deprecated parameters/properties, and a deprecated method that behave identically and will be removed in a future minor version. Migrate call sites to the `Select*Delegate` / `selectDelegates` / `selectDelegate` / `previousSelectDelegate` / `attachSelectDelegates` names to clear the deprecation warnings.

* **DEPRECATION** the `Selector*Entry*` types are renamed to drop the redundant `Selector` prefix: `SelectorEntry` → `SelectEntry`, `SelectorCategoryEntry` → `SelectCategoryEntry`, `SelectorChildEntry` → `SelectChildEntry`, `SelectorRangeEntry` → `SelectRangeEntry`, `SelectorTextEntry` → `SelectTextEntry`, `SelectorIntEntry` → `SelectIntEntry`, and `SelectorEntries` → `SelectEntries` (the associated extensions were renamed to `SelectEntryExt`, `SelectChildEntryExt`, `SelectRangeEntryExt`, `SelectCategoryEntryExtension`, and `SelectEntriesExtension`). The source file `lib/src/selector/selector_entry.dart` was renamed to `lib/src/selector/select_entry.dart`. The old names are retained as deprecated type aliases (e.g. `typedef SelectorEntry<E> = SelectEntry<E>;`) that behave identically and will be removed in a future minor version. Migrate call sites to the `Select*Entry*` names to clear the deprecation warnings.

* **DEPRECATION** `DropdownSelectorBar`, `DropdownSelectorButton`, and their related types are renamed to the shorter `PopupSelect*` names: `PopupSelectBar`, `PopupSelectButton`, `PopupSelectBarTheme`, `PopupSelectButtonTheme`, `PopupSelectController`, `PopupTabData`, `PopupSelectDirection`, `PopupTab`, `PopupSelectBarCallback`, `PopupSelectBarToggleCallback`, `PopupSelectBarWillToggleCallback`, `PopupSelectButtonVariant`, `PopupSelectButtonResultCallback`, `PopupSelectButtonWillToggleCallback`, `PopupSelectControllerProvider`, `kPopupSelectBarHeight`, and `kPopupSelectButtonHeight`. The source files were renamed along the way (`lib/src/dropdown_selector_bar.dart` → `lib/src/popup_select_bar.dart`, etc.). The old names are retained as deprecated type aliases (`typedef DropdownSelectorBar = PopupSelectBar;`) that behave identically and will be removed in a future minor version. Migrate call sites to the `PopupSelect*` names to clear the deprecation warnings.

* **DEPRECATION** `SelectorBox` is renamed to `SelectView`, and the source file `lib/src/selector_box.dart` is renamed to `lib/src/select_view.dart`. `SelectorBox` is retained as a deprecated type alias (`typedef SelectorBox = SelectView;`) that behaves identically and will be removed in a future minor version. Migrate call sites to `SelectView`.

* **DEPRECATION** `showSelector` (dialog entry function) is renamed to `showSelect`. `showSelector` is retained as a deprecated backward-compatible alias that delegates to `showSelect` and will be removed in a future minor version. Migrate call sites to `showSelect` to clear the deprecation warning.

* **DEPRECATION** `showModalBottomSelector` (bottom sheet entry function) is renamed to `showModalBottomSelect`. `showModalBottomSelector` is retained as a deprecated backward-compatible alias that delegates to `showModalBottomSelect` and will be removed in a future minor version. Migrate call sites to `showModalBottomSelect` to clear the deprecation warning.

* **FEATURE** `GridSelector` now consumes `SelectorCategoryEntry.layout` via an exhaustive `switch (layout)`, matching the behavior already present in `ListSelector`. Each category renders as a `SelectorListView`, `SelectorGridView`, `SelectorChipBar`, or `SelectorRangeView` depending on its layout. `GridSelectorDelegate` gains optional `radioBuilder` / `checkboxBuilder` parameters for the `SelectorListLayout` branch. When `layout` is null the default `SelectorListLayout` is used; when `layout` is `SelectorGridLayout`, its own grid parameters (`crossAxisCount` etc.) take precedence over the delegate-level defaults.

* **BREAKING** remove the deprecated `CriteriaSelectorLocalizations` / `CriteriaSelectorLocalizationsDelegate` typedef aliases (introduced in 0.3.0). Use `SelectorLocalizations` / `SelectorLocalizationsDelegate` instead.

* **BREAKING** remove the deprecated `DropdownSelectorResult` class, `DropdownSelectorController.onChanged` / `onApplied` / `onReset` fields, `DropdownTabLabelGetter` typedef, `legacyLabelGetter` fields on `DropdownTabData` and `DropdownTab`, and the `fromLegacyResultCallback` / `fromLegacyLabelGetter` / `fromTabLabelGetter` adapter functions (introduced in 0.3.0). Use the listener API (`addChangeListener` / `addApplyListener` / `addResetListener`) on `DropdownSelectorController`, the `(DropdownTabData tabData, SelectorEntries selected)` callback signature directly, and the `SelectorLabelLoader` / `labelLoader` for label building.

* see [Migration guide](https://github.com/amlzq/criteria_selector/blob/main/MIGRATION.md#migrate-to-030).

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
