/// Deprecated API aliases for the `criteria_selector` package.
///
/// The `Dropselect*` public API has been renamed to `Dropdown*` for clarity and
/// consistency. The old names below are kept only as type/const aliases and are
/// scheduled for removal in the next major version.
///
/// Migration is a pure rename: every old symbol is the exact same type/value as
/// its new counterpart, so you can simply replace the name in your code.
library;

import 'dropdown_selector_bar.dart';
import 'dropdown_overlay.dart';
import 'dropdown_overlay_style.dart';
import 'dropdown_selector_result.dart';
import 'dropdown_tab_data.dart';
import 'dropdown_selector_controller.dart';
import 'dropdown_selector_bar_theme.dart';
import 'selector_delegate.dart';
import 'constants.dart';

/// Use [DropdownSelectorBar] instead.
@Deprecated(
  'Renamed to DropdownSelectorBar. The API and behavior are identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef DropselectTabBar = DropdownSelectorBar;

/// Use [DropdownTab] instead.
@Deprecated(
  'Renamed to DropdownTab. The API and behavior are identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef DropselectTab = DropdownTab;

/// Use [DropdownSelectorBarTheme] instead.
@Deprecated(
  'Renamed to DropdownSelectorBarTheme. The API and behavior are identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef DropselectTabBarTheme = DropdownSelectorBarTheme;

/// Use [DropdownSelectorController] instead.
@Deprecated(
  'Renamed to DropdownSelectorController. The API and behavior are identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef DropselectTabController = DropdownSelectorController;

/// Use [DropdownSelectorControllerProvider] instead.
@Deprecated(
  'Renamed to DropdownSelectorControllerProvider. The API and behavior are '
  'identical; simply rename the type. This alias will be removed in a future '
  'major version.',
)
typedef DropselectTabControllerProvider = DropdownSelectorControllerProvider;

/// Use [DropdownTabData] instead.
@Deprecated(
  'Renamed to DropdownTabData. The API and behavior are identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef DropselectTabData = DropdownTabData;

/// Use [DropdownSelectorResult] instead.
@Deprecated(
  'Renamed to DropdownSelectorResult. The API and behavior are identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef DropselectResult = DropdownSelectorResult;

/// Use [DropdownOverlay] instead.
@Deprecated(
  'Renamed to DropdownOverlay. The API and behavior are identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef DropselectOverlay = DropdownOverlay;

/// Use [DropdownOverlayStyle] instead.
@Deprecated(
  'Renamed to DropdownOverlayStyle. The API and behavior are identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef DropselectOverlayStyle = DropdownOverlayStyle;

/// Use [DropdownSelectorResultCallback] instead.
@Deprecated(
  'Renamed to DropdownSelectorResultCallback. The signature is identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef DropselectResultCallback = DropdownSelectorResultCallback;

/// Use [DropdownTabLabelGetter] instead.
@Deprecated(
  'Renamed to DropdownTabLabelGetter. The signature is identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef DropselectTabLabelGetter = DropdownTabLabelGetter;

/// Use [kDropdownSelectorBarHeight] instead.
@Deprecated(
  'Renamed to kDropdownSelectorBarHeight. This is the same constant; '
  'simply rename it. This alias will be removed in a future major version.',
)
const double kDropselectTabBarHeight = kDropdownSelectorBarHeight;

/// Use [kDropdownOverlayMaxHeightFactor] instead.
@Deprecated(
  'Renamed to kDropdownOverlayMaxHeightFactor. This is the same constant; '
  'simply rename it. This alias will be removed in a future major version.',
)
const double kDropselectOverlayMaxHeightFactor =
    kDropdownOverlayMaxHeightFactor;

/// Use [SelectorDelegate] instead.
@Deprecated(
  'Renamed to SelectorDelegate. The API and behavior are identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef Selector = SelectorDelegate;

/// Use [CascadingSelectorDelegate] instead.
@Deprecated(
  'Renamed to CascadingSelectorDelegate. The API and behavior are identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef CascadingSelector = CascadingSelectorDelegate;

/// Use [ListSelectorDelegate] instead.
@Deprecated(
  'Renamed to ListSelectorDelegate. The API and behavior are identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef ListSelector = ListSelectorDelegate;

/// Use [GridSelectorDelegate] instead.
@Deprecated(
  'Renamed to GridSelectorDelegate. The API and behavior are identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef GridSelector = GridSelectorDelegate;

/// Use [FlattenSelectorDelegate] instead.
@Deprecated(
  'Renamed to FlattenSelectorDelegate. The API and behavior are identical; '
  'simply rename the type. This alias will be removed in a future major version.',
)
typedef FlattenSelector = FlattenSelectorDelegate;
