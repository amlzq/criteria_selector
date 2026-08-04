# Migration Guide

## Next

### `DropdownOverlay*` / `SelectorLabel*` renamed to `Select*`

The overlay and label types have been renamed to a consistent `Select*` naming
scheme. The public types are kept as deprecated type aliases (e.g.
`typedef DropdownOverlayStyle = SelectOverlayStyle;`) for backward
compatibility and **will be removed in a future minor version**. Since the
aliases are exact `typedef`s, this is a pure rename — no behavior changes.

| Old name | New name | Deprecated alias? |
| --- | --- | --- |
| `DropdownOverlay` | `SelectOverlay` | no (package-internal) |
| `DropdownOverlayStyle` | `SelectOverlayStyle` | yes |
| `SelectorOverlayHost` | `SelectOverlayHost` | no (package-internal) |
| `SelectorLabelState` | `SelectLabelState` | yes |
| `SelectorLabelLoader` | `SelectLabelLoader` | yes |
| `kDropdownOverlayMaxHeightFactor` | `kSelectOverlayMaxHeightFactor` | no (package-internal) |
| `kDropdownOverlayScreenMargin` | `kSelectOverlayScreenMargin` | no (package-internal) |

The source files were renamed along the way (`lib/src/dropdown_overlay.dart` →
`lib/src/select_overlay.dart`, `lib/src/dropdown_overlay_style.dart` →
`lib/src/select_overlay_style.dart`, `lib/src/selector_overlay_host.dart` →
`lib/src/select_overlay_host.dart`, and `lib/src/selector_label_state.dart` →
`lib/src/select_label_state.dart`). The public export is updated, so no import
change is required when using the package barrel.

Migration: replace each old name with its new counterpart at every call site.

```dart
// Before
PopupSelectBarTheme(
  overlayStyle: DropdownOverlayStyle(barrierColor: Colors.black54),
);
PopupSelectButton(labelLoader: (selected) => '${selected.length} selected');

// After
PopupSelectBarTheme(
  overlayStyle: SelectOverlayStyle(barrierColor: Colors.black54),
);
PopupSelectButton(labelLoader: (selected) => '${selected.length} selected');
```

### `Selector*Layout` renamed to `Select*Layout`

The sealed layout descriptor and its subclasses have been renamed to drop the
redundant `Selector` prefix. The old names are kept as deprecated type aliases
(e.g. `typedef SelectorLayout = SelectLayout;`) for backward compatibility and
**will be removed in a future minor version**. Since the aliases are exact
`typedef`s, this is a pure rename — no behavior changes.

| Old name | New name |
| --- | --- |
| `SelectorLayout` | `SelectLayout` |
| `SelectorListLayout` | `SelectListLayout` |
| `SelectorGridLayout` | `SelectGridLayout` |
| `SelectorChipLayout` | `SelectChipLayout` |
| `SelectorRangeLayout` | `SelectRangeLayout` |

The source file was renamed along the way (`lib/src/selector/selector_layout.dart`
→ `lib/src/selector/select_layout.dart`). The public export is updated, so no
import change is required when using the package barrel.

Migration: replace each old name with its new counterpart at every call site.

```dart
// Before
SelectCategoryEntry(
  id: 'home_type',
  name: 'Home type',
  layout: const SelectorGridLayout(crossAxisCount: 2),
);

// After
SelectCategoryEntry(
  id: 'home_type',
  name: 'Home type',
  layout: const SelectGridLayout(crossAxisCount: 2),
);
```

### `SelectorDelegate` renamed to `SelectDelegate`

The selector configuration types have been renamed to drop the redundant
`Selector` prefix. The old names are kept as deprecated type aliases (e.g.
`typedef SelectorDelegate = SelectDelegate;`) for backward compatibility and
**will be removed in a future minor version**. Since the aliases are exact
`typedef`s, this is a pure rename — no behavior changes.

| Old name | New name |
| --- | --- |
| `SelectorDelegate` | `SelectDelegate` |
| `CascadingSelectorDelegate` | `CascadingSelectDelegate` |
| `ListSelectorDelegate` | `ListSelectDelegate` |
| `GridSelectorDelegate` | `GridSelectDelegate` |
| `FlattenSelectorDelegate` | `FlattenSelectDelegate` |

The source file was renamed along the way
(`lib/src/selector/selector_delegate.dart` →
`lib/src/selector/select_delegate.dart`), and the unit test
`test/selector/selector_delegate_test.dart` →
`test/selector/select_delegate_test.dart`. The public export is updated, so no
import change is required when using the package barrel.

