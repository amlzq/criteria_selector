# CriteriaSelector

A multi-dimensional condition selector — a typical use case is a list filtering selector.

## Features

- **5 public entry points**: `CriteriaSelector` (embed in a page), `DropdownSelectorBar` (tab bar + overlay), `DropdownSelectorButton` (single trigger), `showSelector` (dialog), and `showModalBottomSelector` (bottom sheet).
- **4 built-in layouts** via `SelectorDelegate`: `CascadingSelectorDelegate`, `GridSelectorDelegate`, `ListSelectorDelegate`, `FlattenSelectorDelegate`.
- **Single & multiple selection** via `SelectionMode`.
- **Async data loading** through `entriesLoader`.
- **Any / Custom / immediate-apply entries** — an "Any" entry clears a category, `SelectorRangeEntry.custom` accepts user min/max input, and `immediate` entries apply without the action bar.
- **`skeletonBuilder` & `errorBuilder`** for custom loading and error states.
- **Theming** via `SelectorThemeData` and the `DropdownSelectorBarTheme` / `DropdownSelectorButtonTheme` theme extensions.
- **Built-in i18n** (10 languages) via `CriteriaSelectorLocalizationsDelegate`.

## Getting started

### Install

```bash
flutter pub add criteria_selector
```

### Import

```dart
import 'package:criteria_selector/criteria_selector.dart';
```

## Usage

### CriteriaSelector

`CriteriaSelector` is the public entry point for embedding a selector directly in a
page or dialog body. It takes a single `delegate` that decides both how entries are
loaded and how the selector body is rendered.

Before the per-delegate examples, here are the shared concepts every delegate builds on.

#### Common concepts

Entries form a tree. `SelectorCategoryEntry` is the root (a category) and
`SelectorChildEntry` is any non-root node, identified by its `parentId`.

| Entry | Purpose |
| --- | --- |
| `SelectorCategoryEntry` | Root node. Holds `children` and the `selectionMode` for them. |
| `SelectorTextEntry` | A plain text leaf. Use `.any(...)` for the "Any" (clear) entry. `.name(...)` creates a parentless leaf for flat lists. |
| `SelectorRangeEntry<N, E>` | A numeric range leaf (`min`/`max`). Use `.any(...)` for "Any" and `.custom(...)` for a user-input range. `SelectorIntEntry<E>` is a handy alias for `SelectorRangeEntry<int, E>`. |

Selection is controlled by `SelectionMode` (`single`, the default, or `multiple`), set
either on a `SelectorCategoryEntry` (per category) or on the delegate (fallback).

Entries are loaded asynchronously via `entriesLoader`, which returns a
`Future<SelectorEntries>` where `SelectorEntries` is `Set<SelectorEntry>`.

```dart
// A category with single-selection children
SelectorCategoryEntry(
  id: 'price',
  name: 'Price',
  children: {
    SelectorRangeEntry<int, void>.any(parentId: 'price', name: 'Any'),
    SelectorRangeEntry<int, void>(parentId: 'price', id: '0-100', name: '0-100', min: 0, max: 100),
    SelectorRangeEntry<int, void>.custom(parentId: 'price', name: 'Custom'),
  },
);

// A multi-selection category
SelectorCategoryEntry(
  id: 'more',
  name: 'More',
  selectionMode: SelectionMode.multiple,
  children: {
    SelectorTextEntry.any(parentId: 'more', name: 'Any'),
    SelectorTextEntry(parentId: 'more', id: 'near_subway', name: 'Near subway'),
  },
);

// Parentless leaves for a flat list
SelectorTextEntry.name(id: 'default', name: 'Default');
```

Every example below loads its data through an `entriesLoader` and is rendered by a
`CriteriaSelector`. The same delegates also drive the other entry points
(`DropdownSelectorBar`, `DropdownSelectorButton`, `showSelector`,
`showModalBottomSelector`) shown later.

#### CascadingSelectorDelegate

A tree-structured selector: categories on the left, a cascading list to the right.