The public member names that carried the `selectorDelegate(s)` spelling were
renamed as well. The old names are retained as deprecated parameters /
properties / a method for backward compatibility and will be removed in a
future minor version:

| Old member | New member |
| --- | --- |
| `PopupSelectBar.selectorDelegates` | `PopupSelectBar.selectDelegates` |
| `PopupSelectButton.selectorDelegate` | `PopupSelectButton.selectDelegate` |
| `PopupSelectController.previousSelectorDelegate` | `PopupSelectController.previousSelectDelegate` |
| `PopupSelectController.attachSelectorDelegates(...)` | `PopupSelectController.attachSelectDelegates(...)` |

Migration: replace each old name with its new counterpart at every call site.

```dart
// Before
PopupSelectBar(
  tabs: const [PopupTab(label: 'Filter')],
  selectorDelegates: [CascadingSelectorDelegate()],
);

// After
PopupSelectBar(
  tabs: const [PopupTab(label: 'Filter')],
  selectDelegates: [CascadingSelectDelegate()],
);
```

```dart
// Before
PopupSelectButton(selectorDelegate: ListSelectorDelegate());

// After
PopupSelectButton(selectDelegate: ListSelectDelegate());
```

### `Selector*Entry*` renamed to `Select*Entry*`

The `Selector*Entry*` types have been renamed to drop the redundant `Selector`
prefix. The old names are kept as deprecated type aliases (e.g.
`typedef SelectorEntry<E> = SelectEntry<E>;`) for backward compatibility and
**will be removed in a future minor version**. Since the aliases are exact
`typedef`s, this is a pure rename — no behavior changes.

| Old name | New name |
| --- | --- |
| `SelectorEntry` | `SelectEntry` |
| `SelectorCategoryEntry` | `SelectCategoryEntry` |
| `SelectorChildEntry` | `SelectChildEntry` |
| `SelectorRangeEntry` | `SelectRangeEntry` |
| `SelectorTextEntry` | `SelectTextEntry` |
| `SelectorIntEntry` | `SelectIntEntry` |
| `SelectorEntries` | `SelectEntries` |
| `SelectorEntryExt` | `SelectEntryExt` |
| `SelectorChildEntryExt` | `SelectChildEntryExt` |
| `SelectorRangeEntryExt` | `SelectRangeEntryExt` |
| `SelectorCategoryEntryExtension` | `SelectCategoryEntryExtension` |
| `SelectorEntriesExtension` | `SelectEntriesExtension` |

The source file was renamed along the way (`lib/src/selector/selector_entry.dart`
→ `lib/src/selector/select_entry.dart`), and the unit test
`test/selector/selector_entry_test.dart` → `test/selector/select_entry_test.dart`.
The public export is updated, so no import change is required when using the
package barrel.

Migration: replace each old name with its new counterpart at every call site.

```dart
// Before
SelectorCategoryEntry(
  id: 'price',
  name: 'Price',
  children: {
    SelectorRangeEntry<int, void>.any(parentId: 'price', name: 'Any'),
  },
);

// After
SelectCategoryEntry(
  id: 'price',
  name: 'Price',
  children: {
    SelectRangeEntry<int, void>.any(parentId: 'price', name: 'Any'),
  },
);
```

### `SelectorBox` renamed to `SelectView`

`SelectorBox` has been renamed to `SelectView`. The old name `SelectorBox` is
kept as a deprecated type alias (`typedef SelectorBox = SelectView;`) for
backward compatibility and **will be removed in a future minor version**.

- The source file was renamed along the way (`lib/src/selector_box.dart` →
  `lib/src/select_box.dart` → `lib/src/select_view.dart`). The public export is
  updated, so no import change is required.
- `SelectorBox` is the exact same type as `SelectView` (a `typedef`), so this is
  a pure rename — no behavior changes.

Migration: replace `SelectorBox` with `SelectView` at every call site.

```dart
// Before
SelectorBox(
  delegate: delegate,
  onChanged: (selected) { /* ... */ },
);

// After
SelectView(
  delegate: delegate,
  onChanged: (selected) { /* ... */ },
);
```

### `showSelector` renamed to `showSelect`

`showSelector` (the dialog entry function) has been renamed to `showSelect`. The
old name is kept as a deprecated backward-compatible alias that delegates to
`showSelect` and **will be removed in a future minor version**.

Migration: replace `showSelector` with `showSelect` at every call site.

```dart
// Before
final result = await showSelector(context: context, delegate: delegate);

// After
final result = await showSelect(context: context, delegate: delegate);
```

### `showModalBottomSelector` renamed to `showModalBottomSelect`

`showModalBottomSelector` (the bottom sheet entry function) has been renamed to
`showModalBottomSelect`. The old name is kept as a deprecated backward-compatible
alias that delegates to `showModalBottomSelect` and **will be removed in a future
minor version**.

Migration: replace `showModalBottomSelector` with `showModalBottomSelect` at
every call site.

```dart
// Before
final result = await showModalBottomSelector(context: context, delegate: delegate);

// After
final result = await showModalBottomSelect(context: context, delegate: delegate);
```

### `SelectorController` / `SelectorThemeData` renamed to `Select*`

The controller, callback and theme types have been renamed to drop the
redundant `Selector` prefix. The old names are kept as deprecated type aliases
(e.g. `typedef SelectorThemeData = SelectThemeData;`) for backward compatibility
and **will be removed in a future minor version**. Since the aliases are exact
`typedef`s, this is a pure rename — no behavior changes.

> `SelectPanel` is an unpublished (internal) widget, so it is renamed cleanly
> without a deprecated alias.

| Old name | New name |
| --- | --- |
| `SelectorController` | `SelectController` |
| `SelectorControllerProvider` | `SelectControllerProvider` |
| `SelectorCallback` | `SelectCallback` |
| `SelectorThemeData` | `SelectThemeData` |
| `SelectorTheme` | `SelectTheme` |
| `SelectorPanelTheme` | `SelectPanelTheme` |

The source files were renamed along the way
(`lib/src/selector/selector_panel.dart` → `lib/src/selector/select_panel.dart`,
`lib/src/selector/selector_controller.dart` →
`lib/src/selector/select_controller.dart`,
`lib/src/selector/selector_theme_data.dart` →
`lib/src/selector/select_theme_data.dart`,
`lib/src/selector/selector_theme.dart` →
`lib/src/selector/select_theme.dart`, and
`lib/src/selector/selector_panel_theme.dart` →
`lib/src/selector/select_panel_theme.dart`), and the unit tests were renamed
along the way (`test/selector/selector_panel_test.dart` →
`test/selector/select_panel_test.dart`, `test/selector/selector_controller_test.dart`
→ `test/selector/select_controller_test.dart`, and
`test/selector/selector_panel_theme_test.dart` →
`test/selector/select_panel_theme_test.dart`). The public export is updated, so
no import change is required when using the package barrel.

The public member that carried the `selectorController` spelling was renamed as
well. The old name is retained as a deprecated property for backward
compatibility and will be removed in a future minor version:

| Old member | New member |
| --- | --- |
| `PopupSelectController.selectorController` | `PopupSelectController.selectController` |

Migration: replace each old name with its new counterpart at every call site.

```dart
// Before
SelectorController.of(context);
final theme = SelectorThemeData(Theme.of(context));

// After
SelectController.of(context);
final theme = SelectThemeData(Theme.of(context));
```

### `selectorTheme` parameter renamed to `selectTheme`

The `selectorTheme` parameter / field on the public entry points
([`PopupSelectBar`], [`PopupSelectBarTheme`], and [`PopupSelectButtonTheme`])
has been renamed to `selectTheme`. The old `selectorTheme` constructor parameter
and getter are kept as deprecated backward-compatible aliases that delegate to
`selectTheme` and **will be removed in a future minor version**. No behavior
changes.

The same parameter on the unpublished `SelectPanel` widget is also renamed to
`selectTheme`, but without a deprecated alias.

```dart
// Before
PopupSelectBar(
  selectorTheme: SelectThemeData(Theme.of(context)),
);

// After
PopupSelectBar(
  selectTheme: SelectThemeData(Theme.of(context)),
);
```

Passing both the old and the new parameter at the same call site triggers an
`assert`, mirroring the existing `selectDelegates` / `selectorDelegates`
pattern.

### `DropdownSelector*` renamed to `PopupSelect*`

The `DropdownSelector*` widgets and their related types have been renamed to the
shorter `PopupSelect*` names. The old names are kept as deprecated type aliases
(`typedef DropdownSelectorBar = PopupSelectBar;`) for backward compatibility and
**will be removed in a future minor version**. Since the aliases are exact
`typedef`s, this is a pure rename — no behavior changes.