```dart
Future<SelectorEntries> _fetchRegion() async {
  return {
    SelectorCategoryEntry(
      id: 'region',
      name: 'Region',
      children: {
        SelectorTextEntry.any(parentId: 'region', name: 'Any'),
        SelectorTextEntry(
          parentId: 'region',
          id: 'bj',
          name: 'Beijing',
          children: {
            SelectorTextEntry(parentId: 'bj', id: 'cy', name: 'Chaoyang'),
            SelectorTextEntry(parentId: 'bj', id: 'hd', name: 'Haidian'),
          },
        ),
      },
    ),
  };
}

CriteriaSelector(delegate: CascadingSelectorDelegate(entriesLoader: _fetchRegion));
```

![CascadingSelectorDelegate](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/sz/region.gif)

#### GridSelectorDelegate

A grid layout. `crossAxisCount` is required.

```dart
Future<SelectorEntries> _fetchPrice() async {
  return {
    SelectorCategoryEntry(
      id: 'price',
      name: 'Price',
      children: {
        SelectorRangeEntry<int, void>.any(parentId: 'price', name: 'Any'),
        SelectorRangeEntry<int, void>(parentId: 'price', id: '0-100', name: '0-100', min: 0, max: 100),
        SelectorRangeEntry<int, void>(parentId: 'price', id: '100-500', name: '100-500', min: 100, max: 500),
        SelectorRangeEntry<int, void>.custom(parentId: 'price', name: 'Custom'),
      },
    ),
  };
}

CriteriaSelector(
  delegate: GridSelectorDelegate(crossAxisCount: 3, entriesLoader: _fetchPrice),
);
```

![GridSelectorDelegate](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/atx/price.gif)

#### ListSelectorDelegate

A single-column list. Use parentless `SelectorTextEntry.name(...)` leaves for a flat list.

```dart
Future<SelectorEntries> _fetchSort() async {
  return {
    SelectorTextEntry.name(id: 'default', name: 'Default'),
    SelectorTextEntry.name(id: 'price_low', name: 'Price: low to high'),
    SelectorTextEntry.name(id: 'price_high', name: 'Price: high to low'),
  };
}

CriteriaSelector(delegate: ListSelectorDelegate(entriesLoader: _fetchSort));
```

![ListSelectorDelegate](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/atx/sort.gif)

#### FlattenSelectorDelegate

Renders children in a grid while keeping the category hierarchy. Pairs well with
`SelectionMode.multiple` and an "Any" entry.

```dart
Future<SelectorEntries> _fetchMore() async {
  return {
    SelectorCategoryEntry(
      id: 'more',
      name: 'More',
      selectionMode: SelectionMode.multiple,
      children: {
        SelectorTextEntry.any(parentId: 'more', name: 'Any'),
        SelectorTextEntry(parentId: 'more', id: 'near_subway', name: 'Near subway'),
        SelectorTextEntry(parentId: 'more', id: 'pet_friendly', name: 'Pet friendly'),
      },
    ),
  };
}

CriteriaSelector(
  delegate: FlattenSelectorDelegate(
    crossAxisCount: 3,
    selectionMode: SelectionMode.multiple,
    entriesLoader: _fetchMore,
  ),
);
```

![FlattenSelectorDelegate](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/atx/rooms.gif)

### DropdownSelectorBar

A tab bar (`PreferredSizeWidget`) that shows an overlay selector panel when a tab is
tapped. Provide `tabs` for the bar UI and a matching `selectorDelegates` list (one
delegate per tab). Selected results are delivered via `onChanged` / `onApplied` /
`onReset`.

```dart
DropdownSelectorBar(
  tabs: const [
    DropdownTab(label: 'Region'),
    DropdownTab(label: 'Price'),
    DropdownTab(label: 'Sort'),
  ],
  selectorDelegates: [
    CascadingSelectorDelegate(entriesLoader: _fetchRegion),
    GridSelectorDelegate(crossAxisCount: 3, entriesLoader: _fetchPrice),
    ListSelectorDelegate(entriesLoader: _fetchSort),
  ],
  onApplied: (result) {
    // result is a DropdownSelectorResult; result.selected is the SelectorEntries
  },
);
```

![DropdownSelectorBar](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/atx/more.gif)

### DropdownSelectorButton