| Old name | New name |
| --- | --- |
| `DropdownSelectorBar` | `PopupSelectBar` |
| `DropdownSelectorButton` | `PopupSelectButton` |
| `DropdownSelectorBarTheme` | `PopupSelectBarTheme` |
| `DropdownSelectorButtonTheme` | `PopupSelectButtonTheme` |
| `DropdownSelectorController` | `PopupSelectController` |
| `DropdownTabData` | `PopupTabData` |
| `DropdownSelectorDirection` | `PopupSelectDirection` |
| `DropdownTab` | `PopupTab` |
| `DropdownSelectorBarCallback` | `PopupSelectBarCallback` |
| `DropdownSelectorBarToggleCallback` | `PopupSelectBarToggleCallback` |
| `DropdownSelectorBarWillToggleCallback` | `PopupSelectBarWillToggleCallback` |
| `DropdownSelectorButtonVariant` | `PopupSelectButtonVariant` |
| `DropdownSelectorButtonResultCallback` | `PopupSelectButtonResultCallback` |
| `DropdownSelectorButtonWillToggleCallback` | `PopupSelectButtonWillToggleCallback` |
| `DropdownSelectorControllerProvider` | `PopupSelectControllerProvider` |
| `kDropdownSelectorBarHeight` | `kPopupSelectBarHeight` |
| `kDropdownSelectorButtonHeight` | `kPopupSelectButtonHeight` |

The source files were renamed along the way (`lib/src/dropdown_selector_bar.dart`
→ `lib/src/popup_select_bar.dart`, `lib/src/dropdown_selector_button.dart` →
`lib/src/popup_select_button.dart`, `lib/src/dropdown_selector_bar_theme.dart` →
`lib/src/popup_select_bar_theme.dart`, `lib/src/dropdown_selector_button_theme.dart`
→ `lib/src/popup_select_button_theme.dart`, and
`lib/src/dropdown_selector_controller.dart` → `lib/src/popup_select_controller.dart`).
The public export is updated, so no import change is required when using the
package barrel.

Migration: replace each old name with its new counterpart at every call site.

```dart
// Before
DropdownSelectorBar(
  tabs: const [DropdownTab(label: 'Filter')],
  selectorDelegates: [delegate],
  controller: DropdownSelectorController(),
  direction: DropdownSelectorDirection.below,
);

// After
PopupSelectBar(
  tabs: const [PopupTab(label: 'Filter')],
  selectorDelegates: [delegate],
  controller: PopupSelectController(),
  direction: PopupSelectDirection.below,
);
```

### `SelectorLocalizations` / `SelectorLocalizationsDelegate` renamed to `SelectLocalizations` / `SelectLocalizationsDelegate`

**Description**
The i18n classes were renamed to drop the redundant `Selector` prefix. The old
names are kept as deprecated type aliases (e.g.
`typedef SelectorLocalizations = SelectLocalizations;`) for backward
compatibility and **will be removed in a future minor version**. Since the
aliases are exact `typedef`s, this is a pure rename — no behavior changes.

The source files were renamed along the way
(`lib/src/i18n/localizations.dart` → `lib/src/i18n/select_localizations.dart`
and `lib/src/i18n/localizations_delegate.dart` →
`lib/src/i18n/select_localizations_delegate.dart`), and unit tests were added
under `test/i18n/select_localizations_test.dart` and
`test/i18n/select_localizations_delegate_test.dart`. The public export is
updated, so no import change is required when using the package barrel.

| Old name | New name |
| --- | --- |
| `SelectorLocalizations` | `SelectLocalizations` |
| `SelectorLocalizationsDelegate` | `SelectLocalizationsDelegate` |

Migration: replace each old name with its new counterpart at every call site.

```dart
// Before
MaterialApp(
  localizationsDelegates: const [
    SelectorLocalizationsDelegate(),
  ],
  supportedLocales: SelectorLocalizationsDelegate.supportedLocales,
);

// After
MaterialApp(
  localizationsDelegates: const [
    SelectLocalizationsDelegate(),
  ],
  supportedLocales: SelectLocalizationsDelegate.supportedLocales,
);
```

## MIGRATE TO 0.4.0

### Single `layout` replaces `listConfig` / `gridConfig` / `chipConfig`

**Description**
`SelectorCategoryEntry` previously exposed three mutually-exclusive, nullable
fields (`listConfig`, `gridConfig`, `chipConfig`) to choose how a category's
children are rendered. These are replaced by a single `layout` property
of the new sealed `SelectorLayout` type, with the concrete layouts
`SelectorListLayout`, `SelectorGridLayout`, and `SelectorChipLayout`. A `switch`
over `layout` is exhaustively checked by the compiler (the base class is
`sealed`). When `layout` is `null`, a default `SelectorListLayout` is
used at render time.

The old fields are **deprecated but still available** as getters and constructor
parameters. They are mapped to the new layouts with the priority
`listConfig` > `gridConfig` > `chipConfig`, so existing code keeps compiling and
behaving the same. The deprecated members will be removed in a future major
version.

**Before → After**

```dart
// Before
SelectorCategoryEntry(
  id: 'home_type',
  name: 'Home type',
  gridConfig: const SelectorGridConfig(
    crossAxisCount: 2,
    childAspectRatio: 5,
  ),
  children: {...},
);

// After
SelectorCategoryEntry(
  id: 'home_type',
  name: 'Home type',
  layout: const SelectorGridLayout(
    crossAxisCount: 2,
    childAspectRatio: 5,
  ),
  children: {...},
);
```

| Old | New |
| --- | --- |
| `SelectorCategoryEntry.listConfig` | `SelectorCategoryEntry.layout` is `SelectorListLayout` |
| `SelectorCategoryEntry.gridConfig` | `SelectorCategoryEntry.layout` is `SelectorGridLayout` |
| `SelectorCategoryEntry.chipConfig` | `SelectorCategoryEntry.layout` is `SelectorChipLayout` |
| `SelectorListConfig` | `SelectorListLayout` |
| `SelectorGridConfig` | `SelectorGridLayout` |
| `SelectorChipConfig` | `SelectorChipLayout` |

### `SelectorBox.onChangeTap` renamed to `SelectorBox.onChanged`

**Description**
`SelectorBox` exposes its selection callback under the new name `onChanged`.
The previous `onChangeTap` argument and the `onChangeTap` getter are now
deprecated but still supported for backward compatibility, and will be removed
in a future minor version. Passing both `onChanged` and `onChangeTap` triggers
an assertion, so migrate existing call sites to `onChanged` to clear the
deprecation warning.

**Before → After**

```dart
// Before
SelectorBox(
  controller: controller,
  onChangeTap: (SelectorEntries selected) { /* ... */ },
);

// After
SelectorBox(
  controller: controller,
  onChanged: (SelectorEntries selected) { /* ... */ },
);
```

| Old | New |
| --- | --- |
| `SelectorBox.onChangeTap` (argument) | `SelectorBox.onChanged` |
| `SelectorBox.onChangeTap` (getter) | `SelectorBox.onChanged` |

## MIGRATE TO 0.3.0

### Rename i18n classes (drop the redundant `Criteria` prefix)

**Description**
The i18n classes were renamed to drop the redundant `Criteria` prefix. This is a
pure rename — each old symbol is the exact same type as its new counterpart, so
simply replace the name in your code.

**Before → After**

```dart
// Before
MaterialApp(
  localizationsDelegates: const [
    CriteriaSelectorLocalizations.delegate,
    CriteriaSelectorLocalizationsDelegate(),
  ],
);

// After
MaterialApp(
  localizationsDelegates: const [
    SelectorLocalizations.delegate,
    SelectorLocalizationsDelegate(),
  ],
);
```

| Old | New |
| --- | --- |
| `CriteriaSelectorLocalizations` | `SelectorLocalizations` |
| `CriteriaSelectorLocalizationsDelegate` | `SelectorLocalizationsDelegate` |

### `DropdownSelectorResultCallback` / `DropdownTabLabelGetter` now take `(tabData, selected)`

**Description**
These callbacks previously received a single `DropdownSelectorResult`. They now
receive the tab metadata and the selected entries directly as two arguments. The
change applies to `DropdownSelectorBar.onChanged` / `onApplied` and to
`DropdownTabLabelGetter`. The `DropdownSelectorResult` class itself is unchanged
and remains useful for querying the selection (e.g. `childIdsOf`,
`firstSelectedId`).

To keep an existing legacy `void Function(DropdownSelectorResult)` handler
compiling with minimal changes, wrap it with the `fromLegacyResultCallback`
adapter helper. Backward compatibility is also preserved on
`DropdownSelectorController`: `onChanged` / `onApplied` still accept the legacy
signature (deprecated, to be removed in a future minor version), so
`addChangeListener` / `addApplyListener` call sites you have not yet migrated
continue to compile.

**Before → After**