A single-trigger alternative to `DropdownSelectorBar` — opens a selector overlay on
tap, like `PopupMenuButton`. It takes one `selectorDelegate` and a `label`/`child`.
Three variants are available via named constructors: filled (the default),
`.elevated(...)`, and `.outlined(...)`.

```dart
DropdownSelectorButton(
  label: 'Price',
  selectorDelegate: GridSelectorDelegate(crossAxisCount: 3, entriesLoader: _fetchPrice),
  onApplied: (result) { /* ... */ },
);

DropdownSelectorButton.elevated(
  label: 'Price',
  selectorDelegate: GridSelectorDelegate(crossAxisCount: 3, entriesLoader: _fetchPrice),
);

DropdownSelectorButton.outlined(
  label: 'Price',
  icon: const Icon(Icons.filter_alt_outlined),
  selectorDelegate: GridSelectorDelegate(crossAxisCount: 3, entriesLoader: _fetchPrice),
);
```

![DropdownSelectorButton](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/sz/floor_plan.gif)

### showSelector

Shows a selector in a modal dialog. Returns the selected `SelectorEntries` when
applied, or `null` when dismissed. In single-selection mode tapping an item applies
immediately; in multi-selection mode the action bar's "Apply" confirms.

```dart
final SelectorEntries? selected = await showSelector(
  context: context,
  delegate: ListSelectorDelegate(entriesLoader: _fetchSort),
  title: const Text('Sort'),
);

if (selected != null) {
  // a selection was applied
}
```

![showSelector](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/sz/sort.gif)

### showModalBottomSelector

Shows a selector in a modal bottom sheet built on Flutter's `showModalBottomSheet`.
Same interaction model as `showSelector`. Standard sheet parameters
(`isScrollControlled`, `isDismissible`, `enableDrag`, `showDragHandle`,
`constraints`, etc.) are forwarded.

```dart
final SelectorEntries? selected = await showModalBottomSelector(
  context: context,
  delegate: FlattenSelectorDelegate(
    crossAxisCount: 3,
    selectionMode: SelectionMode.multiple,
    entriesLoader: _fetchMore,
  ),
  title: const Text('More'),
);

if (selected != null) {
  // a selection was applied
}
```

![showModalBottomSelector](https://raw.githubusercontent.com/amlzq/criteria_selector/main/screenshots/sz/price.gif)

### Theming

**Per instance** — pass `selectorTheme` to any selector entry point
(`CriteriaSelector`, `showSelector`, `showModalBottomSelector`,
`DropdownSelectorBar`, `DropdownSelectorButton`):

```dart
CriteriaSelector(
  delegate: ListSelectorDelegate(entriesLoader: _fetchSort),
  selectorTheme: SelectorThemeData(
    Theme.of(context),
    selectedColor: Theme.of(context).colorScheme.primary,
    onSelectedColor: Theme.of(context).colorScheme.onPrimary,
  ),
);
```

**Globally** — register `DropdownSelectorBarTheme` and
`DropdownSelectorButtonTheme` as `ThemeData` extensions so every bar/button picks
them up automatically:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      DropdownSelectorBarTheme(
        height: 48,
        labelColor: Colors.blue,
        selectorTheme: SelectorThemeData(ThemeData.light()),
      ),
      DropdownSelectorButtonTheme(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    ],
  ),
);
```

### Internationalization

Add `CriteriaSelectorLocalizationsDelegate()` to your `MaterialApp`. It ships
translations for `en`, `zh` (Hans/Hant), `es`, `pt`, `id`, `vi`, `fr`, `de`, `ja`,
and `ko`, localizing the "Apply" / "Reset" / "Multiple" labels automatically.

```dart
const localizationsDelegates = <LocalizationsDelegate>[
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  CriteriaSelectorLocalizationsDelegate(),
];

const supportedLocales = CriteriaSelectorLocalizationsDelegate.supportedLocales;

MaterialApp(
  localizationsDelegates: localizationsDelegates,
  supportedLocales: supportedLocales,
  home: const HomePage(),
);
```

To override the labels for a single delegate, set `applyText` / `resetText` on it
directly.