```dart
// Before
DropdownSelectorBar(
  onChanged: (DropdownSelectorResult result) { /* ... */ },
  onApplied: (DropdownSelectorResult result) { /* ... */ },
);
DropdownTab(labelGetter: (DropdownSelectorResult result) => '...');

// After
DropdownSelectorBar(
  onChanged: (DropdownTabData tabData, SelectorEntries selected) { /* ... */ },
  onApplied: (DropdownTabData tabData, SelectorEntries selected) { /* ... */ },
);
DropdownTab(labelGetter: (DropdownTabData tabData, SelectorEntries selected) => '...');
```

```dart
// Keep a legacy handler compiling — wrap it with the adapter helper
onChanged: fromLegacyResultCallback((DropdownSelectorResult result) {
  // existing legacy code that uses `result`
}),
```

### `DropdownSelectorResult` is deprecated

**Description**
`DropdownSelectorResult` still works but is now deprecated and will be removed in
a future minor version. You only need to construct it to keep an existing legacy
`void Function(DropdownSelectorResult)` callback working. Prefer consuming the tab
metadata and the selected entries directly via the `(tabData, selected)`
arguments instead. The `DropselectResult` rename alias is also deprecated.

**Before → After**

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

Every convenience accessor previously provided by `DropdownSelectorResult` has a
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

### `DropdownSelectorButton` no longer exposes tab metadata

**Description**
`DropdownSelectorButton` is a single trigger with no tab concept, so its lifecycle
callbacks no longer receive `DropdownTabData`. Internally the button now stores a
`SelectorLabelState` (a new, tab-agnostic base class) instead of a faked
`DropdownTabData(index: 0, ...)`. `DropdownSelectorBar` is unaffected — it still
uses `DropdownTabData` and the `(tabData, selected)` callbacks. If you previously
keyed behaviour off `tabData.index` to distinguish multiple buttons, give each
button its own handler (or a domain argument) instead — that `index` was always
`0` for a standalone button and is no longer available.

**Before → After**

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

| Callback | Before | After |
| --- | --- | --- |
| `onChanged` | `void Function(DropdownTabData, SelectorEntries)` | `void Function(SelectorEntries)` (typedef `SelectorResultCallback`) |
| `onApplied` | `void Function(DropdownTabData, SelectorEntries)` | `void Function(SelectorEntries)` |
| `onSelectorShowed` / `onSelectorHidden` | `void Function(DropdownTabData)` | `void Function()` |
| `onSelectorWillShow` / `onSelectorWillHide` | `FutureOr<bool> Function(DropdownTabData)` | `FutureOr<bool> Function()` |

### `DropdownTab.labelLoader` now takes `(selected)` instead of `(tabData, selected)`

**Description**
The label builder has been refactored to the tab-agnostic typedef
`SelectorLabelLoader` (`String Function(SelectorEntries selected)`). The old
`DropdownTabLabelGetter` (`String Function(DropdownTabData, SelectorEntries)`) is
kept as a deprecated alias for backward compatibility. Note that
`fromTabLabelGetter` drops the tab metadata (a placeholder tab is passed), so
getters that relied on `tabData` should use `legacyLabelGetter`, which forwards
the live `DropdownTabData`, or be rewritten to the new signature.

**Before → After**

```dart
// Before
DropdownTab(
  label: 'Price',
  labelLoader: (DropdownTabData tabData, SelectorEntries selected) => '...',
);

// After — canonical form, drop the unused tabData argument
DropdownTab(
  label: 'Price',
  labelLoader: (SelectorEntries selected) => '${selected.length} selected',
);

// Keep a legacy (tabData, selected) getter compiling — wrap with the adapter
DropdownTab(
  label: 'Price',
  labelLoader: fromTabLabelGetter((tabData, selected) => '...'),
);

// Keep receiving the live tab metadata losslessly — use the legacy field
DropdownTab(
  label: 'Price',
  legacyLabelGetter: (tabData, selected) => '${tabData.tag}: ${selected.length}',
);
```

| API | Before | After |
| --- | --- | --- |
| `DropdownTab.labelLoader` | `DropdownTabLabelGetter?` (`(tabData, selected)`) | `SelectorLabelLoader?` (`(selected)`) |
| `DropdownTabData.labelGetter` | `DropdownTabLabelGetter?` | `SelectorLabelLoader?` (getter; also keeps `labelLoader` / `legacyLabelGetter`) |

## MIGRATE TO 0.2.0
The old names are kept as deprecated type/constant/parameter aliases during the deprecation period and will be removed in the next minor version.

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
